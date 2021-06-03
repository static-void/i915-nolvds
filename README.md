Updated from the original here: https://github.com/alexdelifer/i915-nolvds

Patches updated to work on 5.4.0.
Changed to work on debian based distros, but hopefully still works on other
distros.

Worth noting that if you installed 1vyrain you can choose to have the BIOS
disable LVDS when you do the installation, but the internal DP still doesn't
appear as eDP, brightness controls still don't work, and for me the laptop
doesn't sleep properly when the lid is closed. This fixes those issues.

You may need to replace the code `20SAVHY877` from patches/i915-no-lvds.patch
with your own product name (based on `dmidecode | grep -A3 '^System
Information'`), although I find (with 1vyrain) it isn't necessary.

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
