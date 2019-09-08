# Ch_Synthetic

The files in this folder are provided to allow the replication of the results in "Term Premia in Emerging Markets" by Pavel Solís
Alternative title: International Bond Risk Premia Implications of Deviations from Covered Interest Rate Parity.


## SYSTEM FEATURES
-------------------------------------------------------------------------------------
The results in the paper were generated using the following:
- Operating system: macOS High Sierra 10.14.3
- Software: Matlab R2018b, Stata 15
- Add-ons: Financial Toolbox of Matlab, outreg2 for Stata, Excel add-in for Bloomberg
- Restricted data sources: Bloomberg terminal, Thomson Reuters Datastream
- Expected running time: Pre-Analysis (XX min/hr), only if replicated from scratch (i.e. using data directly downloaded from Bloomberg and Datastream); Analysis (XX min/hr)


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
- MetadataGuide.docx

Docs folder: 
- Paper folder
- Slides folder
- Tables folder
- Equations folder
- Figures folder: figures, Latex folder
- DataStats folder: descriptive statistics of the variables used
- Settings folder: .tex files with settings used for both the paper and the slides
- References folder: .bib file with the references cited


## DATA FILES
-------------------------------------------------------------------------------------
See the metadata guide (Data -> MetadataGuide.docx) for a description of the data files (e.g. date accessed, how to obtain a copy, list of variables, sample period)

The results can be replicated using the data contained in the MAT-file (Codes -> Pre-Analysis -> .mat). This file constructs the necessary variables for the analysis from the data dowloaded from Bloomberg and Datastream, which are not included in the replication folder due to licensing issues. However, the dataset can be recreated from scratch and, subsequently, updated if you have access to those two data sources. See the metadata guide (Data -> MetadataGuide.docx) for how to recreate or update each of the following:
- Tickers documented in AE_EM_Curves_Tickers.xlsx (Bloomberg and Datastream)
- Tickers documented in Macro_Finance_Tickers.xlsx (Bloomberg)
- US yield curve from Gürkaynak, Sack & Wright (2007)
- US term premium from Adrian, Crump & Moench (2013)
- Uncertainty indexes from Baker, Bloom & Davis (2016)


## INSTRUCTIONS TO REPLICATE THE STUDY
-------------------------------------------------------------------------------------
Open doAll.sh. This file calls runCodes.EXT (Codes -> runCodes.EXT) to reproduce the results (figures and tables), paper.tex (Docs -> Paper -> paper.tex) and slides.tex (Docs -> Slides -> slides.tex) to generate the latest versions of the paper and the slides. Before executing doAll.sh choose the option that you want to execute: with access to Bloomberg and DataStream data or with no access to them. See below on how to update the data. If you don't want to or can't execute doAll.sh, you can replicate the results by manually executing runCodes.EXT and then (in any order) executing paper.tex and/or slides.tex.

What do runCodes.EXT, paper.tex and slides.tex do?
Stratification (dividing into small components) avoids repeating code or duplicating files (e.g. equations, figures and tables used in both the paper and the slides) and allows to focus on specific parts. This also has many other advantages like development and testing, as well as facilitating collaboration. The downside is that it may be difficult to follow the order of the codes and files. Master files, however, solve this issue by calling the necessary files in the required order.
- runCodes.EXT: run codes sequentially to clean the data, perform the analysis and generate the results (figures and tables). See below if you want to follow the workflow of the codes.
- paper.tex: call abstract.tex, sections.tex and appendix.tex (the last two call equations, figures and tables).
- slides.tex: call title_slide.tex as well as equations, figures and tables.

List of results reported in the paper that are replicated:
1. Figure 3
1. Table 2, column 4
1. The simulation reported in section 4.3
1. The income elasticity of demand for beef (1.86) reported on page 58 of the paper


## FINAL COMMENTS
-------------------------------------------------------------------------------------
If you modify the files in the main folder, keep in mind that file and folder names must not have spaces.

The paths in the codes for opening and/or saving files are relative to the folder in which the file is located. Therefore, the codes work regardless of where the main folder is located.

Commands that generate specific results in the paper are indicated with comments in the code.

The paths of directories are defined using the Unix convention (i.e. forward slash). Windows, in contrast, uses a backslash; thus, an error may appear if the files are executed in a Windows machine. The user would just need to modify them where appropriate; this should only happen in executable .sh files because the codes in Matlab were written to be independent of the platform used.

