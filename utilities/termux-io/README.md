# Easy transfer of Termux content between devices

## Setup

### Android
1) Install Termux from F-Droid. Run the app.
2) Run the following in the console:
```
termux-setup-storage
mkdir storage/shared/TermuxIO
```
3) The new folder `TermuxIO` should now be accessible in any File Manager app (Matieral Files from F-Droid is recommended). Place `termux_io.sh` in this `TermuxIO` folder.
4) Open Termux and move the `termux_io.sh` file into the termux home folder. It has to be exactly in this folder, so the script can recognize that it's inside the actual termux environment.
```
pwd # make sure that this corresponds to /data/data/com.termux/files/home
mv storage/shared/TermuxIO/termux_io.sh termux_io.sh
```
5) `termux_io.sh` (and Termux in general) is now ready to use.

### PC
1) Place the `termux_io.sh` script inside any folder. Create a subdirectory called `TermuxIO` inside said folder.
2) `termux_io.sh` is now ready to use.


## Usage
WIP
