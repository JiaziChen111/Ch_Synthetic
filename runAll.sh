#!/bin/bash
# This script generates the results, the paper and the slides for "Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy" by Pavel Solís (pavel.solis@gmail.com), October 2021. To run it, go to the directory where this script is located (e.g., in the terminal type `cd Documents/Ch_Synt`) and type `sh runAll.sh`

dirHOME=`pwd`

cd $dirHOME/Codes/Pre-Analysis
matlab -batch "read_data"

cd $dirHOME/Codes/Analysis
matlab -batch "ts_analysis"
nohup stata -b do spillovers &

cd $dirHOME/Docs/Paper
pdflatex paper.tex

cd $dirHOME/Docs/Slides
pdflatex slides.tex

