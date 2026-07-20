- download a file:
```bash
	pdb=1AKX
	curl https://files.rcsb.org/download/$pdb.pdb.gz --output $pdb.pdb.gz
	curl https://files.rcsb.org/download/$pdb.pdb    --output $pdb.pdb
```

- replace CRLF with LF:
```bash
find . -type f -not -path './.git*' -not -path './node_modules*' | xargs sed -i 's/\r//g'
```
(source: https://foldingair.blogspot.com/2018/02/converting-crlf-to-lf-for-all-files-in.html)

- inspect binaries
```bash
xxd -R always $path_in | less -R 
```

- replace a substring in a line
```bash
string="1;2;3"
delim=";"
repl=","
echo ${string//$delim/$repl}
# newstr=${string//$delim/$repl}
```

- split a line into a substrings array and select from it with an index
```bash
string="a/b/c"
delim="/"
idx=1
arr=(${string//$delim/ })
echo ${arr[$idx]}
```

- range of numbers coming from a variable
```bash
nframes=100
eval echo {1..$nframes..20} 
for i in $(eval echo "{1..$END}"); do echo $i; done
```

# Others
```bash
rm -f .[!.]*.npz .[!.]*.lock
```

```bash
hostnamectl
```
