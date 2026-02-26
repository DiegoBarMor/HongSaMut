# Ubuntu
<!-- ----------------------------------------------------------------------- -->
## Connecting to Eduroam
1) Select the `eduroam` network.
2) Set `Authentication` to **Protected EAP (PEAP)**.
3) Check the `No CA certificate is required` checkbox.
4) Set `PEAP version` to **Automatic**.
5) Set `Inner authentication` to **MSCHAPv2**.
6) Provide the `Username` and `Password`.

<!-- ----------------------------------------------------------------------- -->
## Dual boot issues
- https://www.howtogeek.com/323390/how-to-fix-windows-and-linux-showing-different-times-when-dual-booting/
```bash
timedatectl
timedatectl set-local-rtc 1 --adjust-system-clock
```

<!-- ----------------------------------------------------------------------- -->
## About portable Ubuntu installations
- https://askubuntu.com/questions/1300454/easy-full-install-usb-that-boots-both-bios-and-uefi
- https://askubuntu.com/questions/1217832/how-to-create-a-full-install-of-ubuntu-20-04-to-usb-device-step-by-step
- https://askubuntu.com/questions/343268/how-to-use-manual-partitioning-during-installation

<!-- ----------------------------------------------------------------------- -->
