import { apiInitializer } from "discourse/lib/api-initializer";
import { inject as service } from "@ember/service";
import ApiSportsModal from "../components/modal/api-sports-widget-modal";

export default apiInitializer("1.8.0", (api) => {
  if (!api.container.lookup("service:site-settings").api_sports_enabled) {
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

    const siteSettings = api.container.lookup("service:site-settings");
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
    config.setAttribute("data-show-error", "false");
    config.setAttribute("data-lang", "en");
    config.setAttribute("data-target-player", "modal");
    config.style.display = "none";
    document.body.appendChild(config);
  }

  api.onPageChange(() => {
    ensureConfigWidget();
  });

  // Add toolbar button
  api.onToolbarCreate((toolbar) => {
    toolbar.addButton({
      id: "api-sports-widget",
      group: "extras",
      icon: "futbol",
      title: "api_sports.toolbar_button_title",
      sendAction: (event) => {
        toolbar.context.send("showApiSportsModal", event);
      },
    });
  });

  // Wire modal to composer — modal must be a declared service, not a container lookup
  api.modifyClass("component:d-editor", {
    pluginId: "discourse-api-sports",
    modal: service(),

    actions: {
      showApiSportsModal(toolbarEvent) {
        this.modal.show(ApiSportsModal, {
          model: { toolbarEvent },
        });
      },
    },
  });
});
