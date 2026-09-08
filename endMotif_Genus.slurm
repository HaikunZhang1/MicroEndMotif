#!/bin/bash

set -euo pipefail

##########  this script is used to obtain fragment end-motif frequencies for all candidate genera  ##########

##########################################################################################
##########################################################################################
# Project root dirctory
PROJECT_DIR="${SLURM_SUBMIT_DIR}"

# Load analysis and SLURM parameters
CONFIG_FILE="$PROJECT_DIR/config.sh"

if [[ ! -f "$CONFIG_FILE" ]]; then
	echo "Error: configuration file not found: $CONFIG_FILE"
	exit 1
fi

source "$CONFIG_FILE"

# Software 
ENV_DIR="$PROJECT_DIR/tools/endmotif-env"
SAMTOOLS="$ENV_DIR/bin/samtools"
BEDTOOLS="$ENV_DIR/bin/bedtools"
PERL="$ENV_DIR/bin/perl"

# Project directories and files
OUTPUT_DIR="$PROJECT_DIR/results"
MICRO_ALIGN_DIR="$PROJECT_DIR/data"
GENUS_REF_DIR="$PROJECT_DIR/refs"
GENUS_FILE="$PROJECT_DIR/data/genusRefName.txt"

cd "$PROJECT_DIR" || exit 1


#############################  end motif for each genus  #############################
while IFS= read Genus || [[ -n "$Genus" ]]; do

	# Skip empty lines
	[[ -z "$Genus" ]] && continue

	echo "Processing genus: $Genus"
	Dir="$OUTPUT_DIR/$Genus"

	# Create output directories
	mkdir -p \
		$Dir/bedFiles \
	  	$Dir/endMotif \
	      $Dir/jobScripts \
	      $Dir/logs

	# Get sample names from CRAM files
	find "$MICRO_ALIGN_DIR/$Genus" \
		-maxdepth 1 \
		-type f \
		-name "*.cram" \
		-printf "%f\n" |             # Print file names only
		sed 's/\.cram$//' \
		> "$Dir/sampleName.txt"


	#####  Get end motifs for a specific genus  #####
	for file in `cat $Dir/sampleName.txt`;do
		echo -e '#!/bin/bash' > $Dir/jobScripts/$file.slurm;
	done
	for file in `cat $Dir/sampleName.txt`;do
      	echo -e "#\n\
#SBATCH -p $SAMPLE_PARTITION\n\
#SBATCH -N 1\n\
#SBATCH -n $SAMPLE_CPUS\n\
#SBATCH --mem $SAMPLE_MEMORY\n\
#SBATCH -t $SAMPLE_TIME\n\
#SBATCH -o $Dir/logs/endMotif.$file.log\n\
#SBATCH --job-name=endMotif.$file\n\
set -euo pipefail\n\
\n\
cd $Dir

##########  Microbial end-motif analysis
## extract xx-mer motifs and calculate motif frequencies
$SAMTOOLS collate -@ $SAMPLE_CPUS -uO $MICRO_ALIGN_DIR/$Genus/$file.cram $Dir/bedFiles/samCollate.$file | \\
      $SAMTOOLS view -T $GENUS_REF_DIR/$Genus/$Genus.fna -bh | \\
      $BEDTOOLS bamtobed -i stdin | \\
      $BEDTOOLS getfasta -fi $GENUS_REF_DIR/$Genus/$Genus.fna -bed - -bedOut > $Dir/bedFiles/$file.seq.bed
$PERL $PROJECT_DIR/scripts/endMotifFromBed.pl $Dir/bedFiles/$file.seq.bed $Genus $MER $Dir/endMotif/$file.endMotifR1.txt $Dir/endMotif/$file.endMotifR2.txt $Dir/endMotif/$file.endMotifR1R2.txt

## normalize by background
$PERL $PROJECT_DIR/scripts/GenomeMotif_alignedAll.pl $Dir/bedFiles/$file.seq.bed $GENUS_REF_DIR/$Genus/$Genus.fna $Genus $MER $Dir/endMotif/GenomeMotif_${Genus}_${MER}mer.$file.txt    # generate motif frequencies of aligned references

$PERL $PROJECT_DIR/scripts/EndFreqNorm.pl $Dir/endMotif/$file.endMotifR1.txt $Dir/endMotif/GenomeMotif_${Genus}_${MER}mer.$file.txt $Dir/endMotif/$file.endMotifR1Norm.txt
$PERL $PROJECT_DIR/scripts/EndFreqNorm.pl $Dir/endMotif/$file.endMotifR2.txt $Dir/endMotif/GenomeMotif_${Genus}_${MER}mer.$file.txt $Dir/endMotif/$file.endMotifR2Norm.txt

rm $Dir/endMotif/$file.endMotifR1.txt $Dir/endMotif/$file.endMotifR2.txt $Dir/endMotif/$file.endMotifR1R2.txt $Dir/endMotif/GenomeMotif_${Genus}_${MER}mer.$file.txt" >> $Dir/jobScripts/$file.slurm;
	done


	#####  run jobs  #####
	cd $Dir/jobScripts || exit
		for i in `ls *.slurm`; do sbatch --wait $i &
	done
	wait
done < "$GENUS_FILE"
