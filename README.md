# Ch_Synthetic

The files in this folder are provided to allow the replication of the results in "Term Premia in Emerging Markets" by Pavel Solís
Alternative title: International Bond Risk Premia Implications of Deviations from Covered Interest Rate Parity

-------------------------------------------------------------------------------------
SYSTEM FEATURES
-------------------------------------------------------------------------------------
The results in the paper were generated using the following
- Operating system: macOS High Sierra 10.14.3
- Software: Matlab R2018b, Stata 15
- Add-ons: Matlab Financial Toolbox, Excel add-in for Bloomberg
- Restricted data sources: Bloomberg terminal, Thomson Reuters Datastream
- Expected running time: Pre-Analysis (XX min/hr), only if replicated from scratch (i.e. using data directly downloaded from Bloomberg and Datastream); Analysis (XX min/hr)


-------------------------------------------------------------------------------------
CONTENTS OF THE MAIN FOLDER
-------------------------------------------------------------------------------------
README.txt (this file)
doAll.sh: generates results, paper and slides
Codes folder: 
	runCodes.EXT: executes the codes that generate the results
	Pre-Analysis folder: codes for cleaning and preparing the data
	Analysis folder: runAppendix.EXT and replication codes
Data folder: 
	Analytic folder
	Raw folder
	Temp folder
	MetadataGuide.docx
Docs folder: 
	Paper folder
	Slides folder
	Tables folder
	Equations folder
	Figures folder: figures, Latex folder
	DataStats folder: descriptive statistics of the variables used
	Settings folder: .tex files used for both the paper and the slides, .gitignore
	References folder: .bib file with the references cited


-------------------------------------------------------------------------------------
DATA FILES
-------------------------------------------------------------------------------------
See the metadata guide (Data -> MetadataGuide.docx) for a description of the data files (e.g. date accessed, how to obtain a copy, list of variables, sample period)

The results can be replicated using the data contained in the MAT-file (Codes -> Pre-Analysis -> .mat). This file constructs the necessary variables for the analysis from the data dowloaded from Bloomberg and Datastream, which is not included in the replication folder due to licensing issues. However, the dataset can be recreated from scratch and, subsequently, updated if you have access to those two sources. See the metadata guide (Data -> MetadataGuide.docx) for how to recreate or update each of the following:
- Tickers documented in AE_EM_Curves_Tickers.xlsx (Bloomberg and Datastream)
- Tickers documented in Macro_Finance_Tickers.xlsx (Bloomberg)
- US yield curve from Gürkaynak, Sack & Wright
- US term premium from Adrian, Crump & Moench
- Uncertainty indexes from Baker, Bloom & Davis


-------------------------------------------------------------------------------------
INSTRUCTIONS TO REPLICATE THE STUDY
-------------------------------------------------------------------------------------
Open doAll.sh. This file calls runCodes.EXT (Codes -> runCodes.EXT) to reproduce the results (figures and tables), paper.tex (Docs -> Paper -> paper.tex) and slides.tex (Docs -> Slides -> slides.tex) to generate the latest versions of the paper and the slides. Before executing doAll.sh choose the option that you want to execute: with access to Bloomberg and DataStream data or with no access to them. See below on how to update the data. If you don't want to or can't execute doAll.sh, you can replicate the results by manually executing runCodes.EXT and then (in any order) executing paper.tex and/or slides.tex.

What do runCodes.EXT, paper.tex and slides.tex do?
Stratification (dividing into small components) avoids repeating code or duplicating files (e.g. equations, figures and tables used in both the paper and the slides) and allows to focus on specific parts. This also has many other advantages like development and testing, as well as facilitating collaboration. The downside is that it may be difficult to follow the order of the codes and files. Master files, however, solve this issue by calling the necessary files in the required order.
- runCodes.EXT: run codes sequentially to clean the data, perform the analysis and generate the results (figures and tables). See below if you want to follow the workflow of the codes.
- paper.tex: call abstract.tex, sections.tex and appendix.tex (the last two call equations, figures and tables).
- slides.tex: call title_slide.tex as well as equations, figures and tables.



List of results reported in the paper that are replicated:
Result 1: Figure 3
Result 2: Table 2, column 4
Result 3: The simulation reported in section 4.3
Result 4: The income elasticity of demand for beef (1.86) reported on page 58 of the
paper



