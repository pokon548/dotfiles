{ config, pkgs, lib, ... }:
let
  pkg = pkgs.librewolf-unwrapped;
  extraPrefs = ''
    lockPref('media.peerconnection.enabled', false);
    lockPref("privacy.resistFingerprinting", false);

    lockPref("privacy.clearOnShutdown.history", false);
    lockPref("privacy.clearOnShutdown.downloads", false);

    lockPref("identity.fxaccounts.enabled", true);

    lockPref("browser.compactmode.show", true);
    lockPref("browser.tabs.tabmanager.enabled", false);
  '';
  extraPolicies = {
    ExtensionSettings = {
      "adguardadblocker@adguard.com" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/adguard-adblocker/latest.xpi";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        default_area = "navbar";
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      };
      "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = {
        default_area = "navbar";
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/single-file/latest.xpi";
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
      "leechblockng@proginosko.com" = {
        installation_mode = "force_installed";
        install_url =
          "https://addons.mozilla.org/firefox/downloads/latest/leechblock-ng/latest.xpi";
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