On reproducibility of empirical research, see:
- TIER protocol (http://www.projecttier.org/tier-protocol/)
- Gentzkow & Shapiro, 2014. Code and Data for the Social Sciences: A Practitioner’s Guide
- Chang & Li, 2017. A Pre-analysis Plan to Replicate Sixty Economics Research Papers That Worked Half of the Time


## CODE WORKFLOW (OPTIONAL)
-------------------------------------------------------------------------------------
All information is stored in a Matlab structure array of countries with different fields. The information in the key fields (including lccs, tp, syn, nom) is stored as a timetable (a Matlab data type). Below are the details to facilitate following the workflow of the codes.

In pre-analysis folder

	run read_data.m 		-> generates dataset_daily (takes < 2 min)

	read_data.m calls: read_tickers_v4.m, read_bloomberg.m, read_usyc.m, ccs.m, csp.m, append_dataset.m, plot_spreads.m

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


## GIT AND GITHUB
-------------------------------------------------------------------------------------
**Git** is a version control software. **GitHub** is a hosting service for your committed changes. In this way, you can work in your machine (local) and backup your changes online (remote).

To **commit** is to register the changes made in a file or files. Before commiting changes, you put files in the **staging area** to keep track of them.

A Git **repository** is a history of commits and how they relate. A repository is a project (i.e. folder with files).
- Git tracks changes line by line
- Git stores data as a series of snapshots

A **branch** is a sequence of commits. 

An **upstream** is simply another branch name, usually a *remote-tracking* branch, associated with a (regular) *local* branch.

To **pull** is to download the changes in the remote repository to your local machine. To **push** is to upload the changes in your local machine to the remote repository.

In what follows:
- The lines starting with the '$' symbol mean commands one inputs in the terminal; the lines starting with the '>' symbol mean output shown in the terminal.
- The most commonly used commands in the terminal (also known as shell) when working with Git are: `cd`, `ls`.
- The most commonly used Git commands are: `status`, `add`, `commit`, `push`, `pull`; other less used commands include: `diff`, `reset`, `branch`, `checkout`, `merge`.

### [Setting Up Git](https://help.github.com/en/articles/set-up-git)
In the terminal type the following to compare your current version of Git with the [latest release](https://git-scm.com/downloads)
```bash
$ git --version
```

Git uses a username to associate commits with an identity; the Git username is not the same as your GitHub username. Set your Git username for every repository on your computer:
```bash
$ git config --gobal user.name "Your Name"
```

Set your commit email address in Git:
```bash
$ git config --global user.email "Your Email"
```

To visualize changes more easily in the terminal,  tell Git to colorize its output:
```bash
$ git config --global color.ui "auto"
```

[Authenticate](https://help.github.com/en/articles/which-remote-url-should-i-use#cloning-with-https-urls-recommended) with GitHub from Git using either HTTPS (recommended) or SSH. If you don't authenticate, when you try to clone, pull, push, etc. to the remote repository, the terminal will display the following error:
```bash
> Permission denied (publickey)
```

If you decide to use HTTPS:
- Find out if Git and the osxkeychain helper are already installed:
```bash
$ git credential-osxkeychain
```
- Tell Git to use osxkeychain helper using the global credential.helper config:
```bash
$ git config --global credential.helper osxkeychain
```

- After this, the next time you try to clone, pull, push, etc. from the terminal, it will ask you for your GitHub user and password (which you will only need to provide once).

All Git commands have the following syntax: git verb options.

Note: Git commands only work when (in the terminal) you are in a folder that contains a Git repository, otherwise the terminal will send an error message
```bash
> Not a git repository
```

### Create (remote and local) repositories
You need to designate a folder to be a Git repository. When you initialize a folder to be a repository, Git creates a subfolder called *.git* that it uses to do all its magic.

You can create a Git repository from the terminal with `$ git init` or from GitHub.com. With the first option, you will later need to call that local repository from GitHub; for the second option, later you will need to clone the remote repository into your local machine. Below are the steps for creating a repository using GitHub.

In GitHub.com click the plus sign at the top and follow the instructions. Choose whether you want the repository to be private or public. Initialize it with a README file. Although it's optional, it is recommended to include a GitHub-hosted *.gitignore* file, it includes the file extensions you want Git to ignore (e.g. junk files from Latex).

- If you are going to move an existing project (i.e. folder with files) to the repository just created, make sure to have or create a *.gitignore* file immediately after the repository is created, so that the unwanted files are ignored right away when you include files with those extensions in your local repository; otherwise, if you first upload a file with extension that you don't want to follow and then create the .gitignore file, you will need to untrack the file with the command: `$ git rm --cached <filename.ext>`.
- You can place the *.gitignore* file within any folder in the Git repository except in the *.git* folder itself, in which case the file won't work. However, if you need to have a private version of the *.gitignore* file, you can add the rules to the *.git/info/exclude* file.
- Extensions to include in the *.gitignore* file: Latex junk, Excel files (.xls*) because of size limits and they will later be processed into .mat or .dta files. In fact, very large files (> 100 MB) do not work well in version control because they are often duplicated in the history and are not supported by GitHub.
- Do **not** include: .tex files, figures (you may want them later if you change the code).

Once you created a repository in GitHub, copy the URL link that GitHub creates in order to clone the repository in your machine. You need the appropriate URL depending on how you decided to clone when setting up Git above. Thus there are two options: using HTTPS (recommended) or SSH.

Using the `cd` command in the terminal, go to the folder where you want to set the repository: 
```bash
$ git clone <URL>
```

This has initialized a folder as a Git repository. To pull down from GitHub.com the most recent version of the project to your machine, use:
```bash
$ git pull
# OR
$ git pull <remote> <branch>
```

### Daily Workflow: Status, Add, Commit and Push
To see what has changed in your local repository and/or what is different in your local machine with respect to the version in GitHub (in the cloud), use:
```bash
$ git status
```

- When your local version is not ahead to that in GitHub, the terminal will display `Your branch is up to date with 'origin/<parent>', nothing to commit, working tree clean`. However, note that this does not tell you whether the remote version is ahead of your local version. That is why it is recommended to always pull before pushing.

To include new (i.e. untracked) or update modified (i.e. not staged) files to the **staging area** (from which changes will be recorded later), use:
```bash
$ git add <filename1.ext> <filename2.ext>
```

- Once a file is in the staging area (also known as index), Git keeps track of its changes.
- To add *all* files in the directory, use: `git add .`, `git add -A` or `git add --all`.
- To keep tracking changes to files but place them back into the 'unstaged' area (in other words, without changing the history at all nor changing what is going on in the working directory, i.e. a safe command), use: `git reset HEAD`
- HEAD is the name of the current commit in the current branch.
- To do the same but for a specific file, use: `git reset HEAD <filename.ext>`, `git reset HEAD -- path/to/file` or `git reset <filename.ext>`. To unstage all files at once, you can also use: `git reset HEAD -- .`.
- To stop tracking changes to a file without removing it from the working directory (i.e. to only remove the file from the index or staging area), use: `git rm --cached <filename.ext>`. The  working directory is not affected by `git rm --cached`, because `--cached` works directly in the index. This command will set the file to the state it was after it was added to the staging area.
- To discard changes in the working directory before they are staged (*Warning*: When you do this, you will lose any unsaved work!), use: `git checkout HEAD -- <filename.ext>`
- `--` tells Git that what follows after the two dashes are filenames.

Once you finish making changes to the files in the staging area, the next thing to do is to record (i.e. **commit**) those changes. That is, to lock in the changes to your *local* repository, you need to commit a snapshot of the files in the staging area:
```bash
$ git commit -m "Brief (< 50 characters) meaningful comment"
```
- Always run tests and review changes *before* committing. When working with code, this means to commit working versions of it.

When you want to commit all the files in the staging area (e.g. a whole project), you can combine the add and commit steps in one step. above with one line as follows:
```bash
$ git commit -a -m "Message"
# OR
$ git commit -am "Message"
```
- If you did not include a message when you commit (either you forgot or you want to write a multi-line message), the terminal will show a screen to allow you to write a message. Git opens your default editor for you to edit the commit message. In a Mac it might be the `vi` editor. To start writing, press `i` (to switch to the insert mode) and write your comment. To exit the insert mode and switch to the command mode in order to save the changes, press `Esc`. Then type `:wq` to save the commit message and exit the editor, where `:` enters the command mode, `w` is for write/save and `q` is for quit (see [here](https://apple.stackexchange.com/questions/252541/how-do-i-escape-the-git-commit-window-from-os-x-terminal)). In summary,
```bash
Esc + :wq + Enter
```


To sync up the changes made locally with the repository in GitHub.com, use:
```bash
$ git push
```

#### Difference Between Stage and Commit
You don't want to keep a record of *every* little change you do. You want to make changes, go back and forth, and once you are happy with the new version (no mistakes in code, no compilation errors, consistent output), you register the changes.

It is recommended to commit *per discrete task* (which may involve multiple files). However, you may be modifying more files than the ones involved in a particular task. With `git add` you can select which of the modified files have to do with that particular task, and commit only changes to those files without having to commit the changes to the other modified files (unrelated to the task). In other words, staging allows you to commit changes per task. That is, with `git add` you can choose which of the modified files to commit; with `git commit`, however, you don't get to choose since all the files in the staging area are committed.

Make 'small' frequent commits rather than big infrequent commits.

#### See Changes Before Adding/Committing
Three different ways to see the changes made to a file before adding and/or committing:
```bash
$ git diff [filename]		# show differences between index and working tree (i.e. changes you haven't staged to commit)

$ git diff --cached [filename]	# show differences between current commit and index (i.e. what you're about to commit)
$ git diff --staged 		# does exactly the same thing, use what you like

$ git diff HEAD [filename]	# show differences between current commit and working tree
```
It'll work recursively on directories, and if no paths are given, it shows all the changes. [Here](https://stackoverflow.com/questions/1587846/how-do-i-show-the-changes-which-have-been-staged) is a graphic that explains the differences between using `--cached` and `HEAD`.

#### Discard Changes Before Adding/Committing
Discard all local changes, but save them for possible re-use later: 
```bash
$ git stash
```

Discarding local changes (permanently) to a file:
```bash
$ git checkout -- <file>
```

Discard all local changes to all files permanently:
```bash
$ git reset --hard
```

#### Remove File from Commit
To move a wrongly commited file to the staging area from a previous commit (without canceling the changes done): 
```bash
$ git reset --soft HEAD^
$ git reset HEAD path/to/unwanted_file		# Reset the unwanted files in order to leave them out from the commit
$ git commit -c ORIG_HEAD 			# Commit again with this or the usual command
```
Explained in this [link](https://stackoverflow.com/questions/12481639/remove-files-from-git-commit), which includes case where you also `git push`.


### Git Workflow: Branching, Merging, Pull Requests
*Summary*: Make a branch to solve a feature request, code the feature, make commits, get latest master version, merge master back into your branch, push your branch up, make a pull request for other people to peer review the code, resolve conflicts and make more merges to an existing pull request depending on the feedback received. When your changes are approved, your branch is merged to the parent branch and everybody's branches can inherit those changes.

Branches are the most powerful part of Git. They allow to trying things out. By isolating features into separate branches, everybody can work independently, yet it is still possible to share changes with other developers when necessary.

Git encourages workflows that branch and merge often, even multiple times in a day.

All branches in the remote repo will hang from origin, that is why it is important to have a branching model (structure, naming conventions, rules for branching off and merging to) to distinguish between permanent (`master`, `development`) branches and among temporary (`feature`, `fixes`) branches.

**CAUTION**: Always commit *and* close the modified files *before* switching branches (with `git checkout`) because when you switch Git will update the files in the repository to match the version to which you are moving to. If you introduce changes in one branch and suddenly realized to it would be better to swith to a different branch, Git [may or may not](https://stackoverflow.com/questions/22053757/checkout-another-branch-when-there-are-uncommitted-changes-on-the-current-branch) allow you to switch:
- If Git doesn't allow you to switch, you can use `git commit` to the current branch and then switch to a different branch; alternatively, you can save your changes in a temporary branch using `git stash`, make the required changes in another branch and then restore the interrupted changes using `git stash pop`. `git stash` can also be used when your local changes conflict with the changes in the upstream (in which case, `git pull` will not merge): `git stash`, `git pull`, `git stash pop`.

#### Daily Workflow (Cont.)
Modify the files in the branch, add and commit to the branch as many edits as necessary with: `git add`, `git commit`.

Once you finish making changes, you want to incorporate the latest version of the `parent` branch in the remote repository into your local repository to ensure there are no conflicts: 
```bash
$ git checkout <parent>
$ git pull
$ git checkout <branchname>
$ git merge <parent>		# merges <parent> **into** the *current* branch (i.e. <branchname>)
```
- Always **commit before** pushing or pulling because if there are conflicts, Git reconstructs using the commits.
- Always **pull before** you push so that the local and the remote repositories are in sync.
- **Consult before** merging when working in a team in order to get feedback on a new feature branch. Create a pull request for this.
- If you want to merge the changes in `<branchname>` into the `<parent>`: `git checkout <parent>`, `git merge <branchname>`.

If there are conflicts, they will be indicated in the respective file (you are HEAD). Manually resolve any conflict. Delete all of the delimiters (`<<<`). Add the file back (`git add --all`) and finish the merge (`git merge --continue`). To abort the merge use: `git merge --abort`.


#### Knowing Where You Are and How to Move
To see the available branches:
```bash
$ git branch			# Displays all local branches
$ git branch -r			# Displays all remote branches
$ git branch -a			# Displays all local and remote branches

> * master			# If only the master branch exists
> * master, <branchname>	# If there are two branches
```   
- The asterisk tells you the branch in which you are currently working on. If you configured Git to display its output in color, the current branch will be displayed in green; remote branches will be displayed in red; the rest of the branches (local non-current) will be displayed in white.   

#### Download the Changes in the Remote Repository to the Local Repository
In the terminal, switch back to master and sync: 
```bash
$ git checkout master
$ git pull
```

In the terminal, go to the *local* `parent` branch (which initially will be the `master` branch) and make sure you have the most recent version of the *remote* `parent` branch:
```bash
$ git checkout <parent>		# Update the files to work on `parent`
$ git pull
```

#### Create a Branch
Create a new branch **off** the *current* branch and go to the new branch:
```bash
$ git branch <branchname>		# Creates a branch called <branchname>
# OR
$ git branch --set-upstream-to=origin/<branch> <branch>	# To set tracking information for the branch
					# Message displayed: "Branch '<branchname>' set up to track remote branch '<branchname>' from 'origin'"
# OR

$ git checkout <branchname>		# Switches to branch <branchname>
# OR
$ git checkout -b <branchname>		# Creates branch <branchname> and switches to it
# OR
$ git checkout -t origin/<branchname>	# Creates <branchname>, switches to it and tracks (for push and pull) its remote branch
# OR
$ git checkout -b <branchname> origin/<branchname> # Same as previous but local and tracking branches can have different names
```
- You can now make changes to the new branch `<branchname>` without affecting the `master` branch.
- If after switching to the branch you type `git branch`, the terminal will display: `master`, `* <branchname>`.
- [Link](https://stackoverflow.com/questions/10002239/difference-between-git-checkout-track-origin-branch-and-git-checkout-b-branch) explaining the difference between `git checkout -b` and `git checkout -t` for tracking a remote branch.


#### Upload Changes to the Remote Repository
Save all your commits in the local branch `<branchname>` to the remote repository (your branch `<branchname>` in GitHub):
```bash
$ git checkout <branchname>

$ git push	   		   # Works like `git push <branchname>`, where `<branchname>` is the *current* branch’s remote
# OR
$ git push origin  		   # Pushes the *current* branch to the configured upstream, if it has the same name as the current branch.
# OR
$ git push origin <branchname> 	   # Essentially the syntax is `git push <to> <from>`
# OR
$ git push -u origin <branchname>  # If there is no associated remote branch to <branchname>, use this line in the first push for Git to set `origin/<branchname>` as the upstream for the current branch
				   # This is no needed if the branch was created with `git checkout -b` or `git checkout -t`
				   # Message: `Branch '<branchname>' set up to track remote branch '<branchname>' from 'origin'`
```
-Note that you need to switch to `<branchname>` because if you are on `<parent>` and type `git push origin <branchname>`, Git will try to push the local `<parent>` branch (being the *current* branch) to the remote `<branchname>`, which would be incorrect. If you are in `<parent>` and you don't want to checkout to `<branchname>`, you can use: `git push origin <branchname>:<branchname>`.
- The options above push [just the current branch](https://stackoverflow.com/questions/820178/how-do-you-push-just-a-single-git-branch-and-no-other-branches), not other branches nor the `<parent>`. However, if for every branch that exists on the local side, you want the remote side to be updated if a branch of the same name already exists on the remote side use: `git push origin :` or `git push origin +:` (for non-fast-forward updates).

In GitHub.com refresh, go to your branch `<branchname>` and click the green button 'Compare, review, create a pull request', which will show your changes in green. This is also helpful to understand some conflicts.

#### Pull Requests
*Before* merging, create a pull request when collaborating with other colleagues.

Create a pull request for other people to peer review the changes by clicking the green button 'Create Pull Request'. After typing title and comments, click the green button 'Send pull request'.

Time for back and forth conversation about the changes, as well as necessary corrections (new commits and merges).
- Before you merge, you may have to resolve merge conflicts if others have made changes to the repo. 

When your pull request is approved and conflict-free, you can add your code to the `<parent>` branch.

Someone with privileges can accept the changes by clicking the green button 'Merge pull request', then the 'Confirm merge' button. The changes will now show up in the `<parent>` branch.
- It is usually a bad idea to merge your own pull requests when working with a team.

#### Delete Branches
Only delete temporary branches (`ftr` and `fix`), not permanent branches (`dev`).

Once it has been merged to in its upstream branch, the branch `<branchname>` can be safely deleted.

To delete a **local** branch (which has already been fully merged in its upstream branch) from the terminal:
```bash
$ git branch -d <branchname>
```

To delete a **remote** branch from the terminal ([link](https://stackoverflow.com/questions/2003505/how-do-i-delete-a-git-branch-both-locally-and-remotely), [link](https://stackoverflow.com/questions/5094293/git-remote-branch-deleted-but-still-appears-in-branch-a)):
```bash
$ git branch -d -r origin/<branch_name>		# Remove a particular remote-tracking branch
# OR
$ git push origin --delete <branch_name>
# OR
$ git push origin :<remote_branch_name>
```

To delete a branch **in GitHub**:
- After a pull request has been approved and merged, you can delete a branch by clicking the grey button 'Delete branch'. 
- If you merge a branch locally and then deleted it from the terminal, to delete it in GitHub click on the 'branches' tab at the top of the project's contents and click the trash button nex to the name of the branch.

When you delete branches in GitHub, they will still show up in the terminal with `git branch -a`. Also, after deleting the local branch (with `git branch -d <branchname>`) and the remote branch (with `git push origin --delete <branchname>`) other machines may still have "obsolete tracking branches". To remove all such [stale](https://makandracards.com/makandra/6739-git-remove-information-on-branches-that-were-deleted-on-origin) branches locally:
```bash
$ git remote prune origin
# OR
$ git fetch --prune
# OR
$ git fetch --all --prune		# In other machines after deleting remote branches to propagate changes
# OR
$ git fetch -p				# Prune remote branches
# OR
$ git pull -p
```



### Driessen's Branching Model
Use meaningful branch names. 
- [Link](https://stackoverflow.com/questions/273695/what-are-some-examples-of-commonly-used-practices-for-naming-git-branches) for useful naming conventions that facilitate the workflow. 
- [Link](https://nvie.com/posts/a-successful-git-branching-model/) explaining a successful Git branching model.

Based on the previous two sources, I will use a forward slash separator and the following branching categories and rules: 
- `dev` branch off from `master` and merge back into `master`. It is a permanent branch.
- `ftr` branch off from `dev` and merge back into `dev`. It is a temporary branch.
- `fix` branch off from `master` or `dev` and merge back into `master` or `dev`. It is a temporary branch. `fix` branches deal with bugs found in the `dev` branch or in the `master` branch (due to a -recent- merge from the `dev` branch).

Since `dev` is a permanent branch and `fix` branches are mainly used to correct bugs, most of the branches that will be used are feature `ftr` branches. Therefore, naming conventions are needed to differentiate between them; also since `fix` branches can be branched off from `master` *or* `dev`, it will be useful to distinguish between them. Thus, these are the naming conventions for the temporary branches:
- To distinguish a `fix` branched off from `master` or `dev`, the names of `fix` branches will begin with: `fix/mst` or `fix/dev`.
- There can be three types of feature branches and so `ftr` can take any of three tokens: `data`, `code`, `docs`.
  `data` branches deal with raw or analytic data so this token will be followed by: `raw` and `ans`.
  `code` branches deal with pre-analysis or analysis of the data so this token will be followed by: `pre` and `ans`.
  `docs` branches deal with issues on equations, statistics, figures, paper, slides, references, tables so this token will be followed by: `sta`, `eqn`, `fig`, `ppr`, `set`, `sld`, `ref` and `tab`.
- All three of the different types of feature branches can be used for experimenting or testing minor things unrelated to the previous categories, in which case any of the three types will be followed by: `tst`.
- Examples: `data/raw/feature-name`, `code/ans/feature-name`, `docs/eqn/feature-name`, `fix/dev/feature-name`, `code/tst/feature-name`, `docs/tst/feature-name`.
- Therefore, there are in total 17 possible types of temporary branches: 15 feautre branches (12 regular, 3 for tests), 2 fix branches.
- With this convention (names *and* forward slashes), no branch can have the following names (see first link above) -i.e. without the `/feature-name` part-: `ftr/cat` (e.g. `data/raw`,`code/ana`), `fix/dev`, `fix/mst`.

#### Driessen's Model Adapted To A Research Project
[Implementation](https://stackoverflow.com/questions/4470523/create-a-branch-in-git-from-another-branch) of Driessen's branching model to a research project:
```bash
$ git checkout -b <branchname> <parent>	# Create a new branch **off** the `<parent>` branch *and* go to the new branch
					# Same as: git checkout <parent>, git branch <branchname>, git checkout <branchname>

$ git commit -am "Your message"		# Commit changes

$ git checkout <parent>
$ git merge --no-ff <branchname>	# Merge your changes to <parent> without a fast-forward

$ git push origin <parent>		# Push changes to the server
$ git push origin <branchname>
$ git branch -d <branchname>		# Optional: remove local and remote branches
$ git push origin --delete <branchname>
```

Implementation following the naming conventions:
```bash
# Develop branch
$ git checkout -b dev master
$ git push -u origin dev		# Sets the upstream for dev and see it in GitHub
	# Usual workflow
$ git status
$ git commit -am "Your message"
	# To merge dev branch into master
$ git checkout master
$ git merge --no-ff dev			# Merge your changes to master without a fast-forward
$ git push origin master		# Push changes to the server
$ git push origin dev


# Feature branches
	# Create the branch
$ git checkout -b ftr/cat/name dev
$ git push -u origin ftr/cat/name	# Sets the upstream for the branch and see it in GitHub
	# Usual workflow
$ git status
$ git commit -am "Your message"
	# To merge feature branch into dev, first close all open files from the feature branch
$ git checkout dev
$ git pull				# Pull before push to ensure you have the latest version of the remote dev branch
$ git merge --no-ff ftr/cat/name	# Merge your branch changes to dev without a fast-forward
$ git pull				# When working in teams, it might be needed to again pull to ensure you have the latest version of the remote dev branch and there are no conflicts
$ git push origin dev			# Push changes to the server
$ git push origin ftr/cat/name		# Might need `git branch` for the name of the feature branch
	# To delete the feature branch
$ git branch -d ftr/cat/name		# Optional: remove local and remote branches
$ git push origin --delete ftr/cat/name


# Fix branches
	# Create the branch
$ git checkout -b fix/dev/name dev	OR	$ git checkout -b fix/mst/name master
$ git push -u origin fix/dev/name	OR	$ git push -u origin fix/mst/name
	# Usual workflow
$ git status
$ git commit -am "Your message"
				# fix/mst branches
	# To merge fix branch into master
$ git checkout master
$ git merge --no-ff fix/mst/name	# Merge your changes to master without a fast-forward
$ git push origin master		# Push changes to the server
$ git push origin fix/mst/name
	# To merge fix branch into dev
$ git checkout dev
$ git merge --no-ff fix/mst/name	# Merge your changes to dev without a fast-forward
$ git push origin dev			# Push changes to the server
				# fix/dev branches
	# To merge fix branch into dev
$ git checkout dev
$ git merge --no-ff fix/dev/name	# Merge your changes to dev without a fast-forward
$ git push origin dev			# Push changes to the server
$ git push origin fix/dev/name
	# To delete the fix branch
$ git branch -d fix/xxx/name		# Optional: remove local and remote branches
$ git push origin --delete fix/xxx/name
```


### Details
- A **ref** is anything pointing to a commit (e.g. branches (heads), tags, and remote branches), they are stored in the .git/refs directory (e.g. `refs/heads/master`, `refs/remotes/master`, `refs/tags`). For example, `refs/heads/0.58` specifies a branch named `0.58`; if you don't specify what namespace the ref is in, Git will look in the default ones, so using only `0.58` is ambiguous (there could have both a `branch` and a `tag` named `0.58`).
- When an update changes a branch (or more in general, a ref) that used to point at commit A to point at another commit B, it is called a **fast-forward** update if and only if B is a descendant of A. Hence a fast-forward update from A to B does not lose any history.
- To check out files from a previous commit (to reverse changes): `git checkout COMMIT_IDENTIFIER -- file1, file2`.
- Warning: `git reset` have options `--hard` and `--soft` that can be used to rewrite history and to throw out commits that you no longer want.
- If you use `git init` to create a local repository, and then want to upstream it to a remote (empty) repo, in your first push you need to use: `git push -u origin master`. This will create an upstream `master` branch on the upstream (`git push origin master`) *and* will record `origin/master` as a remote tracking branch so that the local branch `master` will be pushed to the upstream (origin) `master` (upstream branch). Since Git 1.7.11, the default push policy is `simple`: push only the current branch, and only if it has a similarly named remote tracking branch on the upstream. [Link](https://stackoverflow.com/questions/17096311/why-do-i-need-to-explicitly-push-a-new-branch/17096880#17096880) for an explanation.
- [Why do I have to `git push --set-upstream origin <branch>`?](https://stackoverflow.com/questions/37770467/why-do-i-have-to-git-push-set-upstream-origin-branch)
- Reasons for not keeping the repository in Dropbox: there is a chance of conflicts between the syncing of Dropbox and GitHub, and the space limit in Dropbox might be an issue when the project grows in size.
- Reasons for having a project for each chapter: GitHub has a limit of 1 GB per project and has limits of 100MB per file, keeping them separate minimizes these issues.
- To understand GitHub from scratch: Healey (intuitively explains Git workflow); Youtube videos by Learn Code show the basic workflow; Pinter (2019) explains benefits and gives recommendations; Sviatoslav (2017); Notes by Fernández-Villaverde complement/reinforce the previous one; StackExchange links for clarification, reinforcement and understanding the daily workflow.
- It is recommended to include a license file in your repositories, or at least explicitly claim copyright by including: Copyright [yyyy] [name of copyright owner].
- [Working with large files](https://help.github.com/en/articles/working-with-large-files)
- [Ignoring files](https://help.github.com/en/articles/ignoring-files)
- [Rename a repository](https://help.github.com/en/articles/renaming-a-repository)
- [Relocate a local repo](https://stackoverflow.com/questions/11384928/change-git-repository-directory-location)

### Solving Issues
See history of local commits
```bash
$ git log
```

See history of remote commits
```bash
$ git log HEAD..origin/brach_name
```

To remove a big file [wrongly committed](https://thomas-cokelaer.info/blog/2018/02/git-how-to-remove-a-big-file-wrongly-committed/)
```bash
$ git filter-branch --tree-filter 'rm -rf Codes/Pre-Analysis/struct_data.mat' HEAD
$ git push
```

It may cause the local and remote branches to diverge, in which case (see [this](https://stackoverflow.com/questions/2452226/master-branch-and-origin-master-have-diverged-how-to-undiverge-branches) and [this](http://serebrov.github.io/html/2012-02-13-git-branches-have-diverged.html))
```bash
$ git rebase origin/code/ans/fit-models
```




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

- Course on Debt Instruments and Markets(zeros, convexity, FRAs, repos, swaps, RNP, hedging, caps, floors, options, futures)
http://people.stern.nyu.edu/jcarpen0/courses/b403333/

- Stock & Watson Summer Course
https://www.nber.org/minicourse_2008.html

How to reset SMC & PRAM and fix 99% of Mac problems
https://trendblog.net/mac-shutting-down-smc-pram-fix/

