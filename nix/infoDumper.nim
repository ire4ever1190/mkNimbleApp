# Small script to dump info from a nimble file without needing to to use `nimble dump` (which requires dependencies to be
# installed)

import std/[json, paths, files]
import system/nimscript

let file = Path"@NIMBLE_FILE"

include "@NIMBLE_FILE"

echo %*{
  "name": $file.splitFile().name,
  "version": version,
  "binDir": binDir,
  "srcDir": srcDir,
  "bin": bin,
  "license": license,
  "desc": description,
  "author": author
}
