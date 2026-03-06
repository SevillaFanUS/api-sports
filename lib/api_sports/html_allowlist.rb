# frozen_string_literal: true

# Allow the <api-sports-widget> custom element and all its data-* attributes
# to pass through Discourse's HTML sanitiser so widgets render in posts.

module ApiSports
  module HtmlAllowlist
    WIDGET_ATTRIBUTES = %w[
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

    def self.apply!
      Loofah::HTML5::SafeListProtocol::ALLOWED_ELEMENTS_WITH_OPTIONAL_ATTRIBUTES.add(
        "api-sports-widget"
      )

      WIDGET_ATTRIBUTES.each do |attr|
        Loofah::HTML5::SafeListProtocol::ALLOWED_ATTRIBUTES.add(attr)
      end
    end
  end
end
