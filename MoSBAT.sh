#!/bin/bash

####################### define executables
AffiMx="./bin/AffiMx"
correlate="./src/_R/_correlate.R"
histogram="./src/_R/_histogram.R"
seq_template="./src/_seq/sequences.random.txt"

default_l=100
default_n=20000
rna_db="./src/_motifdb/rna.l"$default_l".n"$default_n
dna_db="./src/_motifdb/dna.l"$default_l".n"$default_n

####################### identify the input arguments
jobid=$1
motif1=$2
motif2=$3
type=$4
length=$5
num=$6

if [ "$jobid" = "" ]; then
	echo -e "\nUsage: bash MoSBAT.sh <jobID> <motif1.pwm> <motif2.pwm> <motif_type> <sequence_length> <sequence_count>\n"
	exit
fi

echo "Job ID: "$jobid
echo "Input file for motif set #1: "$motif1
echo "Input file for motif set #2: "$motif2
echo "Motif type: "$type
echo "Length of sequences for affinity calculations: "$length
echo "Number of sequences for affinity calculations: "$num

if [ "$type" = "rna" ]; then
	echo "Motif type is RNA."
elif [ "$type" = "dna" ]; then
	echo "Motif type is DNA."
else
	echo "ERROR: Motif type was not recognized."
	exit
fi

if [ -e "$motif1" ]; then
	echo "Motif set #1 found."
else
	echo "ERROR: Motif set #1 was not found."
	exit
fi

if [ "$motif2" = "null" ]; then
	echo "Motif set #2 is not provided. Motif set #1 will be compared with the default database."
	length=$default_l
	num=$default_n
	echo "Length of sequences for affinity calculations is set to: "$length
	echo "Number of sequences for affinity calculations is set to : "$num


	if [ "$type" = "rna" ]; then
		if [ -e "$rna_db.affinity.txt" ]; then
			echo "RNA motif database found."
		else
			echo "ERROR: RNA motif database was not found."
			exit
		fi

	else
		if [ -e "$dna_db.affinity.txt" ]; then
			echo "DNA motif database found."
		else
			echo "ERROR: DNA motif database was not found."
			exit
		fi
	fi
elif [ -e "$motif2" ]; then
	echo "Motif set #2 found."
else
	echo "ERROR: Motif set #2 was not found."
	exit
fi

if [ -e "$seq_template" ]; then
	echo "Template sequence file found."
else
	echo "ERROR: Template sequence file was not found."
	exit
fi



####################### define temporary path
tmp_folder="./tmp/"$jobid
mkdir -p $tmp_folder
seq_in=$tmp_folder"/_seq.in.fasta"

####################### prepare the input sequences
# get the first $length nucleotides of the first $num sequences from the template file

echo "Preparing sequences ..."
cat $seq_template | head -n $num | awk -v l=$length '{ printf(">seq_%i\n%s\n",NR,substr($0,1,l)) }' > $seq_in

####################### define the output path
out_folder="./out/"$jobid
mkdir -p $out_folder
mkdir -p $out_folder"/hist"
out_file=$out_folder"/results"

####################### define log files
step1=$out_folder/log.step1.txt
step2=$out_folder/log.step2.txt
step3=$out_folder/log.step3.txt

rm -f $step1
rm -f $step2
rm -f $step3

####################### calculate the affinities
echo "Calculating affinities ..."
if [ "$type" = "rna" ]; then
	$AffiMx -pwm $motif1 -fasta $seq_in -rnd 0 -dir 0 -out $out_file".set1" >$step1	
	if [ "$motif2" = "null" ]; then
		cp $rna_db".affinity.txt" $out_file".set2.affinity.txt"
		cp $rna_db".energy.txt" $out_file".set2.energy.txt"
		cp $rna_db".position.txt" $out_file".set2.position.txt"
	else
		$AffiMx -pwm $motif2 -fasta $seq_in -rnd 0 -dir 0 -out $out_file".set2" >$step2
	fi
else
	$AffiMx -pwm $motif1 -fasta $seq_in -rnd 0 -dir 2 -out $out_file".set1" >$step1
	if [ "$motif2" = "null" ]; then
		cp $dna_db".affinity.txt" $out_file".set2.affinity.txt"
		cp $dna_db".energy.txt" $out_file".set2.energy.txt"
		cp $dna_db".position.txt" $out_file".set2.position.txt"
	else
		$AffiMx -pwm $motif2 -fasta $seq_in -rnd 0 -dir 2 -out $out_file".set2" >$step2
	fi
fi

####################### calculate the correlations
echo "Calculating correlations ..."

echo -n -e "Motif\t" > $out_file".affinity.correl.txt"
echo -n -e "Motif\t" > $out_file".energy.correl.txt"

Rscript $correlate $jobid affinity 2>&1 | sed 's/Error in plot.new() : figure margins too large/Warning in plot.new() : figure margins too large/g' >$step3
Rscript $correlate $jobid energy 2>&1 | sed 's/Error in plot.new() : figure margins too large/Warning in plot.new() : figure margins too large/g' >>$step3



