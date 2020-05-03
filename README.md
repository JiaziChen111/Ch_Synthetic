# Ch_Synthetic

The files in this folder are provided to facilitate the replication of the results in "Term Premia in Emerging Markets" by Pavel Solís
Alternative title: International Bond Risk Premia Implications of Deviations from Covered Interest Rate Parity.


## SYSTEM FEATURES
-------------------------------------------------------------------------------------
The results in the paper were generated using the following:
- Operating system: macOS 10.14.6
- Software: Matlab R2019b, Stata 15
- Add-ons. Matlab: Financial Toolbox. Stata: regsave, texsave.
- Restricted data sources: Bloomberg, Refinitv
- Expected running time: Pre-Analysis (XX min/hr), only if replicated from scratch (i.e. using data directly downloaded from Bloomberg and Refinitv); Analysis (XX min/hr)


## CONTENTS OF THE MAIN FOLDER
-------------------------------------------------------------------------------------
README.txt (this file)

doAll.sh: generates results, paper and slides

Codes folder: 
- runCodes.EXT: executes the codes that generate the results
- Pre-Analysis folder: codes for cleaning and preparing the data
- Analysis folder: runAppendix.EXT and replication codes

Data folder: 
- Analytic folder
- Raw folder
- Temp folder

Docs folder: 
- Paper folder
- Slides folder
- Equations folder
- Figures folder
- Tables folder
- DataStats folder: descriptive statistics of the variables used
- Settings folder: .tex files with settings for the paper and the slides
- References folder: .bib file with cited references
- Temp folder


## DATA FILES
-------------------------------------------------------------------------------------
See the metadata guide (Data -> Metadata -> MetadataGuide.docx) for a description of the data files (e.g. date accessed, how to obtain a copy, list of variables, sample period).

The results can be replicated using the data contained in the MAT-file (Data -> Analytic -> datasets.mat). This file constructs the necessary variables for the analysis using the data dowloaded from Bloomberg and Datastream, which is not included in the replication folder due to licensing rights. However, the dataset can be recreated from scratch and, subsequently, updated if you have access to those data sources. See the metadata guide for instructions on how to recreate or update each of the following:
- Tickers documented in AE_EM_Curves_Tickers.xlsx (Bloomberg and Datastream)
- Tickers documented in Macro_Finance_Tickers.xlsx (Bloomberg)
- US yield curve from Gürkaynak, Sack & Wright (2007)
- US term premium from Adrian, Crump & Moench (2013)
- Uncertainty indexes from Baker, Bloom & Davis (2016)


## INSTRUCTIONS TO REPLICATE THE STUDY
-------------------------------------------------------------------------------------
Open doAll.sh. This file calls runCodes.EXT (Codes -> runCodes.EXT) to reproduce the results (figures and tables), paper.tex (Docs -> Paper -> paper.tex) and slides.tex (Docs -> Slides -> slides.tex) to generate the latest versions of the paper and the slides. Before executing doAll.sh choose the option that you want to execute: with access to Bloomberg and DataStream data or with no access to them. See below on how to update the data. If you don't want to or can't execute doAll.sh, you can replicate the results by manually executing runCodes.EXT and then (in any order) executing paper.tex and/or slides.tex.

What do runCodes.EXT, paper.tex and slides.tex do?
Stratification (dividing into small components) avoids repeating code or duplicating files (e.g. equations, figures and tables used in both the paper and the slides) and allows one to focus on specific parts. This also has advantages in development and testing, as well as facilitating collaboration. The downside is that it may be difficult to follow the order of the codes and files. Master files solve this issue by calling the necessary files in the required order.
- runCodes.EXT: run codes sequentially to clean the data, perform the analysis and generate the results (figures and tables). See below if you want to follow the workflow of the codes.
- paper.tex: call abstract.tex, sections.tex and appendix.tex (the last two call equations, figures and tables).
- slides.tex: call title_slide.tex as well as equations, figures and tables.

