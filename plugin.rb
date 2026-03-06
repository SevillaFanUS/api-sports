# frozen_string_literal: true

# name: discourse-api-sports
# about: Embeds api-sports.io football widgets into Discourse posts via a composer toolbar button
# version: 1.1.0
# authors: MonchisMen
# url: https://monchismen.com

enabled_site_setting :api_sports_enabled

require_relative "lib/api_sports/html_allowlist"

ApiSports::HtmlAllowlist.apply!(self)

after_initialize do
  # Load the proxy controller
  require_relative "app/controllers/api_sports/proxy_controller"

  # Register routes for API proxy with caching
  Discourse::Application.routes.append do
    scope "/api-sports", defaults: { format: :json } do
      get "/proxy" => "api_sports/proxy#fetch"
      get "/status" => "api_sports/proxy#status"
      delete "/cache" => "api_sports/proxy#clear_cache"
    end
  end
end
