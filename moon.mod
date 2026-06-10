name = "justjavac/keepawake"

version = "0.1.2"

import {
  "justjavac/ffi@0.2.2",
}

readme = "README.mbt.md"

repository = "https://github.com/justjavac/moonbit-keepawake"

license = "MIT"

keywords = [
  "keepawake",
  "native",
  "windows",
  "linux",
  "macos",
  "power-management",
]

description = "Native keep-awake guards for MoonBit on Windows, Linux, and macOS."

preferred_target = "native"

supported_targets = "native"

options(
  source: "src",
)
