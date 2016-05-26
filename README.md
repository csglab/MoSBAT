# MoSBAT

## Motif Similarity Based on Affinity of Targets

Measuring motif similarity is essential for identifying functionally related transcription factors (TFs) and RNA-binding proteins (RBPs), and for annotating de novo motifs. Here, we describe Motif Similarity Based on Affinity of Targets (MoSBAT), an approach for measuring the similarity of motifs by computing their affinity profiles across a large number of random sequences. We show that MoSBAT successfully associates de novo ChIP-seq motifs with their respective TFs, accurately identifies motifs that are obtained from the same TF in different in vitro assays, and quantitatively reflects the similarity of in vitro binding preferences for pairs of TFs. 

## Requirements 
- Unix-compatible OS
- R version 3.0.1 or later [Download](http://www.r-project.org/) 
- R “gplots” library [Download](https://cran.r-project.org/web/packages/gplots/index.html)

## Installation 
1. To install the program, extract the package
2. Change directory: `cd MoSBAT/` 
3. Make MoSBAT: `make`
4. To test the pipeline, execute this command: 

>
    bash MoSBAT.sh MyTestJob \
    examples/RNACompete/RNACompete.part1.pfm.txt \
    examples/RNACompete/RNACompete.part2.pfm.txt rna 20 5000
This should create a “./out/MyTestJob” folder, with the MoSBAT output files described below.

## Running MoSBAT
### Motif File Specifications
To compare your motifs using MoSBAT you will need a CIS-BP formatted position frequency matrix (PFM) file.  Each motif should include the following lines:


1. Identifier `Motif<tab>Motif_ID`
2. Motif Header `Pos<tab>A<tab>C<tab>G<tab>T`
3. Position Frequency Line(s): `PositionNumber<tab>Freq_A<tab>Freq_C<tab>Freq_G<tab>Freq_T`
	- PositionNumber starts at 1
	- Each lines frequencies should sum to 1

**Note:** If the PFM file has more the 1 motif in it, 2 new lines should separate motifs. An example can be downloaded [here](http://mosbat.ccbr.utoronto.ca/MoSBAT_PFMexample.txt), and RNA motif examples are present in `examples/RNACompete`. 

###Usage
Use the MoSBAT.sh script to run RCADE on your dataset:
`bash MoSBAT.sh <job_name> <PFM_file_1> <PFM_file_2> <motif_type> <seq_length> <num_seqs>`

**Recommended settings:**

`<seq_length> = 50` To have the most accurate similarity score the length should be optimized to the: `<length of motif 1> + <length of motif 2> - 1`

`<num_seqs> = 50000` MoSBAT-e score variances are relatively stable for anything over 50,000 sequences. When using MoSBAT-a with long sequences we recommend >100,000 random sequences

## Output
MoSBAT outputs the following files containing all pairwise comparisons of motifs in the first file to the second file:

- **Full Matrix of MoSBAT-a Results** (results.affinity.correl.txt) – Text file containing a matrix of motif similarities based on sequence affinities (MoSBAT-a). Matrix has dimensions: Motif\_Set\_1 *by* Motif\_Set\_2

- **Full Matrix of MoSBAT-e Results** (results.energy.correl.txt) – Text file containing a matrix of motif similarities based on sequence energies (MoSBAT-e). Matrix has dimensions: Motif\_Set\_1 *by* Motif\_Set\_2

For conveince MoSBAT also indentifies the most similar pairs of motifs and their offsets. The outputs are available as heatmaps and browser viewable tables:

- **Heatmap of Top MoSBAT-a Hits** (results.affinity.correl.heatmap.jpg) – Heatmap image displaying at most top 10x10 MoSBAT-a (results.affinity.correl.txt) motif similarity values.

- **Table of Top MoSBAT-a Hits** (results.affinity.correl.htm) – HTML table of the top 1000 pairs of motifs (results.affinity.correl.txt). Includes MoSBAT-a scores, and a histogram of offsets for the top 100 pairs of motifs.

- **Heatmap of Top MoSBAT-e Hits** (results.energy.correl.heatmap.jpg) – Heatmap image displaying at most top 10x10 MoSBAT-e (results.energy.correl.txt) motif similarity values.

- **Table of Top MoSBAT-e Hits** (results.energy.correl.htm) – HTML table of the top 1000 pairs of motifs (results.energy.correl.txt). Includes MoSBAT-a scores, and a histogram of offsets for the top 100 pairs of motifs.

## Advanced Usage Notes
### Using a custom sequence background
Changes to the random sequences MoSBAT uses can be done by editing the `seq_template` value on line **7** of the `MoSBAT.sh` file. To do this change the location from the default random sequence file to your file of DNA sequences (ACGT). Any run of MoSBAT using that bash file will calculate motif similarity using the fist N bases specified by the `<seq_length>` parameter from each of the `<num_seqs>` specified.

### Calculating *p*-values for motif similarities 
MoSBAT does not calculate the signficance of motif similarities but it can be generated using the outputs from the tool. First a large collection of random motifs needs to be created as a background. One way is to generate a large random set of motifs with similar characteristics to your query using the method of Sandelin and Wasserman [(2004)](http://www.ncbi.nlm.nih.gov/pubmed/15066426). The `-genrand` function to make your random set of motifs implemented in the [STAMP](https://github.com/shaunmahony/stamp) toolkit by Mahony, Auron, and Benos [(2007)](http://www.ncbi.nlm.nih.gov/pubmed/17397256) can be used to do this. 

Next run the MoSBAT tool using the background motif collection. For the MoSBAT-a and MoSBAT-e scores calculate the mean and variance of all the scores between the random motifs to create a Gaussian distribution. To calculate the significance of your MoSBAT score take the area under the Gaussian that’s greater than your motif score to obtain the *p*-value. 