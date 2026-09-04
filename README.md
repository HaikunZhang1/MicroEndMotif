# Microbial end motif analysis

This repository contains scripts for microbial fragment end-motif analysis.


## Software environment

The analysis was performed using:

- SAMtools 1.15.1
- HTSlib 1.15.1
- BEDTools 2.30.0
- Perl 5.30.0

Clone the repository and enter the project directory:

```bash
git clone XXX
cd $microEndMotif
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

