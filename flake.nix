{
  description = "Python OTR implementation; it does not bind to libotr";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.python-gnutls={url=github:/AGProjects/python-gnutls; flake=false;};
  outputs = { self, nixpkgs,python-gnutls}:
    let


      supportedSystems = [ "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

          python-gnutls = with final; python38.pkgs.buildPythonPackage rec {
          pname = "python-gnutls";
          version = "3.1.3";
        
          src = python-gnutls;
        
          buildInputs = [
           gnutls 
          ];
 
          checkInputs = with python38Packages; [
            nose
            rednose
          ];
          doCheck=false;
          /*
          Tests are broken https://github.com/python-otr/pure-python-otr/issues/75
          */
          checkPhase = ''
            ls -l
            SRC_ROOT=$(cd -P $(dirname "$0") && pwd)
            export PYTHONPATH=$PYTHONPATH:"$SRC_ROOT/src"

            nosetests --rednose --verbose
          '';
        
        
          meta = with lib; {
            description = "Python wrapper for the GnuTLS Library";
            homepage = https://github.com/AGProjects/python-gnutls;
            license = licenses.lgpl2Plus;
          };
        };
      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) python-gnutls;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.python-gnutls);

      devShell = forAllSystems (system: self.packages.${system}.python-gnutls);


    };
}
