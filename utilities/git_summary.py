import os, sys
import pandas as pd
from pathlib import Path

def parse_log(log: str):
    commits = []
    dates = []
    hours = []
    authors = []
    messages = []
    changes = []
    waiting_message = True
    waiting_changes = True
    for line in log.split('\n'):
        if not line: continue

        if line.startswith("commit"):
            commits.append(line.split()[1])
            waiting_message = True
            waiting_changes = True
            continue

        if line.startswith("Date:"):
            date_hour = line[5:].strip()
            date,hour = date_hour.split('-')
            dates.append(date)
            hours.append(hour)
            continue

        if line.startswith("Author:"):
            author = line[7:].strip()
            authors.append(author)
            continue

        if line.startswith("    "):
            message = line[4:]
            if waiting_message: # dealing with a new message
                messages.append(message)
                waiting_message = False
            else: # dealing with a continuation of the previous message
                messages[-1] += "[NEWLINE]" + message
            continue

        if line[0] != " ":
            words = line.split()
            kind_change = words[0]
            file_changed = " ".join(words[1:]) # just in case the file name has spaces
            change = f"{kind_change}//{file_changed}"

            if waiting_changes:
                changes.append(change)
                waiting_changes = False
            else:
                changes[-1] += "///" + change

    return commits, dates, hours, authors, messages, changes


FOLDER_ROOT = Path(sys.argv[1]).resolve()
FOLDER_OUT = Path(sys.argv[2]).resolve() if (len(sys.argv) >= 3) else None

PATH_TMP = FOLDER_ROOT / "log.tmp"

print(f"Inspecting {FOLDER_ROOT}...")

data = {"commit": [], "date": [], "hour": [], "repo": [], "author" : [], "message": [], "changes": []}
path_repos = [FOLDER_ROOT / git.parent for git in FOLDER_ROOT.rglob("*.git/")]

for path_repo in path_repos:
    path_absolute = path_repo.resolve()
    path_short = path_repo.relative_to(FOLDER_ROOT)

    status = os.system(f"cd {path_absolute} && git log --name-status --date=format-local:'%Y/%m/%d-%H:%M:%S' > {PATH_TMP} 2>&1")

    if status != 0:
        print(f"XXX Error: {path_short} is not a git repository.")
        continue

    print(f">>> Repo found: {path_short}")

    with open(PATH_TMP, 'r') as file:
        log = file.read()

    commits, dates, hours, authors, messages, changes = parse_log(log)
    if len(changes) < len(commits):
        changes.extend([""] * (len(commits) - len(changes)))

    repos = [path_short for _ in authors]
    data["commit"].extend(commits)
    data["date"].extend(dates)
    data["hour"].extend(hours)
    data["repo"].extend(repos)
    data["author"].extend(authors)
    data["message"].extend(messages)
    data["changes"].extend(changes)

os.remove(PATH_TMP)

df = pd.DataFrame(data)
df.sort_values(by = ["date", "hour"], ascending = False, inplace = True)

if FOLDER_OUT is None:
    try:
        path_tmp = FOLDER_ROOT / "repos.csv.tmp"
        df.to_csv(path_tmp, index = False)
        from prisma_csv import TUIPrismaCSV
        tui = TUIPrismaCSV(path_tmp)
        tui.run()
    finally:
        os.remove(path_tmp)

else:
    df.to_csv(FOLDER_OUT / "repos.csv", index = False)
