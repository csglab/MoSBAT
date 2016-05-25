# MoSBAT
##Motif Similarity Based on Affinity of Targets

Measuring motif similarity is essential for identifying functionally related transcription 
factors (TFs) and RNA-binding proteins (RBPs), and for annotating de novo motifs. Here, 
we describe Motif Similarity Based on Affinity of Targets (MoSBAT), an approach for 
measuring the similarity of motifs by computing their affinity profiles across a large 
number of random sequences. We show that MoSBAT successfully associates de novo ChIP-seq 
motifs with their respective TFs, accurately identifies motifs that are obtained from 
the same TF in different in vitro assays, and quantitatively reflects the similarity of
in vitro binding preferences for pairs of TFs.

## Requirements 
- Unix-compatible OS
- R version 3.0.1 or later (http://www.r-project.org/) 
- R “gplots” library (https://cran.r-project.org/web/packages/gplots/index.html) 

## Installation 
1. To install the program, extract the package
2. Change directory: `cd MoSBAT/` 
3. Make MoSBAT: `make`
3. Generate a large library of random sequences (GC content: 50%): `bash ./src/_seq/_generate.sh > ./src/_seq/sequences.random.txt`
4. To test the pipeline, execute this command: 

>
    bash MoSBAT.sh MyTestJob \
    examples/RNACompete/RNACompete.part1.pfm.txt \
    examples/RNACompete/RNACompete.part1.pfm.txt rna 20 5000
This should create a “./out/MyTestJob” folder, with the MoSBAT output files described above.

## Usage
Use the MoSBAT.sh script to run RCADE on your dataset:
`bash MoSBAT.sh <job_name> <PFM_file_1> <PFM_file_2> <motif_type> <seq_length> <num_seqs>`

**Recommended settings:**

`<seq_length> = 50`
*To have the most accurate similarity score the length should be optimized to the:* 
`<length of motif 1> + <length of motif 2> - 1`

`<num_seqs> = 50000`
MoSBAT-e score variances are relatively stable for anything over 50,000 sequences. When 
using MoSBAT-a with long sequences we recommend >100,000 random sequences