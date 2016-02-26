# Genome assembly

This data set is part of the [*Polistes dominula* genome project][pdomproj], and details the assembly of the *P. dominula* genome, as described in ([Standage *et al.*, *Molecular Ecology*, 2016][ref]).
Included in this data set is the final genome assembly itself, as well as documentation providing complete disclosure of the assembly procedure.

## Synopsis

Whole genome shotgun reads were processed using [Trimmomatic][] version [0.22][] to remove adapter contamination and low-confidence base calls.
The processed reads were then assembled using [AllPaths-LG][] version [43216][].

## Data access

Raw Illumina data is available from the NCBI Sequence Read Archive under the accession number [SAMN02584905][sra].
The `GetGenomeSRA.make` script automates the process of downloading these data files and converting them from SRA format to Fastq format.
This script in turn depends on the `fastq-dump` command included in the [SRA toolkit][sratk] binary distribution.

```bash
./GetGenomeSRA.make
```

## Procedure

### Short read quality control

First, we designated the number of processors available, and provided the path of the `trimmomatic-0.22.jar` file distributed with the Trimmomatic source code distribution.

```bash
NumProcs=16
TrimJar=/usr/local/src/Trimmomatic-0.22/trimmomatic-0.22.jar
```

We then applied the following filters to each read pair (see `run-trim.sh` for details).

  - remove adapter contamination
  - remove any nucleotides at either end of the read whose quality score is below 3
  - trim the read once the average quality in a 5bp sliding window falls below 20
  - discard any reads which, after processing, fall below the length threshold (40bp for 100bp reads, 26bp for 35bp reads)

```bash
for sample in 200bp 500bp 1kb 3kb 8kb
do
  ./run-trim.sh $sample $TrimJar $NumProcs
done
```

### Assembly with AllPaths-LG

Next, we prepared a working directory for the assembly and converted the input files into the internal format required by AllPaths-LG.
Note: you may need to edit the `in_groups.csv` file to provide the full paths of the input Fastq files.

```bash
mkdir -p assembly/Polistes_dominula/data-trim
PrepareAllPathsInputs.pl \
      DATA_DIR=assembly/Polistes_dominula/data-trim \
      PLOIDY=2
```

Then, we executed the assembly procedure.

```bash
RunAllPathsLG PRE=assembly \
              REFERENCE_NAME=Polistes_dominula \
              DATA_SUBDIR=data-trim \
              RUN=run01 \
              TARGETS=standard \
              THREADS=$NumProcs
```

Finally, we assigned official project IDs to the scaffolds.

```bash
./scaff-ids.pl PdomSCFr1.2- \
    < $PRE/Polistes_dominula/data-trim/run01/ASSEMBLIES/test/final.assembly.fasta \
    > pdom-scaffolds-unmasked-r1.2.fa
```

------

[![Creative Commons License](https://i.creativecommons.org/l/by/4.0/88x31.png)][ccby4]  
This work is licensed under a [Creative Commons Attribution 4.0 International License][ccby4].


[pdomproj]: https://github.com/PdomGenomeProject
[ref]: http://dx.doi.org/10.1111/mec.13578
[Trimmomatic]: http://www.usadellab.org/cms/index.php?page=trimmomatic
[0.22]: http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.22.zip
[AllPaths-LG]: http://www.broadinstitute.org/scientific-community/science/programs/genome-sequencing-and-analysis/computational-rd/computational-
[43216]: http://bit.ly/1BkRxwD
[sra]: http://www.ncbi.nlm.nih.gov/sra/?term=SAMN02584905
[sratk]: http://www.ncbi.nlm.nih.gov/Traces/sra/?view=software
[ccby4]: http://creativecommons.org/licenses/by/4.0/
