#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo $SCRIPT_DIR
echo $ROOT_DIR

xcodebuild docbuild -scheme KarrotListKit \
  -destination generic/platform=iOS \
  OTHER_DOCC_FLAGS="\
  --transform-for-static-hosting \
  --source-service github \
  --source-service-base-url https://github.com/daangn/KarrotListKit/blob/main \
  --output-path $ROOT_DIR/_site \
  --checkout-path $ROOT_DIR"