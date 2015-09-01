#!/bin/bash

# gawk is required: sudo apt-get install gawk

usage () {
    echo "usage: $0 -i <input directory>"
}

echo "Starting with methylation pattern analysis"

#Filerting of parameters
while getopts ":hi:" option; do
    case "$option" in
	h) usage
	   exit 0;;
	i) INDIR=${OPTARG} ;;
	?) echo "Error: unknown option $OPTARG"
	   usage
	   exit 1;;
    esac
done

HOMEDIR="/home/app/tabsat/tools/MethylSubpop"
TARGET="${HOMEDIR}/target.txt"
OUTDIR="${INDIR}/Output"

echo "Output will be saved in $OUTDIR"
mkdir -p $OUTDIR

#evaluation of each .sam file: 1) whole targets 2)first & last methylated position in each target
for file in $INDIR/*.sam
		do
			current="$(basename "$file" trimmed.fastq_bismark_tmap.sam)"			
			echo "Whole Target for $file"
			perl $HOMEDIR/MethylPattern.pl $TARGET ${file} > $OUTDIR/$current'WholeTarget.txt'
			echo "Intermediate Positions for $file"
			perl $HOMEDIR/FindMethylPositions.pl $OUTDIR/$current'WholeTarget.txt' > $OUTDIR/$current'MethylPositionsIntermediate.txt'
			echo "Paste intermediate Positions for $file"
			paste -d" " $TARGET $OUTDIR/$current'MethylPositionsIntermediate.txt' | while read from to; do echo "${from}" "${to}"; done > $OUTDIR/$current'IntermedTarget.txt' #creates extended target file
			echo "Intermediate Subpops for $file"
			perl $HOMEDIR/FindMethylSubpopulations.pl $OUTDIR/$current'IntermedTarget.txt' ${file} > $OUTDIR/$current'IntermediateSubpop.txt'
			echo "Final Positions for $file"
			perl $HOMEDIR/FindMethylPositions.pl $OUTDIR/$current'IntermediateSubpop.txt' > $OUTDIR/$current'MethylPositionsFinal.txt'	#repeating of the former step in order to localize first and last methylation step
			echo "Paste final Positions for $file"
			paste -d" " $TARGET $OUTDIR/$current'MethylPositionsFinal.txt' | while read from to; do echo "${from}" "${to}"; done > $OUTDIR/$current'FinalTarget.txt' #creates extended target file
			echo "Final Subpops for $file"	
			perl $HOMEDIR/FindMethylSubpopulations.pl $OUTDIR/$current'FinalTarget.txt' ${file} > $OUTDIR/$current'FinalSubpop.txt'
		done

rm -f $OUTDIR/*Intermed*

#comparision and ranking of the subpopulations in all samples 
echo "Comparision of first and last methylation positions in all samples"
paste -d" " $OUTDIR/*MethylPositionsFinal.txt | while read from to; do echo "${from}" "${to}"; done | sed 's/FIRST=0//g;s/LAST=0//g' > $OUTDIR/'ValidPositions.txt'
perl $HOMEDIR/FindRankingPositions.pl $OUTDIR/ValidPositions.txt > $OUTDIR/MinMaxValidPositions.txt	#finds the lowest common factor of the methylation position in all samples
paste -d" " $TARGET $OUTDIR/MinMaxValidPositions.txt | while read from to; do echo "${from}" "${to}"; done > $OUTDIR/RankingPositions.txt
echo "Finding methylation subpopulations"
perl $HOMEDIR/ComparisionSubpop.pl $INDIR/ $OUTDIR/RankingPositions.txt  |
gawk '
   BEGIN {PROCINFO["sorted_in"] = "@val_num_desc"} 
    function output_table() {
        for (key in table) print table[key]
        delete table
	i=0
    }
    /Target/ {print; getline; print; next} 
    /^$/ {output_table(); print; next} 
    {table[++i] = $0} 
   END {output_table()}
' /dev/stdin > $OUTDIR/SampleComparision.txt #gawk just for ordering the results
echo "Done with workflow"
