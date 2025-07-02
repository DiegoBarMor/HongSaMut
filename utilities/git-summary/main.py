import os, sys
import pandas as pd
from pathlib import Path

def parse_log(log):
    dates = []
    authors = []
    messages = []
    waiting_message = True
    for line in log.split('\n'):
        if not line: continue

        if line.startswith("Date:"):
            date = line[5:].strip()
            dates.append(date)
            waiting_message = True

        elif line.startswith("Author:"):
            author = line[7:].strip()
            authors.append(author)

        elif line.startswith("    "):
            message = line[4:]
            if waiting_message: # dealing with a new message
                messages.append(message)
                waiting_message = False
            else: # dealing with a continuation of the previous message
                messages[-1] += "[NEWLINE]" + message


    return dates, authors, messages


FOLDER_ROOT = Path(sys.argv[1])
FOLDER_CWD = Path(os.getcwd())
PATH_TMP = FOLDER_CWD / "log.tmp"
PATH_OUT = FOLDER_CWD / "repos.csv"

print(f"Inspecting {FOLDER_ROOT}...")

data = {"date": [], "repo": [], "author" : [], "message": []}
path_repos = [FOLDER_ROOT / git.parent for git in FOLDER_ROOT.rglob("*.git/")]

for path_repo in path_repos:
    path_absolute = path_repo.resolve()
    path_short = path_repo.relative_to(FOLDER_ROOT)

    status = os.system(f"cd {path_absolute}; git log --date=format-local:'%Y/%m/%d-%H:%M:%S' > {PATH_TMP} 2>&1")

    if status != 0:
        print(f"XXX Error: {path_short} is not a git repository.")
        continue

    print(f">>> Repo found: {path_short}")

    with open(PATH_TMP, 'r') as file:
        log = file.read()

    dates, authors, messages = parse_log(log)
    repos = [path_short for _ in authors]
    data["date"].extend(dates)
    data["repo"].extend(repos)
    data["author"].extend(authors)
    data["message"].extend(messages)


df = pd.DataFrame(data)
df.sort_values(by = ["date"], ascending = False, inplace = True)
df.to_csv(PATH_OUT, index = False)
os.remove(PATH_TMP)
