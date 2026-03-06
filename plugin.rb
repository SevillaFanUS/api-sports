# frozen_string_literal: true

# name: discourse-api-sports
# about: Embeds api-sports.io football widgets into Discourse posts via a composer toolbar button
# version: 1.0.0
# authors: MonchisMen
# url: https://monchismen.com

enabled_site_setting :api_sports_enabled

require_relative "lib/api_sports/html_allowlist"

ApiSports::HtmlAllowlist.apply!(self)
