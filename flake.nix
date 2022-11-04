{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.openapi2jsonschema =
    {
      url = "github:instrumenta/openapi2jsonschema";
      flake = false;
    };

  outputs = { self, nixpkgs, openapi2jsonschema }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.hello;
          });

    in
    {
      inherit packages;
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            buildInputs = with pkgs; [
              python3
              python3Packages.pip
            ];
          };
        });
    };
}
