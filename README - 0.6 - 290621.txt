Just Another Framework - JAF - V0.5.1 - README FILE

AUTHOR: Chris HAWKINS
Staffordshire University
CONTACT: hawkins.chris@outlook.com

SUPERVISOR: Dr Mohamed HASSAN

Introduction:
JAF is a frontend interface and triage tool designed to simplify and automate the forensic analysis of volatile memory via the Volatility Framework.
The functionality of the tool is provided by Volatility, and JAF manages the user interaction .

REQUIREMENTS:
BASH Shell
Volatility Framework (latest version)
Zenity tool

All of these requirements can be installed, checked and located to the correct location by running the JAFINSTALLATION script as root - this is provided in the JAF distro.

INSTALLATION:
** ENSURE THAT THE INSTALL SCRIPT IS RUN FROM THE JAF DIRECTORY **

Git Clone the JAF files to the / directory of your machine - /jaf should be created from the git clone command.

Within the JAF files, there is a file called JAFINSTALLATION - run this as SUDO to install JAF - even if you have all of the requirements installed already, please run the script. This will not install duplicates, it will install the pathways that are required for JAF to run.
ENTER THE INSTALL SCRIPT WITH AN EDITOR AND UNCOMMENT OUT YOUR DISTRO TO INSTALL.
** DO NOT RUN AS ROOT ACCOUNT - RUN AS SUDO - JAF AND ZENITY WILL NOT FUNCTION FROM ROOT ACCOUNT. **
If you get the following error:

Unable to init server: Could not connect: Connection refused

(zenity:22434): Gtk-WARNING **: 20:03:27.168: cannot open display:
Unable to init server: Could not connect: Connection refused

(zenity:22437): Gtk-WARNING **: 20:03:27.715: cannot open display:
No file selected. Closing.

Then you are running as root. Switch to standard user account.

Next, you can either download the standalone Volatility installation, or git clone and install volatility.
FOR THE STANDALONE:
Navigate to: https://www.volatilityfoundation.org/releases and download the latest standalone release for LINUX. Save this to /home/user/volatility (This directory is - for this version - absolute. JAF will not run with this saved elsewhere.)

FOR THE GIT CLONE (Py) VERSION:
run sudo git clone www.github.com/volatilityfoundation/Volatility
Wait for it to copy and then follow the installation instructions.

That's it!
JAF will automatically detect what installation is in use and will run accordingly.
If the installation cannot be detected for any reason, then the option to manually specify this will automatically appear.

PLEASE NOTE THAT AT THIS TIME, JAF ONLY RUNS FOR VOLATILITY 2.6, VOLATILITY 3 IS NOT YET SUPPORTED - THIS WILL BE ADDED TO A LATER VERSION.

USAGE:
JAF is run by calling "jaf" either from any location, or most reliably from the jaf installation directory. It is a BASH script so if this has been installed and will be used without following the installation script, then this is used with the syntax ./jaf.sh - the tool will then run. Ensure that you have done chmod +x jaf.sh first.

JAF is primarily a command line tool that is created as a BASH script, with a simple GUI provided by the Zenity tool.
JAF can be called from any location (when installed with the provided installation script) and does NOT require sudo privileges to run.
When calling JAF, type jaf into the command line from any location - JAF will print information to the command line and request user input via pop-up boxes that will appear in the middle of your screen.
JAF output is via files that are saved into a new directory that is created at the location that the user specifies when the command is run. Documents that are saved will be saved to this location in the following format:
[OUTPUTNAME].[COMMANDRUN].txt
In the case of manual commands, these will be saved with the [COMMANDSPECIFIED.MANUAL].txt format so that different commands can be differentiated.
At this time, only one command can be run at a time. This will be addressed in later versions. However, the tool repeats and so there is no need to go through the whole thing again. When finished, please ensure that you use the QUIT&SAVE option rather than just cancelling and cancelling may mean that data is lost.
When the tool completes, the user is asked whether the files and directory created should be saved, and also whether the HASH should be saved.
If YES is selected, all files are saved.
If NO is selected, no files are saved.

