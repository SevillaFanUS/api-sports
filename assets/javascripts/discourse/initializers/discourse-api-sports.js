import { withPluginApi } from "discourse/lib/plugin-api";
import { service } from "@ember/service";
import ApiSportsModal from "../components/modal/api-sports-widget-modal";

export default {
  name: "discourse-api-sports",

  initialize() {
    withPluginApi("0.8.31", (api) => {
      const siteSettings = api.container.lookup("service:site-settings");

      if (!siteSettings.api_sports_enabled) {
        return;
      }

      // Inject the api-sports widget script into <head> once
      if (!document.getElementById("api-sports-widget-script")) {
        const script = document.createElement("script");
        script.id = "api-sports-widget-script";
        script.type = "module";
        script.crossOrigin = "anonymous";
        script.src = "https://widgets.api-sports.io/3.1.0/widgets.js";
        document.head.appendChild(script);
      }

      // Inject a hidden global config widget
      function ensureConfigWidget() {
        if (document.getElementById("api-sports-global-config")) {
          return;
        }

        const config = document.createElement("api-sports-widget");
        config.id = "api-sports-global-config";
        config.setAttribute("data-type", "config");
        config.setAttribute("data-sport", "football");
        config.setAttribute("data-key", siteSettings.api_sports_api_key || "");
        config.setAttribute("data-theme", siteSettings.api_sports_theme || "dark");
        config.setAttribute(
          "data-refresh",
          String(siteSettings.api_sports_widget_refresh || 60)
        );
        config.setAttribute("data-show-logos", "true");
        config.setAttribute("data-show-error", "true");
        config.setAttribute("data-lang", "en");
        config.setAttribute("data-target-player", "modal");
        config.style.display = "none";
        document.body.appendChild(config);
      }

      api.onPageChange(() => {
        ensureConfigWidget();
      });

      // Ensure config widget exists on initial load
      ensureConfigWidget();

      // Add toolbar button
      api.onToolbarCreate((toolbar) => {
        toolbar.addButton({
          id: "api-sports-widget",
          group: "extras",
          icon: "futbol",
          title: "api_sports.toolbar_button_title",
          action: "showApiSportsModal",
        });
      });

      // Wire modal to composer
      api.modifyClass("controller:composer", {
        pluginId: "discourse-api-sports",
        modal: service(),

        actions: {
          showApiSportsModal() {
            this.modal.show(ApiSportsModal, {
              model: { toolbarEvent: this.toolbarEvent },
            });
          },
        },
      });
    });
  },
};
