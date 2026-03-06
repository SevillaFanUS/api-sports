# frozen_string_literal: true

# Allow the <api-sports-widget> custom element and all its data-* attributes
# to pass through Discourse's HTML sanitiser so widgets render in posts.
#
# Discourse uses the `register_html_builder` / `register_allowlist_entry` API
# on the plugin instance for new-style plugins. Here we use the lower-level
# approach of registering a Loofah scrubber so the custom element and its
# attributes survive sanitisation.

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
      plugin.register_html_builder("cooking") do |doc|
        # no-op: we just need the tag/attr allowlist entries below
        doc
      end

      WIDGET_ATTRS.each do |attr|
        plugin.register_allowlist_entry(:attribute, WIDGET_TAG, attr)
      end

      plugin.register_allowlist_entry(:element, WIDGET_TAG)
    end
  end
end
