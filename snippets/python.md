# Python
- Assuming the python scripts are running with the current directory been the root folder of a project, this snippet will allow to import from anywhere within the project.
```python
import os, sys; sys.path.insert(0, os.getcwd()) # allow imports from root folder
```

<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
<!-- -------------------------------- CURSES ------------------------------- -->
<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
# Curses (TUI)
## Debugging
- It can be useful to debug curses apps by first defining a log function
```python
def log(*x, path_log = "log.txt", init = False):
    mode = 'w' if init else 'a'
    out = "" if init else f"{' '.join(map(str,x))}\n"
    with open(path_log, mode) as file: file.write(out)
```
- The log can then be inspected in real time, for example with `watch`.
```bash
watch -n 0.1 tail log.txt
```


<!-- ----------------------------------------------------------------------- -->
## Managing the event loop without need of user interactions
- There are two approaches:

### No-delay mode
- Call `stdscr.nodelay(True)` before the main loop.
- To control the FPS, three options are available
  1) Call `curses.napms(16)` inside the main loop (function receives *miliseconds* as argument)
  2) Call `stdscr.timeout(16)` before the main loop (function receives *miliseconds* as argument)
  3) Call `curses.delay_output(16)` inside the main loop (function receives *miliseconds* as argument)

### No-delay mode
- Call `curses.halfdelay(1)` before the main loop. This function receives *deciseconds* as argument, and it must be an integer, so 10 is the maximum FPS possible. Note that when an input is given (`stdscr.getch()`), the wait is skipped, which can cause the FPS jump to higher values.
deciseconds --> not good, goes faster when movement key is being pressed.


<!-- ----------------------------------------------------------------------- -->
## Getting multiple keys pressed at once
- normally, extra residual keys can be cleared from the buffer with `curses.flushinp()`.
```python
key = stdscr.getch()
curses.flushinp() # clear buffer
```

However, sometimes multiple keys are indeed of interest in a single frame. This approach can then be followed:

- Initialize an array of keys before the main loop.
```python
keys = np.zeros(1000, dtype = bool)
```

- Go through all the non-ERR keys from the buffer until exhausting them. Use them to update `keys`.
```python
keys.fill(False)
while True:
   key = stdscr.getch()
   if key == -1: break
   keys[key] = True
```

- Now, instead of the usual switch statement, `keys` can be use to evaluate multiple (possibly simultaneously true) conditions at once.
```python
if keys[curses.KEY_UP]:    y -= 1
if keys[curses.KEY_LEFT]:  x -= 1
if keys[curses.KEY_DOWN]:  y += 1
if keys[curses.KEY_RIGHT]: x += 1
```


<!-- ----------------------------------------------------------------------- -->
## Wrapper
```python
def wrapper(func, /, *args, **kwds):
    try:
        stdscr = curses.initscr()
        curses.noecho()
        curses.cbreak()
        stdscr.keypad(1)
        try: curses.start_color()
        except: pass
        return func(stdscr, *args, **kwds)

    finally:
        if "stdscr" not in locals(): return
        stdscr.keypad(0)
        curses.echo()
        curses.nocbreak()
        curses.endwin()
```


<!-- ----------------------------------------------------------------------- -->
