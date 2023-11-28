{ lib, ... }: {
  security.pam.services.sshd = {
    unixAuth = lib.mkForce true;
    googleAuthenticator.enable = true;
  };
}
