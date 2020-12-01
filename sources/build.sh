#!/bin/sh
#source env/bin/activate
set -e

thisFont="Brygada1918"  #must match the name in the font file
VF_DIR=./fonts/variable
TT_DIR=./fonts/ttf
OT_DIR=./fonts/otf

#Generating fonts ==========================================================
#Requires fontmake https://github.com/googlefonts/fontmake

echo ".
GENERATING VARIABLE
."
rm -rf $VF_DIR
mkdir -p $VF_DIR

fontmake -g ./sources/$thisFont.glyphs -o variable --output-path $VF_DIR/$thisFont[wght].ttf

echo ".
GENERATING STATICS
."
rm -rf $TT_DIR $OT_DIR
mkdir -p $TT_DIR $OT_DIR

fontmake -g ./sources/$thisFont.glyphs -i -o ttf --output-dir $TT_DIR
fontmake -g ./sources/$thisFont.glyphs -i -o otf --output-dir $OT_DIR

rm -rf ./master_ufo/ ./instance_ufo/

#Post-processing fonts ======================================================
#Requires gftools https://github.com/googlefonts/gftools

echo ".
POST-PROCESSING VF
."
vfs=$(ls $VF_DIR/*.ttf)
for font in $vfs
do
	gftools fix-dsig --autofix $font
	gftools fix-nonhinting $font $font.fix
	mv $font.fix $font
	gftools fix-unwanted-tables --tables MVAR $font
done
rm $VF_DIR/*gasp*

gftools fix-vf-meta $VF_DIR/$thisFont[wght].ttf
for font in $vfs
do
	mv $font.fix $font
done

echo ".
POST-PROCESSING TTF
."
ttfs=$(ls $TT_DIR/*.ttf)
for font in $ttfs
do
	gftools fix-dsig --autofix $font
	python -m ttfautohint $font $font.fix
	[ -f $font.fix ] && mv $font.fix $font
	gftools fix-hinting $font
	[ -f $font.fix ] && mv $font.fix $font
done

echo ".
POST-PROCESSING OTF
."
otfs=$(ls $OT_DIR/*.otf)
for font in $otfs
do
	gftools fix-dsig --autofix $font
done


echo ".
COMPLETE!
."