PROFILE GENERATION:

** NOTE:  Profile generation can take some time, and therefore it is recommended to save the profile when it has been generated in case of future requirement. **

In order for Volatility, and therefore JAF, to function - a profile must be located for the target sample, if it is not known. If the user knows the profile designation then this can be entered at the relevant time, if this is NOT known, then JAF will attempt to locate this in several stages, including IMAGEINFO and KDBGSCAN - if a profile is obtained from IMAGEINFO then this is automatically carved and will be used in the rest of the analysis - this is the method employed in the first instance.
If IMAGEINFO is not successful at obtaining a profile, or there is another error - this may indicate that the wrong profile has been used or that a profile could not be located. In this event, JAF will present the option to attempt a KDBGSCAN of the target file in an attempt to locate potential profiles. If the user selects yes, then the scan will be conducted and the relevant information obtained and carved, this will then be saved as [OUTPUT].potprofiles.txt. If KDBGSCAN is successful in obtaining several profiles, a method of differentiation that can be used by checking the PSActionProcessHead and PSLoadedModuleList - if several profiles are suggested, but these 2 lists state 0 next to them, then this profile can be ignored and another selected.
Once this carving is complete, JAF will ask the user if they wish to manually review this and pick a profile to test, or whether JAF is to automate this process.
If MANUAL is selected then JAF will save this to [OUTPUT].potprofiles.txt for review in line with the above guidance re PSActionProcessHead and PSLoadedModuleList.
If GUESS is selected, then JAF will automatically review the suggested profiles, and filter out those with 0 under PsA and PsL. The located profile suggestions will then be attempted. To ensure that this process does not take a disproportionate amount of  time, this is limited to 2 suggestions - if this is successful then the rest of the tool carries on with the located profile, which can be saved as normal following the on-screen prompts.
If this is NOT successful, the final attempt is to use the known details of the target system to attempt to locate a profile. The user will be asked to state whether they want to try this approach, if NO then the tool will close with the located potential profiles saved as above.
If YES, then the user will be prompted on screen for the known details of the target, which will then be tried. The user will be informed whether this is successful or not - if successful, the tool will continue and if not then the tool will save any potential profiles located and close as there is no further option available - FAILURE AT THIS STAGE MEANS THAT TRIAGE IS NOT POSSIBLE AND THEREFORE THE IMAGE FILE WILL REQUIRE IN DEPTH FORENSIC INVESTIGATION VIA THE TOOL OF CHOICE.

For clarity, a flowdiagram of the profile generation process is as follows:

PROFILE KNOWN -> Entered by user -> Tool continues with normal functioning.

PROFILE UNKNOWN -> Imageinfo scan -> Success -> Profile loaded, optionally saved and tool continues.
                                 \
                                  -> Unsuccessful -> KDBGSCAN -> User asked for manual or automated review -> Manual -> Suggestions saved and tool closes.
                                                                      \
                                                                        -> Automated -> JAF carves profile suggestions and filters on PsA / PsL -> Success -> Tool continues
                                                                                                                                                  \
                                                                                                                                                   -> Fail -> User prompted for target info -> Success -> Tool continues.
                                                                                                                                                                                            \
                                                                                                                                                                                             -> Fail -> Analysis req'd.
