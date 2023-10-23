{ config, pkgs, lib, ... }:
let
  pkg = pkgs.librewolf-unwrapped;
  extraPrefs = ''
    lockPref('media.peerconnection.enabled', false);
    lockPref("privacy.resistFingerprinting", false);

    lockPref("privacy.clearOnShutdown.cache", false);
    lockPref("privacy.clearOnShutdown.cookies", false);
    lockPref("privacy.clearOnShutdown.history", false);
    lockPref("privacy.clearOnShutdown.downloads", false);

    lockPref("permissions.default.geo", 2);
    lockPref("permissions.default.desktop-notification", 2);

    lockPref("identity.fxaccounts.enabled", true);

    lockPref("browser.compactmode.show", true);
    lockPref("browser.tabs.tabmanager.enabled", false);

    lockPref("xpinstall.enabled", false);
    lockPref("xpinstall.whitelist.required", true);
  '';
  extraPolicies = {
    AppAutoUpdate = false;
    ExtensionSettings = {
      "adguardadblocker@adguard.com" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
      };
      "uBlock0@raymondhill.net" = {
        installation_mode = "blocked";
      };
      "CanvasBlocker@kkapsner.de" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/latest.xpi";
      };
      "CookieAutoDelete@kennydo.com" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/cookie-autodelete/latest.xpi";
      };
      "customscrollbars@computerwhiz" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/custom-scrollbars/latest.xpi";
      };
      "{74145f27-f039-47ce-a470-a662b129930a}" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        default_area = "navbar";
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      };
      "firefox-translations-addon@mozilla.org" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/firefox-translations/latest.xpi";
      };
      "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = {
        default_area = "navbar";
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/single-file/latest.xpi";
      };
      "jid0-3GUEt1r69sQNSrca5p8kx9Ezc3U@jetpack" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/terms-of-service-didnt-read/addon-latest.xpi";
      };
      "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi";
      };
      "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/traduzir-paginas-web/latest.xpi";
      };
      "addon@darkreader.org" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
      };
    };
  };

  # By default, extraPolicies & extraPrefs in firefox-wrapper will **override** prebuilts.
  # This is not convenient as prebuilts are also required for librewolf.
  # So I rewrite the logic of extraPolicies & extraPrefs to ship both prebuilts and custom hacks together :)
  recursiveMerges = attrList:
    let
      f = attrPath:
        lib.zipAttrsWith (n: values:
          if lib.tail values == [ ] then
            lib.head values
          else if lib.all lib.isList values then
            lib.unique (lib.concatLists values)
          else if lib.all lib.isAttrs values then
            f (lib.attrPath ++ [ n ]) values
          else
            lib.last values);
    in
    f [ ] attrList;
  shippedPoliciesJSON = builtins.fromJSON
    (builtins.readFile (builtins.concatStringsSep "" pkg.extraPoliciesFiles));
  customPoliciesJSON = { policies = extraPolicies; };
  overallPolicyFile = pkgs.writeText "policy.json" (builtins.toJSON
    (recursiveMerges [ shippedPoliciesJSON customPoliciesJSON ]));

  shippedPrefs =
    builtins.readFile (builtins.concatStringsSep "" pkg.extraPrefsFiles);
  overallPrefsFile = pkgs.writeText "librewolf.cfg"
    (builtins.concatStringsSep "" [ shippedPrefs extraPrefs ]);
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkg {
      inherit (pkg)
        ;
      wmClass = "LibreWolf";
      libName = "librewolf";

      extraPoliciesFiles = [ overallPolicyFile ];
      extraPrefsFiles = [ overallPrefsFile ];
    };
  };

  home.packages = with pkgs; [ speechd ];
}
