# Simple Ventoy Guide
## Installing Ventoy
1) Download the current installation source from Ventoy's [official website](https://www.ventoy.net/en/download.html) and unpack its contents. In Linux:
```
cd ~
wget https://sourceforge.net/projects/ventoy/files/v1.1.02/ventoy-1.1.02-linux.tar.gz/download -O ventoy.tar.gz
tar -xvzf ventoy.tar.gz
rm ventoy.tar.gz
```

2) Insert the USB device, for example a flash-drive of at least 16 GB (just to make sure).

3) Execute the respective installation binary by double-clicking, or alternatively something like:
```
cd ventoy-1.1.02
./VentoyGUI.x86_64
```

4) Under `device`, select the USB device of interest. Than click `Install` and confirm. You can close the installation program once it finishes.


## Using Ventoy
1) Download any installation `ISO` images and place them in the Ventoy USB drive. Make sure to prioritize USB booting at startup. The Ventoy USB drive should be ready to use now.


## [Persistence](https://www.ventoy.net/en/plugin_persistence.html)
1) Prepare the Ventoy folders
```
cd /media/dbm/Ventoy # example path for the Ventoy USB drive
mkdir -p persistence ventoy
touch ventoy/ventoy.json
```

2) Create the persistence data file using the script provided in the installation folder.
```
cd ~/ventoy-1.1.02
sudo ./CreatePersistentImg.sh -s 2048 # example 2GB DAT file
sudo chmod 777 persistence.dat # set permissions to Full (Read, Write & Execute)
mv persistence.dat /media/dbm/Ventoy/persistence/lubuntu-24.04.1-desktop-amd64.dat # example final path for the DAT file
```

3) Use the [VentoyPlugson](https://www.ventoy.net/en/plugin_plugson.html) utility or fill by hand the ```ventoy/ventoy.json``` file with the following structure:
```
{
    "persistence":[
        {
            "image": "/ISO/lubuntu-24.04.1-desktop-amd64.iso",
            "backend":[
                "/persistence/lubuntu-24.04.1-desktop-amd64.dat"
            ]
        }
    ]
}

```

4) The Ventoy USB drive should be ready to use with persistence now.
