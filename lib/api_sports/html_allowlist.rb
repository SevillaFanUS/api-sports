# frozen_string_literal: true

# Allow the <api-sports-widget> custom element and all its data-* attributes
# to pass through Discourse's HTML sanitiser so widgets render in posts.
#
# We directly modify Loofah's allowlists which is the standard approach
# for Discourse plugins that need custom HTML elements.

module ApiSports
  module HtmlAllowlist
    WIDGET_TAG = "api-sports-widget"

    WIDGET_ATTRS = %w[
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
    ].freeze

    def self.apply!(plugin)
      # Loofah renamed WhiteList to SafeList in newer versions
      # Support both for compatibility
      safelist = if defined?(Loofah::HTML5::SafeList)
                   Loofah::HTML5::SafeList
                 else
                   Loofah::HTML5::WhiteList
                 end

      # Add the custom element to Loofah's allowlist
      safelist::ALLOWED_ELEMENTS.add(WIDGET_TAG)

      # Add all data attributes to Loofah's allowlist
      WIDGET_ATTRS.each do |attr|
        safelist::ALLOWED_ATTRIBUTES.add(attr)
      end
    end
  end
end
