# frozen_string_literal: true

# name: discourse-api-sports
# about: Embeds api-sports.io football widgets into Discourse posts via a composer toolbar button
# version: 1.0.0
# authors: MonchisMen
# url: https://monchismen.com

enabled_site_setting :api_sports_enabled

after_initialize do
  WIDGET_TAG = "api-sports-widget"

  WIDGET_ATTRIBUTES = %w[
    data-type data-sport data-key data-id data-season data-date data-teams
    data-theme data-lang data-refresh data-show-logos data-show-error
    data-favorite data-standings data-player-trophies data-player-injuries
    data-team-squad data-team-statistics data-player-statistics data-tab
    data-game-tab data-target-player data-target-league data-target-team
    data-target-game data-target-standings
  ].freeze

  # Discourse uses PrettyText which exposes an allowlist API for plugins.
  # This is the correct, non-frozen-safe way to extend the sanitizer.
  if defined?(PrettyText)
    PrettyText.add_allowlist(
      elements: [WIDGET_TAG],
      attributes: { WIDGET_TAG => WIDGET_ATTRIBUTES }
    )
  end
end
