#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

rm -rf output

./build.sh

./generate-package-swift.sh

git add -A

git commit -m "Update Package.swift"

git push -f

./upload-release.sh

gh release edit "v${MPP_BUILD_VERSION}" --repo "${GITHUB_REPO}" --draft=false
