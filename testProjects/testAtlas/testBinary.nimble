# Package

version       = "0.1.0"
author        = "Jake Leahy"
description   = "Test when dependency contains a binary"
license       = "MIT"
srcDir        = "src"
bin           = @["testBinary"]


# Dependencies

requires "nim >= 2.2.8"
requires "nimsight"
requires "gh:ire4ever1190/scrolls"
