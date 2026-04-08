#!/usr/bin/env bash
# Download prebuilt GenAI/GenAIC frameworks from Google's CDN and repackage for SPM
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"
SPM_OUTPUT_DIR="${SPM_OUTPUT_DIR:-./spm/output}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Google CDN base URL
# These URLs come from the CocoaPods podspecs (pod spec cat MediaPipeTasksGenAI)
GENAI_URL="${GENAI_URL:-}"
GENAIC_URL="${GENAIC_URL:-}"

echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   GenAI/GenAIC Prebuilt Framework Downloader       ║${NC}"
echo -e "${GREEN}║   Version: ${MPP_BUILD_VERSION}                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

MPP_ROOT_DIR=$(git rev-parse --show-toplevel)
cd "$MPP_ROOT_DIR"

mkdir -p "$SPM_OUTPUT_DIR/archives"
mkdir -p "$SPM_OUTPUT_DIR/checksums"
SPM_OUTPUT_DIR="$(cd "$SPM_OUTPUT_DIR" && pwd)"

CHECKSUM_REPORT="$SPM_OUTPUT_DIR/checksums.txt"

# Resolve download URLs from CocoaPods podspec if not provided
resolve_urls() {
    if [ -z "$GENAI_URL" ] || [ -z "$GENAIC_URL" ]; then
        echo -e "${YELLOW}Resolving download URLs from CocoaPods...${NC}"

        if ! command -v pod &> /dev/null; then
            echo -e "${RED}❌ CocoaPods (pod) is not installed. Install with: gem install cocoapods${NC}"
            echo -e "${RED}   Or set GENAI_URL and GENAIC_URL manually.${NC}"
            exit 1
        fi

        if [ -z "$GENAI_URL" ]; then
            GENAI_URL=$(pod spec cat MediaPipeTasksGenAI 2>/dev/null | ruby -rjson -e 'puts JSON.parse(STDIN.read)["source"]["http"]' 2>/dev/null || true)
        fi
        if [ -z "$GENAIC_URL" ]; then
            GENAIC_URL=$(pod spec cat MediaPipeTasksGenAIC 2>/dev/null | ruby -rjson -e 'puts JSON.parse(STDIN.read)["source"]["http"]' 2>/dev/null || true)
        fi

        if [ -z "$GENAI_URL" ] || [ -z "$GENAIC_URL" ]; then
            echo -e "${RED}❌ Could not resolve download URLs from CocoaPods.${NC}"
            echo -e "${RED}   Set GENAI_URL and GENAIC_URL environment variables manually.${NC}"
            exit 1
        fi
    fi

    echo -e "${GREEN}  GenAI URL:  $GENAI_URL${NC}"
    echo -e "${GREEN}  GenAIC URL: $GENAIC_URL${NC}"
    echo ""
}

# Download and repackage a single GenAI framework for SPM
download_and_repackage() {
    local framework_name=$1
    local url=$2

    echo -e "${YELLOW}📥 Downloading $framework_name...${NC}"

    local temp_dir=$(mktemp -d)
    local tar_file="$temp_dir/${framework_name}.tar.gz"

    curl -sL "$url" -o "$tar_file"

    if [ ! -f "$tar_file" ] || [ ! -s "$tar_file" ]; then
        echo -e "${RED}❌ Failed to download $framework_name${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "  Extracting..."
    tar -xzf "$tar_file" -C "$temp_dir"

    local xcframework_path="$temp_dir/frameworks/${framework_name}.xcframework"
    if [ ! -d "$xcframework_path" ]; then
        echo -e "${RED}❌ XCFramework not found in archive: $xcframework_path${NC}"
        echo "  Archive contents:"
        find "$temp_dir" -maxdepth 3 -type d
        rm -rf "$temp_dir"
        return 1
    fi

    # Add Info.plist files
    echo "  Adding Info.plist files..."
    "$SCRIPT_DIR/add_info_plists.sh" "$xcframework_path" "$framework_name" "$MPP_BUILD_VERSION"

    # Create SPM ZIP archive
    local zip_file="$SPM_OUTPUT_DIR/archives/${framework_name}.xcframework.zip"
    echo "  Creating ZIP archive..."
    cd "$temp_dir/frameworks"
    zip -r -q "$zip_file" "${framework_name}.xcframework"
    cd "$MPP_ROOT_DIR"

    # For GenAIC, also package the static libraries
    if [ "$framework_name" == "MediaPipeTasksGenAIC" ]; then
        local genai_libs_dir="$temp_dir/frameworks/genai_libraries"
        if [ -d "$genai_libs_dir" ]; then
            local libs_zip="$SPM_OUTPUT_DIR/archives/MediaPipeTasksGenAIC_libraries.zip"
            echo "  Packaging GenAIC static libraries..."
            cd "$temp_dir/frameworks"
            zip -r -q "$libs_zip" "genai_libraries"
            cd "$MPP_ROOT_DIR"
            echo -e "${GREEN}  ✅ Packaged GenAIC static libraries${NC}"
        fi
    fi

    rm -rf "$temp_dir"

    if [ -f "$zip_file" ]; then
        local file_size=$(du -h "$zip_file" | cut -f1)
        echo -e "${GREEN}  ✅ Created ZIP: ${framework_name}.xcframework.zip (${file_size})${NC}"

        # Compute checksum
        echo "  Computing checksum..."
        if command -v swift &> /dev/null; then
            local checksum=$(swift package compute-checksum "$zip_file" 2>/dev/null)
            if [ -n "$checksum" ]; then
                echo "$checksum" > "$SPM_OUTPUT_DIR/checksums/${framework_name}.checksum"

                echo "$framework_name:" >> "$CHECKSUM_REPORT"
                echo "  checksum: \"$checksum\"" >> "$CHECKSUM_REPORT"
                echo "  url: \"https://github.com/${GITHUB_REPO}/releases/download/v${MPP_BUILD_VERSION}/${framework_name}.xcframework.zip\"" >> "$CHECKSUM_REPORT"
                echo "" >> "$CHECKSUM_REPORT"

                echo -e "${GREEN}  ✅ Checksum: $checksum${NC}"
            else
                echo -e "${RED}  ❌ Failed to compute checksum${NC}"
            fi
        fi
    else
        echo -e "${RED}  ❌ Failed to create ZIP archive${NC}"
        return 1
    fi
}

resolve_urls

download_and_repackage "MediaPipeTasksGenAIC" "$GENAIC_URL"
download_and_repackage "MediaPipeTasksGenAI" "$GENAI_URL"

echo ""
echo -e "${GREEN}✅ GenAI/GenAIC frameworks downloaded and packaged!${NC}"
echo ""
