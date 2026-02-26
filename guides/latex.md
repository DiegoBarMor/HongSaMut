- Installing LaTeX in Ubuntu:
```bash
sudo apt install texlive -y && sudo apt-get install dvipng texlive-latex-extra texlive-fonts-recommended cm-super -y
# sudo apt install chktex -y ### optional: semantic checker (i.e. for using linters)
```

- Compiling into PDF:
```bash
pdflatex -interaction=nonstopmode -halt-on-error path_to_file.tex
```
