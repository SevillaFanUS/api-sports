# frozen_string_literal: true

module ApiSports
  class ProxyController < ::ApplicationController
    requires_plugin "discourse-api-sports"

    skip_before_action :check_xhr, only: [:fetch]
    before_action :ensure_logged_in

    # Proxy requests to api-sports.io with Redis caching
    # GET /api-sports/proxy?endpoint=fixtures&league=140&season=2025
    def fetch
      endpoint = params[:endpoint]
      return render_json_error("Missing endpoint", status: 400) if endpoint.blank?

      # Build cache key from all params
      cache_key = build_cache_key(endpoint, request.query_parameters.except(:endpoint))
      cache_duration = SiteSetting.api_sports_cache_duration.to_i.seconds

      # Try to get from cache first
      cached = Discourse.cache.read(cache_key)
      if cached.present?
        return render json: { data: cached, cached: true }
      end

      # Fetch from API Sports
      api_key = SiteSetting.api_sports_api_key
      return render_json_error("API key not configured", status: 500) if api_key.blank?

      response = fetch_from_api(endpoint, request.query_parameters.except(:endpoint), api_key)

      if response[:success]
        # Cache the successful response
        Discourse.cache.write(cache_key, response[:data], expires_in: cache_duration)
        render json: { data: response[:data], cached: false }
      else
        render_json_error(response[:error], status: response[:status] || 500)
      end
    end

    # Verify API key works and show quota usage
    # GET /api-sports/status
    def status
      return render_json_error("Admin only", status: 403) unless current_user&.admin?

      api_key = SiteSetting.api_sports_api_key
      return render json: { configured: false, error: "No API key set" } if api_key.blank?

      response = fetch_from_api("status", {}, api_key)

      if response[:success]
        data = response[:data]
        account = data.dig("response", "account") || {}
        requests = data.dig("response", "requests") || {}
        subscription = data.dig("response", "subscription") || {}

        render json: {
          configured: true,
          account: {
            firstname: account["firstname"],
            email: account["email"]
          },
          requests: {
            current: requests["current"],
            limit_day: requests["limit_day"]
          },
          subscription: {
            plan: subscription["plan"],
            active: subscription["active"]
          }
        }
      else
        render json: { configured: true, error: response[:error], valid: false }
      end
    end

    # Clear cache for specific widget type or all
    # DELETE /api-sports/cache?type=fixtures
    def clear_cache
      return render_json_error("Admin only", status: 403) unless current_user&.admin?

      cache_type = params[:type]

      if cache_type.present?
        # Clear specific type (pattern match)
        pattern = "api_sports:#{cache_type}:*"
        keys = Discourse.cache.redis.keys(pattern)
        keys.each { |key| Discourse.cache.delete(key) }
        render json: { cleared: keys.size, pattern: pattern }
      else
        # Clear all api_sports cache
        pattern = "api_sports:*"
        keys = Discourse.cache.redis.keys(pattern)
        keys.each { |key| Discourse.cache.delete(key) }
        render json: { cleared: keys.size, pattern: pattern }
      end
    end

    private

    def build_cache_key(endpoint, params)
      sorted_params = params.to_h.sort.map { |k, v| "#{k}=#{v}" }.join("&")
      "api_sports:#{endpoint}:#{Digest::MD5.hexdigest(sorted_params)}"
    end

    def fetch_from_api(endpoint, params, api_key)
      require "net/http"
      require "uri"

      base_url = "https://v3.football.api-sports.io"
      uri = URI("#{base_url}/#{endpoint}")
      uri.query = URI.encode_www_form(params) if params.present?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      http.open_timeout = 5

      request = Net::HTTP::Get.new(uri)
      request["x-apisports-key"] = api_key
      request["Accept"] = "application/json"

      begin
        response = http.request(request)

        if response.code.to_i == 200
          data = JSON.parse(response.body)
          { success: true, data: data }
        else
          { success: false, error: "API returned #{response.code}", status: response.code.to_i }
        end
      rescue StandardError => e
        Rails.logger.error("API Sports fetch error: #{e.message}")
        { success: false, error: e.message, status: 500 }
      end
    end
  end
end
