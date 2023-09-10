{ pkgs, ... }: {
  i18n.inputMethod = {
    enabled = "fcitx5";

    fcitx5 = {
      addons = with pkgs; [ fcitx5-chinese-addons fcitx5-gtk libsForQt5.fcitx5-qt ];
      ignoreUserConfig = true;
      settings = {
        globalOptions = {
          Hotkey = {
            EnumerateSkipFirst = "True";
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "默认";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };

          "Groups/0/Items/0" = {
            Name = "keyboard-us";
          };

          "Groups/0/Items/1" = {
            Name = "pinyin";
          };

          GroupOrder = {
            "0" = "默认";
          };
        };
        addons = {
          classicui.globalSection = {
            "Vertical Candidate List" = "True";
            UseDarkTheme = "True";
            EnableFractionalScale = "True";
          };
          pinyin.globalSection = {
            EmojiEnabled = "True";
            CloudPinyinEnabled = "False";
            CloudPinyinIndex = 2;
            VAsQuickphrase = "False";
          };
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.nur.repos.pokon548.fcitx5-pinyin-custompinyindict ];
}