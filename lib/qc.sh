#! /bin/bash

## Global Vars
INPUT_DIR=$1

# convert_biom.py -i rarefaction_500_90.biom -o rarefaction_500_90.txt -b

files=$(ls $INPUT_DIR)

for f in $files
do
	output="${f/.biom/.txt}"
	echo convert_biom.py -i $INPUT_DIR/$f -o $INPUT_DIR/$output -b
	convert_biom.py -i $INPUT_DIR/$f -o $INPUT_DIR/$output -b
done