-------------------------------------------------------------------------------------
FINAL COMMENTS
-------------------------------------------------------------------------------------
If you modify the files in the main folder, keep in mind that file and folder names must not have spaces.

The paths in the codes for opening and/or saving files are relative to the folder in which the file is located. Therefore, the codes work regardless of where the main folder is located.

Commands that generate specific results in the paper are indicated with comments in the code.

The paths of directories are defined using the Unix convention (i.e. forward slash). Windows, in contrast, uses backslash; thus, an error may appear if the files are executed in a Windows machine. The user would just need to modify them where appropriate; this should only happen in executable .sh files because the codes in Matlab were written to be independent of the platform used.

On reproducibility of empirical research, see:
- TIER protocol (http://www.projecttier.org/tier-protocol/)
- Gentzkow & Shapiro, 2014. Code and Data for the Social Sciences: A Practitioner’s Guide
- Chang & Li, 2017. A Pre-analysis Plan to Replicate Sixty Economics Research Papers That Worked Half of the Time


-------------------------------------------------------------------------------------
CODE WORKFLOW (OPTIONAL)
-------------------------------------------------------------------------------------
All information is stored in a Matlab structure array of countries with different fields. The information in the key fields (including lccs, tp, syn, nom) is stored as a timetable (a Matlab data type). Below are the details to facilitate following the workflow of the codes.

In pre-analysis folder
run read_data.m 		-> generates dataset_daily (takes < 2 min)
	read_data.m calls: read_tickers_v4.m, read_bloomberg.m, read_usyc.m, ccs.m, csp.m, 	append_dataset.m, plot_spreads.m


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
*
∗


ideal: master file (rp_analysis) that calls functions fit_NS, rp_estimation, rp_plot
give dataset (rf or risky) and special_cases (rf or risky) to fit_NS and get dataset_lcRF or dataset_lcRK
give dataset_lcXX to rp_estimation and get dataset_monthly, header_monthly, statistics
merge both datasets
plot rf and risky



'dataset_daily' contains yield curves (LC, FC, US), cross-currency swaps, credit spreads (LC, FC, LC-US) for different maturities with DAILY frequency. All series run top-down from first day of sample to the most recent one, series were appended to the RIGHT. Countries are identified using (filtering in) header_daily

'dataset_monthly' contains synthetic LC yield curves, expected short rates, risk premia, LCCS for different maturities with MONTHLY frequency. Series run top-down form the first available date per country to the most recent one, series were appended BELOW (since series start at different times). Countries are identified using (filtering in) dataset_monthly



-------------------------------------------------------------------------------------
GITHUB
-------------------------------------------------------------------------------------
Git is a version control software. Github is a hosting service for your committed changes.
A Git repository is a history of commits and how they relate.
	Git tracks changes line by line
	Git stores data as a series of snapshots
A branch is a sequence of commits.
Git encourages workflows that branch and merge often, even multiple times in a day.


Setting up Git (https://help.github.com/en/articles/set-up-git):
- Compare your current version (git --version) with the latest release (https://git-scm.com/downloads)
- Git uses a username to associate commits with an identity. The Git username is not the same as your GitHub username.
- Set your Git username for every repository on your computer: git config --gobal user.name "Your Name"
- Set your commit email address in Git: git config --global user.email "Your Email"
- Tell Git to colorize its output appropriately: git config --global color.ui "auto"
- Authenticate with GitHub from Git using either HTTPS (recommended) or SSH: https://help.github.com/en/articles/which-remote-url-should-i-use#cloning-with-https-urls-recommended
	If you don't authenticate, when you try to clone, pull, push, etc. to the remote repository, the terminal will display the following error: Permission denied (publickey)
- If you decide to use HTTPS:
	Find out if Git and the osxkeychain helper are already installed: git credential-osxkeychain
	Tell Git to use osxkeychain helper using the global credential.helper config: git config --global credential.helper osxkeychain
	After this, the next time you try to clone, pull, push, etc. from the terminal, it will ask you for your GitHub user and password


Create (remote and local) repositories (projects):
- IN GitHub.com click the plus sign at the top and follow the instructions. Choose whether you want the repository to be private or public. Initialize it with a README file. You can also include a GitHub-hosted .gitignore file.
	Make sure to have or create a .gitignore file immediately after creating a repository that includes the file extensions you want Git to ignore so that they are ignored right away when you include files with those extensions in your local repository (o/w if you first upload a file with extension that you don't want to follow and then create the .gitignore file, you will need to untrack the file with the command: git rm --cached <filename.ext>)
	Extensions to include: Latex junk, Excel files (.xls, .xlsx, .xlsb) because of size limits and they will later be processed into .mat files. Very large files (100 MB or larger) do not work well in version control because they are often duplicated in the history.
	DO NOT include: .tex, figures (you may want them later if you change the code)
	You can place .gitignore within any directory in a Git repository. Note that it doesn't work if you put it in the .git (repository) directory. However, if you need to have a private version of .gitignore, you can add the rules to the .git/info/exclude file.
	
- Copy the url link that is created to clone the repository in your machine
	There are two options, you need the appropriate URL depending on how you decided to clone when setting up Git: using HTTPS (recommended) or SSH
- IN the terminal go to the folder where you want to set the repository: git clone <url>
- To see what's different between GitHub (in the cloud) and your local machine: git status
- To include new (o/w untracked) or update modified (o/w not staged) files to the staging area (from which changes will be recorded later): git add <filename1.ext> <filename2.ext>
	Once a file is in the staging area, git keeps track of its changes
	To add ALL files in the directory: git add . or git add -A or git add --all	
	HEAD is the name of the current commit
	To remove changes from the staging area (does not change the history at all nor does it change what is going on in the working directory, safe command): git reset HEAD
	To unstage changes to a file: git reset HEAD <filename.ext>
	To remove file from the staging area but not form the working directory: git rm --cached -- <filename.ext>
	To discard changes in working directory before they are staged (Warning! When you do this you will lose any unsaved work!): git checkout HEAD -- <filename.ext>
- Before committing run tests and review changes
- To lock in the changes to your LOCAL repository (commit a snapshot of the files in the staging area): git commit -m "Brief (< 50 characters) meaningful comment"
	If you have already some files and want to add them: git commit -a -m "Message"
- To sync up the local changes with GitHub.com: git push
- To pull down from GitHub.com to your machine: git pull


Difference between stage and commit:
- You don't want keep a record of EVERY little change. You want to make changes and once you are happy the final edit (no mistakes in code, compilation errors, consistent output), you add the file to the staging area.
- It is recommended to commit per discrete task (which may involve multiple files). However, you may be modifying more files than the ones involved in a particular task. With git add you can select which of the modified files have to do with that particular task, and commit those without having to commit the other modified files unrelated to that task. In other words, staging allows to commit changes per task ('small' frequent commits rather than big infrequent commits).
- When using git add, you can select which files to include. When using git commit you don't choose which files, all files in the staging area are committed.


Git workflow (branching, merging, pull request):
Summary: to solve a feature request make a branch for it, code the feature, commit it, get latest master, merge master back into your branch, push it up, make a pull request for other people to peer review the code. You can make more merges to an existing pull request depending on the feedback received. When your branch is merged to the trunk of the tree (master branch), everybody's branches can inherit those changes.
Branches are the most powerful part of Git. They allow to trying things out.
- Start from the master branch, and make sure you have the most recent version: git pull
- To see all branches: git branch
	If only the master branch exists, it will say: * master
- To create a new branch OF the branch you are currently on: git branch <branchname>
	Use meaningful branch names. See some useful naming conventions that facilitate the workflow: https://stackoverflow.com/questions/273695/what-are-some-examples-of-commonly-used-practices-for-naming-git-branches
- To see all branches: git branch
	It will display: <branchname>, * master
	The asterisk tells you the branch in which you are currently working on
- Switch to the new branch: git checkout <branchname>
	This allows to make changes to the new branch without affecting the master branch
- Add the changes to the files in the branch and then: git add
- Commit the changes to the branch: git commit
- See in which brach you are working on: git branch
	It will display: * <branchname>, master
- Go to the branch to which you want to merge into: git checkout master
- Load all new commits in the remote repository to make sure that master has not changed since the last sync with: git pull
- Go to the branch you had been working on: git checkout <branchname>

- Make the necessary changes
	Add and commit as many edits as necessary
- Merge all the changes in the master branch INTO your branch: git merge master
	Alternatively, you can go to the master and from there merge the <branchname>: git checkout master, followed by git merge <branchname>
	If there are conflicts, they will be indicated; you are HEAD
- Manually resolve any conflict
	Delete all of the delimiters
- Add the file back and finish the merge: git add --all followed by git merge --continue
	To abort the merge: git merge --abort

- Save all your commits by sending them to the remote repository (your branch <branchname> in GitHub): git push
	Always commit before pushing or pulling
	You can push all your branches to the remote repository, or only some of them
	To push just a single branch (and no other branches) nor the master: "git checkout <branchname>" followed by "git push origin <branchname>"
	See https://stackoverflow.com/questions/820178/how-do-you-push-just-a-single-git-branch-and-no-other-branches
	Note that you need to checkout to <branchname> (be in that branch) because if you are on master it would try to push the local master branch to the remote <branchname>. If you want to not have to checkout first you would have to do "git push origin <branchname>:<branchname>"

- IN GitHub.com refresh, go to your branch <branchname> and click the green button 'Compare, review, create a pull request', which will show your changes in green. This is also useful to understand some conflicts
- Create a pull request for other people to peer review the changes by clicking the green button 'Create Pull Request'
- After typing title and comments, click the green button 'Send pull request'
- Back and forth conversion about the changes
- Someone with privileges can accept the changes by clicking the green button 'Merge pull request', then the 'Confirm merge' button. The changes will now show up in master
	Usually a bad idea to merge your own pull requests when working with a team
- Once it has been merged to master, the branch <branchname> can be safely deleted by clicking the grey button 'Delete branch'
- IN the terminal, switch back to master and sync: git checkout master, git pull


Comments:
- pull before you push so that the local and the remote repos are in sync
- all repositories should contain a license file
	Explicitly claim copyright: Copyright [yyyy] [name of copyright owner]
- '--' tells Git that what follows after the two dashes are filenames
	To check out files from a previous commit: git checkout COMMIT_IDENTIFIER -- file1, file2
- All commands for git have the following syntax: git verb options
- git commands only work when you are in a folder that contains a git repository, otherwise it will send an error message ('Not a git repository')
- To get out of the screen when no comment is included in a commit, there are two options:
	Type in the multi-line message that you forgot to include
	Esc+:wq to continue with the commit without a message
- Working with large files: https://help.github.com/en/articles/working-with-large-files
- Ignoring files: https://help.github.com/en/articles/ignoring-files
- To rename a repository: https://help.github.com/en/articles/renaming-a-repository
- To relocate a local repo: https://stackoverflow.com/questions/11384928/change-git-repository-directory-location
- Warning: git reset have options --hard and --soft that can be used to rewrite history and to throw out commits that you no longer want
- Reasons for not keeping the repository in Dropbox: there is a chance of conflicts between the syncing of Dropbox and GitHub, and the space limit in Dropbox might be an issue when the chapter folders grow in size (or even each chapter with different branches)
- Reasons for having a project for each chapter: GitHub has a limit of 1 GB per project and has limits of 100MB per file, keeping them separate minimizes this issues


Order:
- Healey (intuitively explains Git workflow), Youtube videos by Learn Code, Pinter (2019), Fernández-Villaverde (assumes you know the previous ones)



-------------------------------------------------------------------------------------
COMPATIBILITY
-------------------------------------------------------------------------------------
The data types 'table' and 'categorical arrays' were introduced in MATLAB 8.2 (R2013b). This code makes heavy use of those data types as well as of functions for tables introduced in R2016b (e.g. synchronize).




-------------------------------------------------------------------------------------
DELETE
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


-------------------------------------------------------------------------------------
VBA CODE
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


-------------------------------------------------------------------------------------
WEBPAGES
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

- Course on Debt Instruments and Markets(zeros, convexity, FRAs, repos, swaps, RNP, hedging, caps, floors, options, futures)
http://people.stern.nyu.edu/jcarpen0/courses/b403333/

- Stock & Watson Summer Course
https://www.nber.org/minicourse_2008.html

How to reset SMC & PRAM and fix 99% of Mac problems
https://trendblog.net/mac-shutting-down-smc-pram-fix/

