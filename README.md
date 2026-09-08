# Microbial end motif analysis

This repository contains scripts for microbial fragment end-motif analysis.

This is a SLURM-based high-performance computing (HPC) workflow

The workflow starts from pre-generated genus-specific CRAM files and calculated normalized fragment end-motif O/E ratios using the corresponding genus-level reference genomes.


## Input data

Genus-specific CRAM files are used as the input to this workflow.

In the original analysis, microbial reads (.fq) assigned to each candidate genus were aligned to the corresponding genus-level reference genome using BWA-MEM. The resulting alignments were processed with SAMtools and stored as indexed CRAM files.

The CRAM-generation step is not included in this repository.


## Software environment

The analysis was performed using:

- SAMtools 1.15.1
- HTSlib 1.15.1
- BEDTools 2.30.0
- Perl 5.30.0

Clone the repository and enter the project directory:

```bash
git clone https://github.com/HaikunZhang1/microEndMotif.git
cd microEndMotif
```
Install all required software into the local `tools/` directory:

```bash
bash install_tools.sh
```

The environment will be installed under:

```text
tools/
```

## Reference genomes

Genus-level reference genomes are generated from the Kraken2 Standard database (01/12/2024)

Specify the genera to be analyzed in: 

```text
data/genusRefName.txt
```
with one genus per line.

Generate the reference genomes using:

```bash
bash prepare_genus_refs.sh
```

The generated references will be stored under: 

```text
refs/<Genus>/<Genus>.fna
```


## Run the analysis

Before running the analysis, modify the parameters in `config.sh` according to your analysis and local SLURM configuration.

Run the workflow from the project root directory: 

```bash
bash submit.sh
```

The submission script loads parameters from `config.sh` and submits:

```text
endMotif_Genus.slurm
```


## Output

Results are written to `results/<Genus>/`.

The main output directories are:

- `bedFiles/`: intermediate BED files containing genomic coordinates and extracted fragment sequences.
- `endMotif/`: normalized fragment end-motif results.

For each sample, two main output files are generated:

- `endMotif/<sample>.endMotifR1Norm.txt`: 5' end-motif O/E ratios (normalized frequencies)
- `endMotif/<sample>.endMotifR2Norm.txt`: 3' end-motif O/E ratios (normalized frequencies)

Each file contains the following columns:

`GenomeName`, `Motif`, `EndFreq`, `GenomeFreq`, and `EndFreqNorm`

where:

- `GenomeName`: genus name
- `Motif`: end motif
- `EndFreq`: observed end-motif frequency in microbial cfDNA
- `GenomeFreq`: expected motif frequency in the corresponding reference genome
- `EndFreqNorm`: observed/expected (O/E) ratio, calculated as `EndFreq / GenomeFreq`

An example output is shown below:

```text
GenomeName	Motif	EndFreq	GenomeFreq	EndFreqNorm
Staphylococcus	A	0.394736842105263	0.333942857122864	1.18204906523882
Staphylococcus	C	0.190058479532164	0.166057142877136	1.14453661094715
Staphylococcus	G	0.116959064327485	0.166057142877136	0.70433022212132
Staphylococcus	T	0.298245614035088	0.333942857122864	0.893103738180445
```