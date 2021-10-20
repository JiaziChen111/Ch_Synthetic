#!/bin/bash
# This script generates results, paper and slides for "Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy" by Pavel Solís (pavel.solis@gmail.com), October 2021

dirHOME=`pwd`
dirPAPER=$dirHOME/Docs/Paper
dirSLIDE=$dirHOME/Docs/Slides

cd $dirPAPER
pdflatex paper.tex
#cd $dirSLIDE
#pdflatex slides.tex

# In Terminal
# To make the script executable type: chmod a+x scriptname
# To run the script type: sh file_duplicator.sh