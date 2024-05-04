{
  config,
  lib,
  pkgs,
  ...
}: {

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  users.users.root = {
    hashedPassword = "$y$j9T$67lOar4UwWjRxaTypZV1W0$dPrgYqUJppfVUf/ugSTwVp5brl2y94B.2h060m495sC";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgGW4Y7S8YO3Se/1AK1ZuIaAtxa+sakK4SBv/nixRyJ cim@thecowboy.ai"];    
	};

  users.users.cim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    useDefaultShell = false;
    hashedPassword = "$y$j9T$67lOar4UwWjRxaTypZV1W0$dPrgYqUJppfVUf/ugSTwVp5brl2y94B.2h060m495sC";
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgGW4Y7S8YO3Se/1AK1ZuIaAtxa+sakK4SBv/nixRyJ cim@thecowboy.ai"];    
  };

  nixpkgs.config.allowUnfree = true;

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = false;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    neofetch
    nano
    openssl
    pciutils
    pv
    zip
    cacert
    curl
    wget
  ];

  # copy the install files to the iso
  isoImage.isoName = lib.mkForce "cim-vhost-dev-stable-install.iso";

  system.activationScripts.copyConfigFiles = {
    text = ''
      # Ensure the target directory exists
      mkdir -p /etc/nixcfg/dev /etc/nixcfg/dns /etc/nixcfg/nats

      # utility stuff I don't like typing
      echo 'ip addr' >>~nixos/.bash_history
      echo 'sudo systemctl restart install.service &'  >>~nixos/.bash_history
      echo 'journalctl -fb -n100 -uinstall' >>~nixos/.bash_history
      echo 'sudo systemctl restart wpa_supplicant.service'  >>~nixos/.bash_history

      # build an inventory file (we will extend and clean this soon)
      servicetag=$(cat /sys/class/dmi/id/product_serial)
      echo "servicetag: '$servicetag'" >> /etc/nixcfg/inventory.yaml

      # Copy files to the target directory
      cp -r ${./vhost-dev}/* /etc/nixcfg/
      cp ${../../compute/dev/configuration.nix} /etc/nixcfg/dev/configuration.nix
      cp ${../../compute/dns/configuration.nix} /etc/nixcfg/dns/configuration.nix
      cp ${../../compute/nats/configuration.nix} /etc/nixcfg/nats/configuration.nix
    '';
    deps = [ "users" ];  # Run after the 'users' activation script
  };

  system.stateVersion = "23.11";
}
