{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "bearssl";
  version = "0.6";

  src = fetchurl {
    url = "https://www.bearssl.org/bearssl-${version}.tar.gz";
    sha256 = "057zhgy9w4y8z2996r0pq5k2k39lpvmmvz4df8db8qa9f6hvn1b7";
  };

  outputs = [
    "bin"
    "lib"
    "dev"
    "out"
  ];

  enableParallelBuilding = true;

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
    "CC=${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc.targetPrefix}cc"
    "LDDLL=${stdenv.cc.targetPrefix}cc"
  ]
  ++ lib.optional stdenv.hostPlatform.isStatic "DLL=no";

  installPhase = ''
    runHook preInstall
    install -D build/brssl $bin/brssl
    install -D build/testcrypto $bin/testcrypto
    install -Dm644 -t $lib/lib build/libbearssl.*
    install -Dm644 -t $dev/include inc/*.h
    touch $out
    runHook postInstall
  '';

  meta = {
    homepage = "https://www.bearssl.org/";
    description = "Implementation of the SSL/TLS protocol written in C";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
