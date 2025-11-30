##### TODO: review this utility

import re, sys, json
from pathlib import Path

# ------------------------------------------------------------------------------
def sep_args(args: str) -> list:
    """
    Splits the arguments of a function into a list.
    """
    if not args: return []
    args = [a.strip() for a in args.strip("()").split(',')]
    return args


################################################################################
if __name__ == "__main__":
    FOLDER_IN = Path(sys.argv[1]).resolve()
    FOLDER_OUT = Path(sys.argv[2]).resolve()

    FOLDER_OUT.mkdir(parents = True, exist_ok = True)
    PATH_JSON  = FOLDER_OUT / "definitions.json"

    definitions = {}
    for path_py in FOLDER_IN.glob("**/*.py"):
        with open(path_py, 'r') as file:
            lines = [line.split('#')[0] for line in file.readlines()]

        current_class = ''
        current_func = ''
        tokens = []
        for i,line in enumerate(lines):

            ##### CLASSES
            match = re.match(r"class\s+(\w+)\s*(\(.*\))?:", line)
            if match:
                current_func = ''
                current_class = match.group(1)
                parent = sep_args(match.group(2))
                data = ("cls", i, current_class, parent)
                tokens.append(data)
                continue

            ##### FUNCTIONS
            match = re.match(r"\s*def\s+(\w+)\s*(\(.*\)):", line)
            if match:
                current_func = match.group(1)
                args = sep_args(match.group(2))
                kind = "met" if current_class else "fun"
                data = (kind, i, current_class, current_func, args)
                tokens.append(data)
                continue

            ##### CLASS ATTRIBUTES
            match = re.match(r"^\s*self\.(\w+)\s*=(?!.*=).*", line)
            if match:
                var = match.group(1)
                data = ("att", i, current_class, var)
                tokens.append(data)
                continue

            ##### STATIC CLASS VARIABLES
            match = re.match(r"^\s*(\w+)\s*=(?!.*=).*", line)
            if match and current_class and not current_func:
                var = match.group(1)
                data = ("sta", i, current_class, var)
                tokens.append(data)
                continue

            ##### GLOBAL VARIABLES
            match = re.match(r"^(\w+)\s*=(?!.*=).*", line) # assumes (only) global variables start with no indentation
            if match:
                var = match.group(1)
                data = ("glo", i, var)
                tokens.append(data)
                continue


        rel_path = path_py.relative_to(FOLDER_IN)
        definitions[str(rel_path)] = tokens


    for k,v in definitions.items():
        print(k)
        print(*v, sep = '\n')
        print()

    with open(PATH_JSON, 'w') as file:
        json.dump(definitions, file)

################################################################################
