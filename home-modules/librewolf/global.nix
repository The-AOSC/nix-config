{...}: {
  modules.librewolf.globalConfig = {
    settings = {
      # about:config
      "browser.startup.page" = 3; # restore last session
      "browser.tabs.closeWindowWithLastTab" = false; # keep window open when last tab is closed
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.translations.automaticallyPopup" = false;
      "devtools.toolbox.host" = "window"; # display in separate window
      "extensions.autoDisableScopes" = 0; # automatically enable declarative extensions
      "privacy.resistFingerprinting" = false; # has many issues with extensions
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome.css
      "xpinstall.signatures.required" = false; # allow unsigned extensions
    };
    extensions.force = true;
    search = {
      force = true;
      default = "ddg";
      privateDefault = "ddg";
      engines = {
        ddg = {};
      };
    };
    file = {
      # force declarative settings
      "compatibility.ini" = "";
      "prefs.js" = "";
    };
  };
}
