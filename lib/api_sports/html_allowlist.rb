# frozen_string_literal: true

# Allow the <api-sports-widget> custom element and all its data-* attributes
# to pass through Discourse's HTML sanitiser so widgets render in posts.

module ApiSports
  module HtmlAllowlist
    def self.apply!
      # Allowlist the custom element tag
      HtmlSanitize::ALLOWED_ELEMENTS_WITH_OPTIONAL_ATTRIBUTES.push(
        "api-sports-widget"
      ) unless HtmlSanitize::ALLOWED_ELEMENTS_WITH_OPTIONAL_ATTRIBUTES.include?("api-sports-widget")

      # Allowlist all data-* attributes on the element
      %w[
        data-type
        data-sport
        data-key
        data-id
        data-season
        data-date
        data-teams
        data-theme
        data-lang
        data-refresh
        data-show-logos
        data-show-error
        data-favorite
        data-standings
        data-player-trophies
        data-player-injuries
        data-team-squad
        data-team-statistics
        data-player-statistics
        data-tab
        data-game-tab
        data-target-player
        data-target-league
        data-target-team
        data-target-game
        data-target-standings
      ].each do |attr|
        unless HtmlSanitize::ALLOWED_ATTRIBUTES.include?(attr)
          HtmlSanitize::ALLOWED_ATTRIBUTES.push(attr)
        end
      end
    end
  end
end
