{
  description = "rust nix shells";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , rust-overlay
    }: flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        packages = rec {
          myRustPlatform = pkgs.makeRustPlatform { cargo = rust-stable; rustc = rust-stable; };
          cargo-show-asm = with pkgs; myRustPlatform.buildRustPackage rec {
            pname = "cargo-show-asm";
            version = "0.1.2";
            src = fetchCrate {
              inherit pname version;
              sha256 = "sha256-8AlsQScsMXoXiqISR0GX256GGElWYDNUALrpNnb7qGA=";
            };
            cargoHash = "sha256-lvln+x6n03Xy9otcmqBpvhTSsqItLFsAAxEgZySPgEE=";
            nativeBuildInputs = [ pkg-config ];
            buildInputs = [ openssl ];
          };
          rust-stable = pkgs.rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; };
        };
        devShells = {
          stable = with pkgs; mkShell {
            buildInputs = [
              bashInteractive
              packages.rust-stable
              cargo-edit
              llvmPackages_latest.bintools
              packages.cargo-show-asm
            ];
            RUSTFLAGS = "-Clink-arg=-fuse-ld=lld";
          };
        };
      }
    );
}
