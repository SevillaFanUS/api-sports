const rule = {
  tag: "api-sports",

  before(state, tagInfo) {
    const attrs = tagInfo.attrs;
    const token = state.push("bbcode_open", "api-sports-widget", 1);

    token.attrs = [];

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

    // Set display style so widget is visible
    token.attrs.push(["style", "display:block;min-height:100px;"]);
  },

  after(state) {
    state.push("bbcode_close", "api-sports-widget", -1);
  },
};

export function setup(helper) {
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
    "api-sports-widget[style]",
  ]);

  helper.registerPlugin((md) => {
    md.block.bbcode.ruler.push("api-sports", rule);
  });
}
