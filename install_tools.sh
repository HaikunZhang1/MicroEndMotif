#!/bin/bash

set -e

# Project root directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Local software environment
ENV_DIR="$PROJECT_DIR/tools/endmotif-env"

# Check whether Conda is available
if ! command -v conda >/dev/null 2>&1; then
    echo "Error: Conda was not found."
    echo "Please install Conda or Miniconda before running this script."
    exit 1
fi

# Create the tools directory
mkdir -p "$PROJECT_DIR/tools"

echo "Installing software environment to:"
echo "$ENV_DIR"

# Create the Conda environment
conda env create \
    --solver=classic \
    --prefix "$ENV_DIR" \
    --file "$PROJECT_DIR/environment.yml"

echo
echo "Installation completed."
echo "Environment location:"
echo "$ENV_DIR"
