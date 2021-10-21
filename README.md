# Ch_Synthetic

The files in this folder facilitate the replication of the results in "Term Premia and Credit Risk in Emerging Markets: The Role of U.S. Monetary Policy" by Pavel Solís (pavel.solis@gmail.com)


## SYSTEM FEATURES
-------------------------------------------------------------------------------------
The results in the paper were generated using the following:
- Operating systems: macOS 11.6, Windows 10 Enterprise
- Software: Matlab R2019a, Stata 17
- Add-ons. Matlab toolboxes: Financial. Stata: scheme-modern, xtcsd, xtscc.ado*
- Restricted data sources: Bloomberg, Datastream
- Expected running time: Pre-Analysis (1 hr), Analysis (2 hrs)

* Comment out section `Check if dataset's timevar is regularly spaced` (lines 74-83) because it uses `tab `timevar'` which gives the error `too many variables`. To find the location of the xtscc.ado file, type `which xtscc` in Stata.


## CONTENTS OF MAIN FOLDER (Ch_Synt)
-------------------------------------------------------------------------------------
README.txt (this file)

runAll.sh: generates results (if data files are provided, see below), paper and slides

Codes folder:
- Pre-Analysis folder: codes for cleaning and preparing the data
- Analysis folder: replication codes
- Extra folder: auxiliary files not used to generate the results

Data folder:
- Metadata: files describing the datasets needed to generate the results
- Raw folder: original data files 
- Analytic folder: generated datasets
- Extra folder: auxiliary files not used to generate the results

Docs folder: 
- DataStats folder: intended for descriptive statistics of the variables but is empty
- Paper folder: files for the manuscript
- Slides folder: files for the slides
- Equations folder: files for equations used in the paper and the slides
- Figures folder: files where figures are stored
- Tables folder: files to generate the tables
- Settings folder: .tex files with settings for the paper and the slides
- References folder: .bib file with cited references
- Extra folder: auxiliary files not used in the paper nor the slides


## DATA FILES
-------------------------------------------------------------------------------------
The repository does not support .xls nor .xlsx files. See the metadata guide (Data -> Metadata -> MetadataGuide.docx) for a description of all original data files (names, sources, date downloaded, list of variables, sample period) and how to recreate them.

Datasets that require access to Bloomberg and Datastream cannot be shared due to licensing rights. All other files can be shared upon request.

From the datasets in the Raw folder, the codes generate new datasets. Some of them are stored outside the main folder Ch_Synt due to their large sizes; they are: struct_datady_cells.mat, struct_datady_S.mat, struct_datamy_S.mat, dataspillovers1.dta, dataspillovers2.dta. Before running the codes (either individually or via runAll.sh), you need to define where those large datasets will be stored in your computer by updating the paths in the respective codes (read_data.m, ts_analysis.m, spillovers.do). 


## INSTRUCTIONS TO REPLICATE THE STUDY
-------------------------------------------------------------------------------------
runAll.sh calls the scripts to reproduce the results (figures and tables) and to generate the latest versions of the paper and the slides. If you don't want to or can't execute runAll.sh, you can replicate the results by manually executing the scripts in the same order as in runAll.sh (for this, open it with a text editor).

The scripts called by runAll.sh are master files. The idea behind them is stratification (dividing into small components), which avoids repeating code or duplicating files (e.g. equations, figures and tables used in both the paper and the slides) and allows one to focus on specific parts. This also has advantages in development and testing, as well as facilitating collaboration. Master files call the necessary files in the required order.
- runAll.sh: runs the analytical codes sequentially (to clean the data, perform the analysis and generate the figures and tables), and calls paper.tex and slides.tex.
- paper.tex: call abstract.tex, sections.tex and appendix.tex (the last two call equations, figures and tables).
- slides.tex: call title_slide.tex as well as equations, figures and tables.


## COMMENTS
-------------------------------------------------------------------------------------
If you add or modify the files in the main folder, keep in mind that the names of files and folders must have *no* spaces.

The paths in the codes for opening and/or saving files are relative to the folder in which the file is located. Therefore, the codes work regardless of where the main folder is located. However, the relative paths rely on the structure of the main folder as provided.

The paths of directories are generally defined using the Unix convention (i.e., forward slash). Since Windows systems use a backslash, an error may appear if the files (e.g., .sh, .do, .tex) are executed in a Windows machine. The user would just need to modify the codes where appropriate. Matlab codes are mostly independent of the platform used.

On reproducibility of empirical research, see:
- TIER protocol (http://www.projecttier.org/tier-protocol/)
- Gentzkow & Shapiro, 2014. Code and Data for the Social Sciences: A Practitioner’s Guide
- Chang & Li, 2017. A Pre-analysis Plan to Replicate Sixty Economics Research Papers That Worked Half of the Time


## WORKFLOW OF MATLAB CODES (OPTIONAL)
-------------------------------------------------------------------------------------
Most data in Matlab are stored in a structure array of countries with different fields; the information in key fields is stored as a timetable (a Matlab data type). Below are details to facilitate following the workflow of the codes.

In the Pre-Analysis folder, read_data.m -> generates dataset_daily (approx. runtime: 1 hr)
	read_platforms	-> tickers from Bloomberg and Datastream
	read_usyc	-> data from GSW and H.15
	fwd_prm		-> short- and long-term forward premia
	zc_yields	-> par converted into zero-coupon yields
	spreads		-> CIP deviations, yield spreads (LC, FC)
	read_cip		-> load DIS dataset
	plot_spreads	-> plot (term structure of) spreads
	compare_cip	-> compare own spreads vs DIS
variable types in header_daily: RHO,LCNOM,LCSYNT,LCSPRD,CIPDEV,FCSPRD
auxiliary m-files: compare_tbills, compare_ycs, compare_fx

In the Analysis folder, ts_analysis.m -> generates structure with data in fields (approx. runtime: 2 hrs)
	daily2dymy	-> extract monthly data
	add_macroNsvys	-> add macro and survey data
	append_svys2ylds	-> combine yield and survey data
	atsm_estimation 	-> estimate model w/ and w/o survey data, nominal & synthetic YCs
	se_components	-> compute standard errors using the delta method
	(post-estimation)-> assess_fit, add_vars, ts_plots, ts_correlations, ts_pca
	atsm_daily	-> estimate model w/ daily data
	construct_panel 	-> construct panel dataset
auxiliary m-files: read_macrovars, read_kw

'dataset_daily' contains yield curves (LC, FC, US), forward premiums, spreads (LC, FC, LC-US) for different maturities with DAILY frequency. All series run top-down old-new, series were appended to the RIGHT. Series are identified with a filter over header_daily

'dataset_monthly' contains synthetic LC yield curves, expected short rates, term premia, LCCS for different maturities with MONTHLY frequency. Series run top-down old-new, series were appended BELOW (since series start at different times). Series are identified with a filter over header_monthly
