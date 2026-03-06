# frozen_string_literal: true

# name: discourse-api-sports
# about: Embeds api-sports.io football widgets into Discourse posts via a composer toolbar button
# version: 1.0.0
# authors: MonchisMen
# url: https://monchismen.com

enabled_site_setting :api_sports_enabled

after_initialize do
  # Allow <api-sports-widget> custom element and its data-* attributes to survive
  # the Sanitize-gem-based post sanitiser that Discourse runs on cooked HTML.
  #
  # Discourse exposes its sanitise config via PrettyText::ALLOWED_CUSTOM_CLASS_NAMES
  # and the Sanitize::Config::DISCOURSE hash – we patch the latter's :elements and
  # :attributes lists so the widget tags are preserved end-to-end.
  require "sanitize"

  WIDGET_TAG = "api-sports-widget"

  WIDGET_ATTRIBUTES = %w[
    data-type data-sport data-key data-id data-season data-date data-teams
    data-theme data-lang data-refresh data-show-logos data-show-error
    data-favorite data-standings data-player-trophies data-player-injuries
    data-team-squad data-team-statistics data-player-statistics data-tab
    data-game-tab data-target-player data-target-league data-target-team
    data-target-game data-target-standings
  ].freeze

  # Find whichever Sanitize config Discourse actually uses and extend it.
  # Discourse stores it in PrettyText::SANITIZE_CONFIG (older) or builds it
  # dynamically; patching the Sanitize::Config::RELAXED elements list is the
  # safest cross-version approach used by several community plugins.
  [
    defined?(PrettyText::SANITIZE_CONFIG) ? PrettyText::SANITIZE_CONFIG : nil,
    defined?(Sanitize::Config::DISCOURSE)  ? Sanitize::Config::DISCOURSE  : nil,
  ].compact.each do |cfg|
    cfg[:elements] = (cfg[:elements] + [WIDGET_TAG]).uniq if cfg[:elements].is_a?(Array)

    cfg[:attributes] ||= {}
    existing = cfg[:attributes][WIDGET_TAG] || []
    cfg[:attributes][WIDGET_TAG] = (existing + WIDGET_ATTRIBUTES).uniq
  end

  # Also patch the Sanitize allowlists that Discourse registers through
  # its own HtmlSanitizer class if present (Discourse ≥ 3.x).
  if defined?(Sanitize) && Sanitize.respond_to?(:clean)
    # Belt-and-suspenders: patch Sanitize::Config::RELAXED as well so that any
    # code path calling Sanitize.clean with RELAXED config also works.
    if defined?(Sanitize::Config::RELAXED)
      cfg = Sanitize::Config::RELAXED
      cfg[:elements] = (cfg[:elements] + [WIDGET_TAG]).uniq if cfg[:elements].is_a?(Array)
      cfg[:attributes] ||= {}
      cfg[:attributes][WIDGET_TAG] = WIDGET_ATTRIBUTES
    end
  end
end
