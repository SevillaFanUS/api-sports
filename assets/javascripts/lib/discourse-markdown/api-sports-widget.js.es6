// Transform [api-sports] BBCode into <api-sports-widget> custom elements
// and allowList the output so it survives sanitization

function setupApiSportsRule(md) {
  // Block-level BBCode rule for [api-sports type="..." ...]...[/api-sports]
  md.block.bbcode.ruler.push("api-sports", {
    tag: "api-sports",

    wrap: function (token, tagInfo) {
      token.tag = "api-sports-widget";
      token.attrs = [];

      // Parse all attributes from the BBCode tag and convert to data-* attrs
      const attrs = tagInfo.attrs;

      // Handle [api-sports=games] shorthand
      if (attrs._default) {
        token.attrs.push(["data-type", attrs._default]);
      }

      // Handle explicit attributes
      if (attrs.type) token.attrs.push(["data-type", attrs.type]);
      if (attrs.id) token.attrs.push(["data-id", attrs.id]);
      if (attrs.season) token.attrs.push(["data-season", attrs.season]);
      if (attrs.date) token.attrs.push(["data-date", attrs.date]);
      if (attrs.teams) token.attrs.push(["data-teams", attrs.teams]);
      if (attrs.sport) token.attrs.push(["data-sport", attrs.sport]);

      return true;
    },
  });
}

export function setup(helper) {
  if (!helper.markdownIt) {
    return;
  }

  // AllowList the widget element and its attributes
  helper.allowList([
    "api-sports-widget",
    "api-sports-widget[data-type]",
    "api-sports-widget[data-sport]",
    "api-sports-widget[data-key]",
    "api-sports-widget[data-id]",
    "api-sports-widget[data-season]",
    "api-sports-widget[data-date]",
    "api-sports-widget[data-teams]",
    "api-sports-widget[data-theme]",
    "api-sports-widget[data-lang]",
    "api-sports-widget[data-refresh]",
    "api-sports-widget[data-show-logos]",
    "api-sports-widget[data-show-error]",
    "api-sports-widget[data-favorite]",
    "api-sports-widget[data-standings]",
    "api-sports-widget[data-player-trophies]",
    "api-sports-widget[data-player-injuries]",
    "api-sports-widget[data-team-squad]",
    "api-sports-widget[data-team-statistics]",
    "api-sports-widget[data-player-statistics]",
    "api-sports-widget[data-tab]",
    "api-sports-widget[data-game-tab]",
    "api-sports-widget[data-target-player]",
    "api-sports-widget[data-target-league]",
    "api-sports-widget[data-target-team]",
    "api-sports-widget[data-target-game]",
    "api-sports-widget[data-target-standings]",
    "api-sports-widget[style]",
  ]);

  // Register the BBCode-to-HTML transformation
  helper.registerPlugin(setupApiSportsRule);
}
