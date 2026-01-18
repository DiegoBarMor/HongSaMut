# Conda
- Installing miniconda
```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh
```

- Miscellaneous operations
```bash
conda env list                  # check the list of environments
conda list                      # check the installed packages inside the current environment
conda create --name ENVNAME     # create a new env
conda env create -f ENVNAME.yml # create a new env from a environment YAML file
conda remove -n ENVNAME --all   # delete the env
conda clean --all               # clear cache
conda env export > ENVNAME.yml  # export env specifications (optional: remove the last line, "prefix:...")
```
