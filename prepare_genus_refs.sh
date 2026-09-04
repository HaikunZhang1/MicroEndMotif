#!/bin/bash

set -euo pipefail

########## Prepare genus-level reference genomes ##########

# Project root directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Input genus list
GENUS_FILE="$PROJECT_DIR/data/genusRefName.txt"

# Output directory
REF_DIR="$PROJECT_DIR/refs"

# Kraken2 Standard database (01/12/2024)
K2DB_FILE="$REF_DIR/library_report_K2_standard_20240112.tsv"
K2DB_URL="https://genome-idx.s3.amazonaws.com/kraken/standard_20240112/library_report.tsv"

mkdir -p "REF_DIR"


########## Download Kraken2 library report ##########

if [[ ! -s "$K2DB_FILE" ]]; then
	echo "Downloading Kraken2 Standard database library report (01/12/2024)..."
	wget -c -O "$K2DB_FILE" "$K2DB_URL"
fi


########## Generate reference for each genus ##########

while IFS= read -r GENUS || [[ -n "$GENUS" ]]; do

	# Skip empty lines
	[[ -z "$GENUS" ]] && continue

	echo
	echo "Processing genus: $GENUS"

	GENUS_DIR="$REF_DIR/$GENUS"
	TMP_DIR="$GENUS_DIR/tmp_download"
	URL_FILE="$GENUS_DIR/${GENUS}_genome_urls"
	REF_FASTA="$GENUS_DIR/${GENUS}.fna"
	REF_FASTA_TMP="$GENUS_DIR/${GENUS}.fna.tmp"

	mkdir -p "$GENUS_DIR"


	##### Extract genome URLs #####
	awk -F '\t' -v g="$GENUS" '$1 == "bacteria" && index($2, g) {print $3}' "$K2DB_FILE" | sort -u > "$URL_FILE"
	LINK_NUM=$(wc -l < "URL_FILE")
	echo "$GENUS: $LINK_NUM unique genome links"

	if [[ $LINK_NUM -eq 0 ]]; then
		echo "Warning: no genome links found for $GENUS."
		continue
	fi


	##### Download genome sequences #####
	mkdir -p "$TMP_DIR"
	while IFS= read -r link; do
		wget -c -P "$TMP_DIR" "$link"
	done < "$URL_FILE"


	##### Combine genomes #####
	> "$REF_FASTA_TMP"

	while IFS= read -r file; do
		gzip -cd "$file" >> "$REF_FASTA_TMP"
	done < <(find "$TMP_DIR" -type f -name "*.fna.gz" | sort)

	mv "$REF_FASTA_TMP" "$REF_FASTA"


	##### Remove tmp genome files #####
	rm -rf "$TMP_DIR"

	echo "Reference generated: $REF_FASTA"

done < "$GENUS_FILE"


