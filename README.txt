This is a script for the AutoHotKey program available from http://www.autohotkey.com/

AnyDVD and AnyDVD Ripper (the part that this script uses) come from SlySoft http://www.slysoft.com/en/anydvd.html

Specifically, the script assumes you have already opened the "Rip Video DVD to Harddisk" dialog from the AnyDVD Ripper system dray context menu

There have been threads on their forums asking for 2 things:
1) when a DVD is inserted, automatically start the backup
2) when the backup is done, automatically eject
 - http://forum.slysoft.com/showthread.php?t=36090
 - http://forum.slysoft.com/showthread.php?t=36906
 - http://forum.slysoft.com/showthread.php?t=33103

(implicit) 3) when a new disc is inserted, have it start the backup again

This way those of us with many DVD's to back up (We've lost too many to the kids causing scratches on them) can 
make it a little easier and a lot faster, since without something like this you have to remember to go check 
what the backup status is, swap the discs, then start the new backup.

As per some of the above forum threads, the likely better route is to let AnyDVD stick to just doing the decryption and
use a separate tool like ImgBurn from http://www.imgburn.com/ in order to add the functionality of auto-rip, auto-eject, etc.

This was somewhat just a proof-of-concept and gave me an excuse to download and try out AutoHotKey, but if you find it useful,
even as an example, then have at it.

Warranty: None of any kind whatsoever
License: GPL (which is GNU *General* Public License - not GNU Public License) since I started out with Adam Pash's DVD Rip and it's GPL
			http://www.gnu.org/licenses/gpl.html