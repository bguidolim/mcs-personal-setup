#!/bin/bash
# Configure Xcode project — creates .xcodebuildmcp/config.yaml
# Environment variables provided by mcs:
#   MCS_PROJECT_PATH — absolute path to the project root
#   MCS_RESOLVED_PROJECT — resolved Xcode project/workspace file name

set -euo pipefail

project_path="${MCS_PROJECT_PATH:?MCS_PROJECT_PATH not set}"
project_file="${MCS_RESOLVED_PROJECT:-}"

if [ -z "$project_file" ]; then
    echo "No Xcode project selected — skipping .xcodebuildmcp configuration"
    exit 0
fi

config_dir="$project_path/.xcodebuildmcp"
config_file="$config_dir/config.yaml"

mkdir -p "$config_dir"

cat > "$config_file" << EOF
schemaVersion: 1
enabledWorkflows:
  - simulator
  - ui-automation
  - project-discovery
  - utilities
  - session-management
  - debugging
  - logging
  - doctor
  - workflow-discovery
sessionDefaults:
  projectPath: ./$project_file
  suppressWarnings: false
  platform: iOS
EOF

echo "Created $config_file for $project_file"
