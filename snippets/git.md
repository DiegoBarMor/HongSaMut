- Fix commit signature / date from specific commits
```bash
git config --local user.name "Diego Barquero Morera"
git config --local user.email diego.barquero-morera@phys.ens.fr

date="Sat Jun 27 21:35:13 2026 +0200"
GIT_COMMITTER_DATE="$date" git commit --amend --reset-author --no-edit
git commit --amend --date="$date" --no-edit
GIT_COMMITTER_DATE="$date" git commit --amend --no-edit

# https://stackoverflow.com/questions/454734/how-can-one-change-the-timestamp-of-an-old-commit-in-git
```
