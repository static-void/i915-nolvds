### x220/x230 patches for nitrocaster or KK or similar FHD/2K mod boards

This fixes the following issues:
1. Extra "ghost" LVDS output
2. Brightness controls don't work
3. Laptop doesn't sleep properly when the lid is closed
4. VTs may not work

Notes:
* With 1vyrain you can disable LVDS, which fixes the ghost output, but the internal DP still doesn't appear as eDP and only presents one resolution, and the other issues are still present.
* With non-nitrocaster boards this will not fix the brightness controls, but it does fix the other issues.

This is updated from the original here: https://github.com/alexdelifer/i915-nolvds

Changes from the original are as follows:
* Patches updated
* Changed to work on debian based distros, but hopefully still works on other distros.
* As part of the patching process the makefile will now replace the product name in `patches/i915-no-lvds.patch` with the one found in
`/sys/devices/virtual/dmi/id/board_name` (which is the same as that reported by `sudo dmidecode | grep -A3 '^System Information'`), although I find (with 1vyrain) it isn't necessary.
* Disabled DKMS as it didn't work and the patches need to be fixed at most releases anyway

### Installation
Just run `make` and then `sudo make install`.

If you get and error similar to the following on debian based distros:
  ```ERROR: Could not find linux-5.13 | cut -d- -f1)/. Move downloaded source dir to linux-5.13/ and try again```
The Makefile downloaded and expanded the linux kernel source using apt but could not figure out the name of the directory that apt expanded it to. You will find that a new directory with the kernel source has appeared in the working directory... move it to the path indicated by the error and then run `make` again.

On debian based distros you need to make sure you are on the latest revision of the kernel release available in the apt repository. For example, for 5.8.0 you currently need linux-image-unsigned-5.13.0-1014-oem. Apt will not download source for linux-image-unsigned-5.13.0-1012-oem and older.

### Todo
* Keep patches for multiple kernel versions and apply the right patches as required (currently patches are for 5.13.0)
* Experiment with changing `DMI_MATCH(DMI_PRODUCT_NAME, "XXXXXXX"),` to `DMI_MATCH(DMI_PRODUCT_FAMILY, "ThinkPad X230"),` and a separate entry for x220, so that the patches don't have to be modified for each machine, and compiled modules are portable between x330 machines.

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
