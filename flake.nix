{
  description = "testfailed's nixos-config for Android (nix-on-droid)";

  inputs = {
    # TODO: update nixpkgs and nix-on-droid to v24.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.url = "github:t184256/nix-on-droid/release-23.11";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # systems = [ "aarch64-linux" ];
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.nixpkgs-fmt.enable = true;
        };

        # Default shell.
        devShells.default = pkgs.mkShell {
          name = "default-shell";
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          packages = with pkgs; [
            just
          ];
        };
      };

      flake = {
        # nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        # 	modules = [ ./nix-on-droid.nix ];
        # };

        # TODO: Config for NixOS Server
        # nixosConfigurations...

        # TODO: Config for NixOS VM
        # nixosConfigurations...

        # TODO: Config for Macbook Air M1 (using nix-darwin)
        # darwinConfigurations...

        # Config for Android (using nix-on-droid)
        nixOnDroidConfigurations = {
          droid = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
            modules = [ ./hosts/droid/nix-on-droid.nix ];
            # config = ./hosts/droid/nix-on-droid.nix;
            # system = "aarch64-linux";
          };
        };
      };
    };
}
