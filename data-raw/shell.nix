# Install the nix package manager if it is not available: https://nixos.org/download/#download-nix
# This nix shell definition lets you run 'cue' in a nix shell.
# Install it by running the command 'nix-shell' in a terminal in this folder, then run `cue` in the
# nix shell. Enter 'exit' to exit the nix shell.

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    cue
  ];
}
