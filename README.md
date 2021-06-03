x220/x230 patches for nitrocaster or KK or similar FHD/2K mod boards.

This fixes the following issues:
1. Extra "ghost" LVDS output
2. Brightness controls don't work
3. Laptop doesn't sleep properly when the lid is closed
4. VTs may not work

Notes:
* With 1vyrain you can disable LVDS, which fixes the ghost output, but the internal DP still doesn't appear as eDP and only presents one resolution, and the other issues are still present.
* With a non-nitrocaster boards this will not fix the brightness controls, but it does fix the other issues.

This is updated from the original here: https://github.com/alexdelifer/i915-nolvds

Changes from the original are as follows:
* Patches updated to work on 5.4.0.
* Changed to work on debian based distros, but hopefully still works on other distros.
* As part of the patching process the makefile will now replace the product name in `patches/i915-no-lvds.patch` with the one found in
`/sys/devices/virtual/dmi/id/board_name` (which is the same as that reported by `sudo dmidecode | grep -A3 '^System Information'`, although I find (with 1vyrain) it isn't necessary.

Original readme text follows:

# i915-nolvds

For use with x220/x230 nitrocaster or K.K. fhd mod. If you want to disable LVDS ghost display in linux, this is what you want. 

It's really simple, instead of rebuilding your kernel every time there's an update, or being locked in to using just 1 kernel, now you can just rebuild this i915 against your own kernel headers.

There's two ways you can install this, DKMS or just plain make. To use dkms, you must have it installed.

### DKMS

```
sudo ./dkms-install.sh
reboot # so module can load
```

### Make
```
make
sudo make install
reboot # so module can load
```
## Did it load?
How do I know it worked?

You won't have an unreachable first monitor, but you can run this to be sure.
``` 
$ dmesg | grep i915
[    1.150666] i915: loading out-of-tree module taints kernel.
```
## Uninstalling

Don't like it? No problem.

### DKMS
```
sudo ./dkms-remove.sh
```

### Make
```
sudo make uninstall
```

Note: This was tested on Arch Linux on a K.K. X220 from Taobao, your mileage may vary.