Commands that generate specific results in the paper are indicated with comments in the code. Below is a list of results reported in the paper that are replicated:
1. Figure 3
1. Table 2, column 4
1. The simulation reported in section 4.3
1. The income elasticity of demand for beef (1.86) reported on page 58 of the paper


## FINAL COMMENTS
-------------------------------------------------------------------------------------
If you add or modify the files in the main folder, keep in mind that the names of files and folders must have *no* spaces.

The paths in the codes for opening and/or saving files are relative to the folder in which the file is located. Therefore, the codes work regardless of where the main folder is located. However, the relative paths rely on the structure of the main folder as provided.

The paths of directories are defined using the Unix convention (i.e. forward slash). Keep in mind that Windows systems use a backslash and so, an error may appear if the files are executed in a Windows machine. The user would just need to modify the codes where appropriate. This should only happen with executable .sh and .do files because the codes in Matlab were written to be independent of the platform used.

On reproducibility of empirical research, see:
- TIER protocol (http://www.projecttier.org/tier-protocol/)
- Gentzkow & Shapiro, 2014. Code and Data for the Social Sciences: A Practitioner’s Guide
- Chang & Li, 2017. A Pre-analysis Plan to Replicate Sixty Economics Research Papers That Worked Half of the Time


## CODE WORKFLOW (OPTIONAL)
-------------------------------------------------------------------------------------
All information is stored in a Matlab structure array of countries with different fields. The information in the key fields (including lccs, tp, syn, nom) is stored as a timetable (a Matlab data type). Below are the details to facilitate following the workflow of the codes.

In pre-analysis folder

	run read_data.m 		-> generates dataset_daily (takes ~ 73 min)
	read_data.m calls: read_platforms, read_usyc, fwd_prm, spreads, read_cip, plot_spreads, compare_cip, append_dataset, iso2names

In analysis folder

	run rp_analysis.m		-> once using 'LCRF' and once using 'LC'

	+run fit_NS.m 		-> default-free LC YCs (11 min or 15 if 4 initial values)
	+run rp_estimation.m	-> estimates risk premia (seconds)
	+run rp_plot.m		-> plots risk premia (seconds)
	run rp_us.m		-> US TP (seconds) may require internet access
	+run rp_correlations	-> EMs TPs with US TP, EPU (seconds)
		run read_epu_idx.m -> loads EPU indexes (seconds)
	+run rp_common_factors	-> common factors for orthogonal part of EMs TPs
		run read_macro_vars.m 	-> load macro data (seconds)

	run rp_regressions.m	-> correlations

*Ideal*: master file (rp_analysis) that calls functions fit_NS, rp_estimation, rp_plot
give dataset (rf or risky) and special_cases (rf or risky) to fit_NS and get dataset_lcRF or dataset_lcRK
give dataset_lcXX to rp_estimation and get dataset_monthly, header_monthly, statistics
merge both datasets
plot rf and risky

'dataset_daily' contains yield curves (LC, FC, US), cross-currency swaps, credit spreads (LC, FC, LC-US) for different maturities with DAILY frequency. All series run top-down from first day of sample to the most recent one, series were appended to the RIGHT. Countries are identified using (filtering in) header_daily

'dataset_monthly' contains synthetic LC yield curves, expected short rates, risk premia, LCCS for different maturities with MONTHLY frequency. Series run top-down form the first available date per country to the most recent one, series were appended BELOW (since series start at different times). Countries are identified using (filtering in) dataset_monthly





## COMPATIBILITY
-------------------------------------------------------------------------------------
The data types 'table' and 'categorical arrays' were introduced in Matlab 8.2 (R2013b). This code makes heavy use of those data types as well as of functions for tables introduced in R2016b (e.g. synchronize).



## DELETE
-------------------------------------------------------------------------------------
Files read_tickers and read_tickers_v2 were originally in Ch_X/Codes/Pre-Analysis. The first one read the Excel file with headers and in rectangle cell array (many zeros). The second one read without headers, also in a rectangle cell array, designed to extract tickers from column 3. v3 version stacks all sheets into one cell array. v4 version will do what v3 does but allowing for headers (i.e. extra first row, which is necessary to match the extra first column in dataB for the date once transposed)

Next:
retrieve_blp_data.m change line 11 to stacked(2:end,3); to reflect stacked with headers
modify read_tickers_v3 to allow for stacked to have headers
the objective is for the filters in test.m to have the extra first entry considering the date column in dataB
retrieve_blp_data took 15 min


Process or Cycle: Download data + Metadata Guide + Codes to process data + Data appendix

Cycle:
Codes for analysis/results + Paper

[When finished?] Paste library.bib in References folder and uncomment line for reading it from that folder

The paper and the slides have this line \usepackage{'XXX'}. Paste the files that will be used by many files there so that no need to have a copy every time (e.g. macros). Download the package from www.github.com and paste it in Library -> texmf -> tex -> latex. Check the link stackexchange to ensure you have the structure of the texmf folder.



## VBA CODE
-------------------------------------------------------------------------------------

Sub StackTckrMtrx()
'
' StackTckrMtrx Macro
' Copy and paste columns or matrices from several sheets vertically
'
' Run it while the WB containing the tickers or matrices is open
' Assumes WS 4 is first WS of interest and discards last WS
' For tickers: Assumes column starts in C2 in all sheets
' For matrices: Assumes first row is A2:G2 in all sheets
' Assumes there are no blank cells vertically in the (first) column
' Originally created to stack the (matrices of identifiers for) tickers extracted from Bloomberg
'
    Dim WBtick As Workbook
    Dim WBnew As Workbook
    Dim WS_Count As Integer
    Dim I As Integer
    Dim lRow As Long
    
'   Capture current workbook
    Set WBtick = ActiveWorkbook
    
'   Set WS_Count equal to the number of worksheets in the active workbook minus last one (FX)
    WS_Count = ActiveWorkbook.Worksheets.Count - 1
    
'   Open new workbook
    Workbooks.Add
    
'   Capture new workbook
    Set WBnew = ActiveWorkbook
    
'   Begin the loop at the fourth worksheet (USD)
    For I = 4 To WS_Count
    
'   Go back to original workbook
    WBtick.Activate
    ActiveWorkbook.Worksheets(I).Select
    
'   Copy tickers
'    Range("C2").Select          ' To stack column of tickers
    Range("A2:G2").Select     ' To stack matrices
    Range(Selection, Selection.End(xlDown)).Select
    Selection.Copy
    Range("A1").Select ' Just for cleaning purposes
    
'   Go back to new workbook
    WBnew.Activate
    Sheets(1).Select
    
'   Find the last non-blank cell in column A(1)
    lRow = Cells(Rows.Count, 1).End(xlUp).Row
 
'   Paste data in next blank row of column A
    ActiveSheet.Cells(lRow + 1, 1).Select
    ActiveSheet.Paste
    Application.CutCopyMode = False
    Next I ' End of for-loop

'   Keep everything clean
    Range("A1").Select
    WBtick.Activate
    ActiveWorkbook.Worksheets(1).Select
    WBnew.Activate
End Sub


## WEBPAGES
-------------------------------------------------------------------------------------

Toolkit on Econometrics and Economics Teaching
https://www.mathworks.com/matlabcentral/fileexchange/32601-toolkit-on-econometrics-and-economics-teaching?focused=5197862&tab=function&s_tid=gn_loc_drop

Matlab Financial toolbox functions: zbtyield (Zero curve bootstrapping), pyld2zero, zero2disc, Creating an IRFunctionCurve Object, Pricing and Computing Yields for Fixed-Income Securities, Multilevel Mixed-Effects Modeling Using MATLAB

Wikipedia: Errors and residuals, 

Toodledo, Econometrics Academy, Nick HK R videos,


StackExchange
- Why is OLS estimator of AR(1) coefficient biased?
https://stats.stackexchange.com/questions/240383/why-is-ols-estimator-of-ar1-coefficient-biased

- How the Ornstein–Uhlenbeck process can be considered as the continuous-time analogue of the discrete-time AR(1) process?
https://math.stackexchange.com/questions/345773/how-the-ornstein-uhlenbeck-process-can-be-considered-as-the-continuous-time-anal

- Geometric brownian motion vs. Ornstein Uhlenbeck
https://quant.stackexchange.com/questions/22861/geometric-brownian-motion-vs-ornstein-uhlenbeck

Youtube
- An Introduction to Factor Modelling
https://www.youtube.com/watch?v=Qr7WvELSJUA&feature=youtu.be
- Economics 421/521 - Econometrics - Winter 2011 - Lecture 5
- Economics 421 Online Ch 10 - Part 1


Papers
- Risk Premia in Gold Leasing Markets by Anh Le & Haoxiang Zhu (for summary of EH)
https://editorialexpress.com/cgi-bin/conference/download.cgi?db_name=AFA2014&paper_id=1352

- Market volatility, monetary policy and the term premium by Mallick, Mohanty & Zampolli
https://www.bis.org/publ/work606.pdf
Important for kind of things that can be done once having estimated term premium (link: volatility, MP and TP)

- Should We Fear Derivatives? by Stulz in JEP
https://cpb-us-w2.wpmucdn.com/u.osu.edu/dist/0/30211/files/2017/01/Should_We_Fear_Derivatives-1gxewdt.pdf

- The Excess Sensitivity of Long-Term Rates: A Tale of Two Frequencies
https://www.newyorkfed.org/medialibrary/media/research/staff_reports/sr810.pdf?la=en

Adrien Verdelhan
http://web.mit.edu/adrienv/www/Research.html

Bloomberg terminals and data limits
https://lam.library.ubc.ca/news/2017/05/17/bloomberg-terminals-and-data-limits-at-sauder/

Lectures:

- Lecture on VAR by Rossi
http://economia.unipv.it/pagp/pagine_personali/erossi/rossi_VAR_PhD.pdf

- Intro to Sampling Methods
http://www.cse.psu.edu/~rtc12/CSE586/lectures/cse586samplingPreMCMC.pdf

- Bond Valuation Using Microsoft Excel
http://www.tvmcalcs.com/index.php/calculators/apps/excel_bond_valuation

- Bond Yield Calculation Using Microsoft Excel
http://www.tvmcalcs.com/calculators/apps/excel_bond_yields

- Simulation, bootstrap, EM algorithm, MCMC (Gibbs Sampler, Metropolis Hastings)
http://www.haowulab.org/teaching/statcomp/statcomp.html

- MATLAB / R Reference
https://cran.r-project.org/doc/contrib/Hiebeler-matlabR.pdf

- The new swap math
http://janroman.dhis.org/finance/OIS/CurveBuid%20-%20Bootstrap/BBG-TheNewSwapMath.pdf

- Datastream guide
https://www.gsb.stanford.edu/sites/gsb/files/datastream_guide_0.pdf

- An Interest Rate Model (Review of No Arbitrage Pricing, Review of Risk-Neutral Probabilities)
http://people.stern.nyu.edu/jcarpen0/courses/b403333/14model1h.pdf


Courses

- Course on Debt Instruments and Markets (zeros, convexity, FRAs, repos, swaps, RNP, hedging, caps, floors, options, futures)
http://people.stern.nyu.edu/jcarpen0/courses/b403333/

- Stock & Watson Summer Course
https://www.nber.org/minicourse_2008.html

How to reset SMC & PRAM and fix 99% of Mac problems
https://trendblog.net/mac-shutting-down-smc-pram-fix/

