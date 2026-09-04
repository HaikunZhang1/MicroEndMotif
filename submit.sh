#!/bin/bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_DIR/config.sh"

cd "$PROJECT_DIR"

sbatch \
	--partition="$MAIN_PARTITION" \
	--nodes=1 \
	--cpus-per-task="$MAIN_CPUS" \
    --mem="$MAIN_MEMORY" \
    --time="$MAIN_TIME" \
    --job-name=endMotif_Genus \
    --output="$PROJECT_DIR/endMotif_Genus.log" \
    "$PROJECT_DIR/endMotif_Genus.slurm"
