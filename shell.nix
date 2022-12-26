{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.butane
    # pkgs.fluxcd
    pkgs.jsonnet
    pkgs.jsonnet-bundler
    pkgs.jsonnet-language-server
    pkgs.kubernetes-helm
    pkgs.minikube
    pkgs.packer
    pkgs.tanka
    pkgs.terraform
    pkgs.vault
  ];
}