#*****************************************************************************************
# The following lines check the input/output, and produce appropriate messages
# If no error was detected in either input or output, the info messages will be written in
# ./out/<jobID>/log.info.txt
# Otherwise, the error messages will be written in
# ./out/<jobID>/log.error.txt
#*****************************************************************************************

####################### check if step 1 was performed successfully

success=`cat $step1 | grep 'Job finished successfully'`

if [ "$success" = "" ]; then
	err="Something went wrong while calculating affinities for motif set #1. Are the motifs in the correct format?\n"
	err=$err"See the message below:\n"
	err=$err`cat $step1 | grep 'ERROR'`"\n"
else
	numMotifs=`cat $step1 | grep 'motifs were read' | head -n 1 | cut -d ' ' -f1`
	numSeqs=`cat $step1 | grep 'sequences were read' | head -n 1 | cut -d ' ' -f1`
	motifType=`cat $step1 | grep 'The input was interpreted to present' | head -n 1 | cut -d ' ' -f7`
	info="Motif set #1 contains $numMotifs $motifType\n"
	info=$info"$numSeqs sequences were used to calculate the affinity profiles for motif set #1.\n\n"
fi

####################### check if step 2 was performed successfully

if [ "$motif2" = "null" ]; then
	numMotifs=`cat $out_file.set2.affinity.txt | sed 1d | wc -l`
	info=$info"Motif set #1 was compared against $numMotifs in the <$type> database.\n"
else
	success=`cat $step2 | grep 'Job finished successfully'`

	if [ "$success" = "" ]; then
		err="Something went wrong while calculating affinities for motif set #2. Are the motifs in the correct format?\n"
		err=$err"See the message below:\n"
		err=$err`cat $step2 | grep 'ERROR'`"\n"
	else
		numMotifs=`cat $step2 | grep 'motifs were read' | head -n 1 | cut -d ' ' -f1`
		numSeqs=`cat $step2 | grep 'sequences were read' | head -n 1 | cut -d ' ' -f1`
		motifType=`cat $step2 | grep 'The input was interpreted to present' | head -n 1 | cut -d ' ' -f7`
		info=$info"Motif set #2 contains $numMotifs $motifType\n"
		info=$info"$numSeqs sequences were used to calculate the affinity profiles for motif set #2.\n"
	fi
fi

####################### check if step 3 was performed successfully

failure=`cat $step3 | grep 'Error'`

if [ "$failure" = "" ]; then
	info=$info
else
	err="Something went wrong while calculating the correlations between motif set #1 and #2.\n"
	err=$err"See the message below:\n"
	err=$err`cat $step3`"\n"
fi

####################### write the appropriate messages to the output

info=$info"\nJob finished successfully.\n"

echo "Creating HTML outputs ..."

if [ "$err" = "" ]; then
	echo -e -n $info > $out_folder/log.info.txt
	info=`cat $out_folder/log.info.txt | sed '$ d' | while read line; do echo -n -e $line"<br>"; done | sed 's/<br><br>/<br>/g'`
	
	# create HTML output
	cat $out_file".affinity.correl.txt" | awk -f ./src/_awk/convertToTab.awk | sort -r -g -k3 | head -n 100 > $tmp_folder/tophits.affinity.tab
	Rscript $histogram $jobid affinity 2>&1
	cat ./src/_HTML/template.htm | head -n 37 | sed "s/Title_Here/MoSBAT-a results for job # $jobid/g" | sed "s/Info_Here/$info/g" > $out_file".affinity.correl.htm"
	cat $out_file".affinity.correl.txt" | awk -f ./src/_awk/convertToTab.awk | sort -r -g -k3 | head -n 1000 | cat ./src/_motifdb/URLs.table.txt - | awk -f ./src/_awk/convertToHTML.awk -v type=affinity >> $out_file".affinity.correl.htm"
	cat ./src/_HTML/template.htm | tail -n 5 >> $out_file".affinity.correl.htm"

	cat $out_file".energy.correl.txt" | awk -f ./src/_awk/convertToTab.awk | sort -r -g -k3 | head -n 100 > $tmp_folder/tophits.energy.tab
	Rscript $histogram $jobid energy 2>&1
	cat ./src/_HTML/template.htm | head -n 37 | sed "s/Title_Here/MoSBAT-e results for job # $jobid/g" | sed "s/Info_Here/$info/g" > $out_file".energy.correl.htm"
	cat $out_file".energy.correl.txt" | awk -f ./src/_awk/convertToTab.awk | sort -r -g -k3 | head -n 1000 | cat ./src/_motifdb/URLs.table.txt - | awk -f ./src/_awk/convertToHTML.awk -v type=energy >> $out_file".energy.correl.htm"
	cat ./src/_HTML/template.htm | tail -n 5 >> $out_file".energy.correl.htm"
else
	echo -e -n $err > $out_folder/log.error.txt
fi
