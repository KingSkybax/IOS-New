#!/bin/bash -e -o pipefail
source ~/utils/utils.sh

# Retrieve the CLI version of the latest CodeQL bundle.
download_with_retries https://raw.githubusercontent.com/github/codeql-action/v2/src/defaults.json "/tmp" "codeql-defaults.json"
bundle_version="$(jq -r '.cliVersion' /tmp/codeql-defaults.json)"
bundle_tag_name="codeql-bundle-v$bundle_version"

echo "Downloading CodeQL bundle $bundle_version..."
# Note that this is the all-platforms CodeQL bundle, to support scenarios where customers run
# different operating systems within containers.
download_with_retries "https://github.com/github/codeql-action/releases/download/$bundle_tag_name/codeql-bundle.tar.gz" "/tmp" "codeql-bundle.tar.gz"
codeql_archive="/tmp/codeql-bundle.tar.gz"

codeql_toolcache_path="$AGENT_TOOLSDIRECTORY/CodeQL/$bundle_version/x64"
mkdir -p "$codeql_toolcache_path"

echo "Unpacking the downloaded CodeQL bundle archive..."
tar -xzf "$codeql_archive" -C "$codeql_toolcache_path"

# Touch a file to indicate to the CodeQL Action that this bundle shipped with the toolcache. This is
# to support overriding the CodeQL version specified in defaults.json on GitHub Enterprise.
touch "$codeql_toolcache_path/pinned-version"

# Touch a file to indicate to the toolcache that setting up CodeQL is complete.
touch "$codeql_toolcache_path.complete"

invoke_tests "Common" "CodeQL Bundle"
