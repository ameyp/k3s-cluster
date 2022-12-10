{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.butane
    pkgs.kubernetes-helm
    pkgs.minikube
    pkgs.packer
    pkgs.terraform
    pkgs.vault
  ];
}
