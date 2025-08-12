# Install the nix package manager if it is not available: https://nixos.org/download/#download-nix
# This nix shell definition lets you run 'cue' version 0.8.2 under go version go1.22.8 in a nix shell.
# Start it by running 'nix-shell' in this folder.

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    cue
  ];
}
