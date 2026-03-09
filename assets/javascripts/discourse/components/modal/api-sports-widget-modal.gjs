import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "truth-helpers";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";

const WIDGET_TYPES = [
  {
    id: "games",
    label: "Games — Daily Livescores",
    description:
      "Shows all matches for a given day across all competitions. Great for a matchday thread.",
    fields: [
      {
        key: "date",
        label: "Date",
        placeholder: "YYYY-MM-DD (leave blank for today)",
        required: false,
        attr: "data-date",
      },
    ],
  },
  {
    id: "league",
    label: "League — Full Schedule & Standings",
    description:
      "Full competition schedule, results by round, and standings. Best for a pinned competition topic.",
    fields: [
      {
        key: "league_id",
        label: "League ID",
        placeholder: "e.g. 140",
        required: true,
        attr: "data-id",
      },
      {
        key: "season",
        label: "Season",
        placeholder: "e.g. 2025",
        required: true,
        attr: "data-season",
      },
    ],
  },
  {
    id: "standings",
    label: "Standings — League Table",
    description: "Compact live league table. Ideal for embedding in any post.",
    fields: [
      {
        key: "league_id",
        label: "League ID",
        placeholder: "e.g. 140",
        required: true,
        attr: "data-id",
      },
      {
        key: "season",
        label: "Season",
        placeholder: "e.g. 2025",
        required: true,
        attr: "data-season",
      },
    ],
  },
  {
    id: "team",
    label: "Team — Squad & Stats",
    description:
      "Team profile with squad list, competitions, trophies and statistics.",
    fields: [
      {
        key: "team_id",
        label: "Team ID",
        placeholder: "e.g. 536",
        required: true,
        attr: "data-id",
      },
    ],
  },
  {
    id: "player",
    label: "Player — Player Profile",
    description:
      "Individual player stats, trophies and injury history for a given season.",
    fields: [
      {
        key: "player_id",
        label: "Player ID",
        placeholder: "e.g. 2295",
        required: true,
        attr: "data-id",
      },
    ],
  },
  {
    id: "game",
    label: "Game — Single Match Detail",
    description:
      "Full match breakdown: goals, cards, substitutions, stats and lineups.",
    fields: [
      {
        key: "fixture_id",
        label: "Fixture ID",
        placeholder: "e.g. 1208073",
        required: true,
        attr: "data-id",
      },
    ],
  },
  {
    id: "h2h",
    label: "Head-to-Head",
    description:
      "Full historical record between two clubs. Perfect for pre-match posts.",
    fields: [
      {
        key: "team1_id",
        label: "Team 1 ID",
        placeholder: "e.g. 536 (Sevilla)",
        required: true,
        attr: null,
      },
      {
        key: "team2_id",
        label: "Team 2 ID",
        placeholder: "e.g. 541 (Real Madrid)",
        required: true,
        attr: null,
      },
    ],
  },
];

const QUICK_IDS = [
  { label: "Sevilla FC", value: "536", type: "team" },
  { label: "La Liga", value: "140", type: "league" },
  { label: "Copa del Rey", value: "143", type: "league" },
  { label: "Europa League", value: "3", type: "league" },
  { label: "Champions League", value: "2", type: "league" },
  { label: "Atlético Madrid", value: "530", type: "team" },
  { label: "Real Madrid", value: "541", type: "team" },
  { label: "FC Barcelona", value: "529", type: "team" },
];

export default class ApiSportsWidgetModal extends Component {
  @service siteSettings;

  @tracked selectedTypeId = "games";
  @tracked fieldValues = {};
  @tracked validationError = null;

  constructor() {
    super(...arguments);
    // Pre-fill with defaults from site settings
    this.initializeDefaults();
  }

  initializeDefaults() {
    const defaults = {};
    if (this.siteSettings.api_sports_default_league_id) {
      defaults.league_id = this.siteSettings.api_sports_default_league_id;
    }
    if (this.siteSettings.api_sports_default_team_id) {
      defaults.team_id = this.siteSettings.api_sports_default_team_id;
    }
    if (this.siteSettings.api_sports_default_season) {
      defaults.season = this.siteSettings.api_sports_default_season;
    }
    this.fieldValues = defaults;
  }

  get widgetTypes() {
    return WIDGET_TYPES;
  }

  get quickIds() {
    return QUICK_IDS;
  }

  get selectedType() {
    return WIDGET_TYPES.find((w) => w.id === this.selectedTypeId);
  }

  get hasApiKey() {
    return !!this.siteSettings.api_sports_api_key;
  }

  get defaultsConfigured() {
    return !!(
      this.siteSettings.api_sports_default_league_id ||
      this.siteSettings.api_sports_default_team_id
    );
  }

  // Returns fields with their current value merged in — avoids (get ...) helper
  get fieldsWithValues() {
    const type = this.selectedType;
    if (!type) return [];
    return type.fields.map((field) => ({
      ...field,
      currentValue: this.fieldValues[field.key] || "",
    }));
  }