LINUX and MAC systems, and when all else fails:
When conducting profile guessing operations that are outlined above, the user may receive the message to check this document as they are analysing a MAC or LINUX system - or all the above processes may fail.
The functioning of Volatility means that there are limited potential or suggested profiles within the tool for LINUX and MAC systems, and therefore profile generation may not be successful. Even if the target is Windows, the profile of the image may not be located. In these eventualities then the following procedures can be undertaken:
- Ascertain the details of the target system e.g. Linux, Debian, CentOS, RedHat, Mac OSX etc.
- Locate a profile online for the given system (these are available on Google etc.)
- Create a folder within the filesystem with the structure: /plugins, /overlays or /linux (whichever you choose)
- Save the ZIP file containing the profile to this new location.
- Run the command: /volatility --plugins=[NEWLOCATION] --info
- Then run volatility manually with the following syntax:
/volatility -f [FILE] --plugins=. --profile=[THEPROFILEFOUND] [COMMAND]

In a future version of JAF this will be possible automatically.

DATA ASSURANCE:
Data assurance is a key aspect of any forensic process.
JAF does not contain any known functionality that would affect the target image that is provided, however, as a failsafe the SHA256 algorithm is used to generate a HASH value for the file before any other action is taken, and once all operations are completed then this value is checked again using the same algorithm.
If the output of this is OK then the hash function has confirmed that there has been no alteration.
If the output of this is FAIL then there has been some alteration.
To address the second outcome, it is advised to always run JAF against a forensic copy of the source image file, and if a FAIL is recorded then the operation can be attempted again with a clean copy to ensure that this was an error and is not repeated. If this is repeated then please contact the author (contact at the beginning of this file).

ACCEPTED FILE TYPES:
JAF accepts all file types that can be read by the Volatility Framework.
Some examples of accepted file types are as follows:
.RAW
.VMEM
.VMSS
.VMSN
Crash Dumps
Page Files
Raw linear sample (dd)
Hibernation file (from Windows 7 and earlier)
VirtualBox ELF64 core dump
VMware saved state and snapshot files
EWF format (E01)
LiME format
Mach-O file format
QEMU virtual machine dumps
Firewire
HPAK (FDPro)
[Not an exhaustive list]

COMMANDS:
In this version of JAF there are 7 command options.
CUSTOM COMMANDS AVAILABLE:
PWHASH - This command will check the hivelist for the given target, carve the memory location for the SAM module and pass this memory address to the hashdump function - the output of this will be any known usernames and password hashes. This will be saved into a txt file for future use - NOTE: JAF does not contain an in-built hash cracker, and therefore this file will need to be manually passed to a password cracker of the user's choice.

HP - This command will check the psxview option from Volatility and carve out processes that are listed as TRUE in PSSCAN and FALSE in PSLIST - this indicates that although the process is running and is present on the device that was imaged, it is "hidden" and was not visible by the usual methods e.g. Task Manager - this could indicate that the process is malware and therefore is worthy of further investigation and analysis. This output is a txt file with full information about the processes matching this criteria.

MALFIND - This command runs the MALFIND command from Volatility, identifying and showing processes that contain hidden or injected code.

SUSPROC - This command combines the results of HP with SOCKSCAN to show hidden processes that are communicating on the network. The situations wherein a hidden process should have network connectivity and access, and be communicating on that network, are limited and therefore processes that meet this criteria are considered to be suspicious. The output of this command will be a txt file with process information about processes that meet this criteria.

SOCKSCAN - This runs the SOCKSCAN command to ascertain information about the network connectivity of the system and which processes are communicating on the network from the imaged device. The output of this will be a txt file with information about processes that are communicating on the network.

** WIP - DO NOT USE ** - HARDWARE - This command obtains any available hardware information stored on the volatile memory of the target image. The output is a txt file with information about the hardware of the device.

HPDLLDUMP - This obtains the memory offset for the DLLs that are in use by hidden processes and creates a specific folder within the given OUTPUT directory. It then obtains copies of every DLL associated with any hidden process automatically and loads them to this location for analysis if required.

** WIP - DO NOT USE ** - CON - Runs the CONSOLES volatilty command to attempt to extract command history from the given image.

MANUAL - This command will prompt the user to enter any command within Volatility that they choose and also asks the user if there is a switch that they want to specify. The results of the entered command will then be saved to a file named .manual.txt.
