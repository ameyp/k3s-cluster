{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.google-cloud-sdk
    pkgs.kubernetes-helm
    pkgs.minikube
    pkgs.terraform
    pkgs.vault
  ];
}