  get generatedHtml() {
    const type = this.selectedType;
    if (!type) return "";

    // Build BBCode attributes (without data- prefix)
    let attrs = `type="${type.id}"`;

    if (type.id === "h2h") {
      const t1 = (this.fieldValues["team1_id"] || "").trim();
      const t2 = (this.fieldValues["team2_id"] || "").trim();
      if (t1 && t2) {
        attrs += ` teams="${t1}-${t2}"`;
      }
    } else {
      type.fields.forEach((field) => {
        const val = (this.fieldValues[field.key] || "").trim();
        if (val && field.attr) {
          // Convert data-foo to foo for BBCode
          const bbcodeAttr = field.attr.replace("data-", "");
          attrs += ` ${bbcodeAttr}="${val}"`;
        }
      });
    }

    // Use BBCode syntax instead of raw HTML
    return `[api-sports ${attrs}][/api-sports]`;
  }

  @action
  selectType(typeId) {
    this.selectedTypeId = typeId;
    this.validationError = null;
    // Preserve defaults when switching types
    this.initializeDefaults();
  }

  @action
  updateField(key, event) {
    this.fieldValues = { ...this.fieldValues, [key]: event.target.value };
    this.validationError = null;
  }

  @action
  applyQuickId(chip) {
    const type = this.selectedType;
    if (!type) return;

    if (type.id === "team" && chip.type === "team") {
      this.fieldValues = { ...this.fieldValues, team_id: chip.value };
    } else if (
      (type.id === "league" || type.id === "standings") &&
      chip.type === "league"
    ) {
      this.fieldValues = { ...this.fieldValues, league_id: chip.value };
    } else if (type.id === "h2h" && chip.type === "team") {
      if (!this.fieldValues["team1_id"]) {
        this.fieldValues = { ...this.fieldValues, team1_id: chip.value };
      } else {
        this.fieldValues = { ...this.fieldValues, team2_id: chip.value };
      }
    }
    this.fieldValues = { ...this.fieldValues };
  }

  @action
  insertWidget() {
    const type = this.selectedType;

    for (const field of type.fields) {
      if (field.required) {
        const val = (this.fieldValues[field.key] || "").trim();
        if (!val) {
          this.validationError = `${field.label} is required.`;
          return;
        }
      }
    }

    this.validationError = null;
    const html = this.generatedHtml;
    this.args.model.toolbarEvent.addText(html);
    this.args.closeModal();
  }

  @action
  cancel() {
    this.args.closeModal();
  }

  <template>
    <DModal
      @title="Insert Football Widget"
      @closeModal={{@closeModal}}
      class="api-sports-modal"
    >
      <:body>
        {{#unless this.hasApiKey}}
          <div class="api-sports-no-key-warning">
            No API key configured. Ask your admin to set the
            <strong>api_sports_api_key</strong>
            site setting.
          </div>
        {{/unless}}

        {{#if this.defaultsConfigured}}
          <div class="api-sports-defaults-notice">
            Using configured defaults for League/Team IDs. You can override below.
          </div>
        {{/if}}

        <div class="api-sports-modal-layout">

          <div class="api-sports-type-list">
            <div class="api-sports-section-label">Widget Type</div>
            {{#each this.widgetTypes as |wtype|}}
              <button
                type="button"
                class="api-sports-type-btn {{if (eq this.selectedTypeId wtype.id) 'is-active'}}"
                {{on "click" (fn this.selectType wtype.id)}}
              >
                <span class="api-sports-type-label">{{wtype.label}}</span>
              </button>
            {{/each}}
          </div>

          <div class="api-sports-fields-panel">
            {{#if this.selectedType}}
              <div class="api-sports-type-description">
                {{this.selectedType.description}}
              </div>

              <div class="api-sports-section-label">Quick Fill</div>
              <div class="api-sports-quick-ids">
                {{#each this.quickIds as |chip|}}
                  <button
                    type="button"
                    class="api-sports-chip"
                    {{on "click" (fn this.applyQuickId chip)}}
                  >
                    {{chip.label}}
                    <span class="api-sports-chip-id">{{chip.value}}</span>
                  </button>
                {{/each}}
              </div>

              <div class="api-sports-section-label">Parameters</div>
              {{#each this.fieldsWithValues as |field|}}
                <div class="api-sports-field">
                  <label class="api-sports-field-label">
                    {{field.label}}
                    {{#if field.required}}
                      <span class="api-sports-required">*</span>
                    {{/if}}
                  </label>
                  <input
                    type="text"
                    class="api-sports-field-input"
                    placeholder={{field.placeholder}}
                    value={{field.currentValue}}
                    {{on "input" (fn this.updateField field.key)}}
                  />
                </div>
              {{/each}}

              {{#if this.validationError}}
                <div class="api-sports-validation-error">
                  ⚠️ {{this.validationError}}
                </div>
              {{/if}}

              <div class="api-sports-section-label">Generated Code</div>
              <div class="api-sports-html-preview">
                <code>{{this.generatedHtml}}</code>
              </div>
            {{/if}}
          </div>

        </div>
      </:body>

      <:footer>
        <DButton
          @action={{this.insertWidget}}
          @label="Insert Widget"
          @icon="plus"
          class="btn-primary"
        />
        <DButton
          @action={{this.cancel}}
          @label="Cancel"
          class="btn-flat"
        />
      </:footer>
    </DModal>
  </template>
}
