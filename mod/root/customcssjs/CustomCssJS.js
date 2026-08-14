define([
  "events",
  "connectionManager",
], function (
  events,
  connectionManager,
  ) {
  "use strict";

  return function () {
    this.id = "customcssjs";
    this.type = "customcssjs";

    function getApiClient() {
      try {
        if (connectionManager && connectionManager.currentApiClient) {
          var api = connectionManager.currentApiClient();
          if (api && api.serverAddress) return api;
        }
      } catch (e) {}
      try {
        if (window.ApiClient && window.ApiClient.serverAddress) return window.ApiClient;
      } catch (e) {}
      try {
        if (globalThis.ApiClient && globalThis.ApiClient.serverAddress) return globalThis.ApiClient;
      } catch (e) {}
      return null;
    }

    function loadCss(name, content, source) {
      try {
        var s = document.createElement("style");
        s.type = "text/css";
        s.innerHTML = content;
        document.head.appendChild(s);
        console.warn("[CustomCssJS] load CSS from " + source + ": " + name);
      } catch (e) {
        console.error("[CustomCssJS] load CSS error: " + e);
      }
    }

    function loadJS(name, content, source) {
      try {
        new Function(content)();
        console.warn("[CustomCssJS] load JS from " + source + ": " + name);
      } catch (e) {
        console.error("[CustomCssJS] load JS error: " + e);
      }
    }

    function loadCode(custom, type, source) {
      if (type === "css") {
        custom.forEach(function(item) { loadCss(item.name, item.content, source); });
      } else if (type === "js") {
        custom.forEach(function(item) { loadJS(item.name, item.content, source); });
      }
    }

    function getCustom(type, config) {
      var api = getApiClient();
      var serverId = api ? api.serverId() : "default";
      var customServerConfig = localStorage.getItem("custom" + type + "ServerConfig_" + serverId);
      if (!customServerConfig) {
        customServerConfig = [];
        localStorage.setItem("custom" + type + "ServerConfig_" + serverId, JSON.stringify(customServerConfig));
      } else {
        customServerConfig = JSON.parse(customServerConfig);
      }
      var customServer = config["custom" + type].filter(function(item) {
        return (item.state === "on" && customServerConfig.indexOf(item.name) >= 0) || item.state === "forced_on";
      });

      var customLocalConfig = localStorage.getItem("custom" + type + "LocalConfig");
      if (!customLocalConfig) {
        customLocalConfig = [];
        localStorage.setItem("custom" + type + "LocalConfig", JSON.stringify(customLocalConfig));
      } else {
        customLocalConfig = JSON.parse(customLocalConfig);
      }
      var customLocal = localStorage.getItem("custom" + type + "Local");
      if (!customLocal) {
        customLocal = [];
        localStorage.setItem("custom" + type + "Local", JSON.stringify(customLocal));
      } else {
        customLocal = JSON.parse(customLocal).filter(function(item) {
          return customLocalConfig.indexOf(item.name) >= 0;
        });
      }

      return [customServer, customLocal];
    }

    function loadConfiguration() {
      var api = getApiClient();
      if (!api) {
        console.warn("[CustomCssJS] No ApiClient available yet, deferring load");
        return false;
      }
      if (window.isCustomCssJSLoad) return true;
      
      api.getJSON(api.getUrl("CustomCssJS/Scripts", {})).then(function(config) {
        if (!window.isCustomCssJSLoad) {
          window.isCustomCssJSLoad = true;
          console.log("[CustomCssJS] Scripts loaded, applying...");
          var jsPair = getCustom("js", config);
          var cssPair = getCustom("css", config);
          loadCode(cssPair[0], "css", "Server");
          loadCode(cssPair[1], "css", "Local");
          loadCode(jsPair[0], "js", "Server");
          loadCode(jsPair[1], "js", "Local");
        }
      }, function(err) {
        console.error("[CustomCssJS] Failed to load scripts:", err);
        if (window.isCustomCssJSLoad) {
          reload();
        }
      });
      return true;
    }

    function reload() {
      if (typeof MainActivity === "undefined") {
        window.location.href = "index.html";
      } else {
        if (document.getElementById("Carnival")) {
          window.location.href = "index.html";
        } else {
          MainActivity.exitApp();
          setTimeout(function() { window.open("emby://items", "_blank"); }, 150);
        }
      }
    }

    // Listen for user sign-in event (original behavior)
    events.on(connectionManager, "localusersignedin", function() {
      console.log("[CustomCssJS] localusersignedin event received");
      loadConfiguration();
    });

    // Also listen for apiclientcreated — fires when ApiClient is first created
    events.on(connectionManager, "apiclientcreated", function() {
      console.log("[CustomCssJS] apiclientcreated event received");
      loadConfiguration();
    });

    // Poll for ApiClient availability — covers the case where the user
    // was already signed in before this module loaded (Emby 4.9 persistent sessions)
    var pollAttempts = 0;
    var maxPollAttempts = 20;
    function pollForApiClient() {
      if (window.isCustomCssJSLoad) return;
      var api = getApiClient();
      if (api) {
        console.log("[CustomCssJS] ApiClient found after " + pollAttempts + " attempts, loading scripts");
        loadConfiguration();
      } else if (pollAttempts < maxPollAttempts) {
        pollAttempts++;
        setTimeout(pollForApiClient, 500);
      } else {
        console.warn("[CustomCssJS] ApiClient not found after " + maxPollAttempts + " attempts, giving up");
      }
    }
    pollForApiClient();

  }
});
