# macSpleef
Windows PowerShell Mac Spoof Script(s)
These where made as a project that was more-or-less for fun. 

# ChangeMac_IntWi-Fi.ps1:
Provides CLI to change MAC address to random or specified address with an option of picking from a switch-case pool of manufacturer prefixes.
Once confirmed, it will disable the Wi-Fi device, write the new MAC to the registry, re-enable it, and verify that the changes where successful.

# ChangeMac_IntWi-Fi_Loop.ps1:
Is basically ChangeMac_IntWi-Fi but more randomization focused with looping ability that will loop until it was able to successfully rotate through the specified number of mac addresses.
Also, if it determines that the prefixes specified in the switch-case statement do not work than it will automatically switch to being completely random.

# If the following error shows up but the script still seems to work, its fine; it just kinda does that.
```
Get-ChildItem : Requested registry access is not allowed.
At C:\Users\foxx1\Desktop\ChangeMac_IntWi-Fi_Loop.ps1:73 char:5
+     Get-ChildItem $regPath | ForEach-Object {
+     ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...318}\Properties:String) [Get-ChildItem], SecurityEx
   ception
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.GetChildItemCommand
```
