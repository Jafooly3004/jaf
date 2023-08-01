#!/bin/bash

#HELP OPTION
if [[ "$1" == "-h" ]]; then
  echo " "
  echo "Just Another Framework (JAF) v1.0 - HELP"
  echo "Useage: jaf.sh from CLI & follow input prompts"
  echo " "
  echo "REQUIREMENTS: zenity, volatility."
  echo " "
  echo "JAF - Automated Volatile Memory Triage - Uses the VOLATILITY FRAMEWORK for analysis."
  echo " "
  echo "OUTPUT FORMAT: The tool asks the user for a name, then outputs reports in the format of OUTPUTNAME.COMMAND.txt within a directory that is selected by the user at the beginning of the tool."
  echo " "
  echo "COMMANDS:"
  echo "Triage - This command will generate an output report containing the following information: SHA256 Hash value for data assurance, Username information, LM Password Hashes, Local IP information, Hidden Process information, Suspicious Process information, Network Connection information, Hidden / injected code information."
  echo "PWHASH - Generates report of any available usernames, and hashes of passwords in LM format."
  echo "HP - Locates processes that are likely to be HIDDEN within the system, which is a good indication that they may be malicious"
  echo "MALFIND - Locates processes that contain likely hidden or injected code as part of their executable. This is a good indication of malware."
  echo "SUSPROC - Located processes that are hidden on the system, but also communicating on the network. This would be a strong indicator that the process requires further investigation."
  echo "NETWORK - Obtains network information showing which processes in use on the machine are communicating on the network and on which port they are communicating. Also shows the PID of that process."
  echo "HPDLLDUMP - Locates all DLL files that are associated with hidden processes and automatically dumps these DLL files to a specific directory for analysis"
  echo "CON - Locates any available CLI history for the machine"
  echo "NAMEDPROCINFO - Locates relevant process information for a given process name."
  echo "IPFINDER - Locates any available local IP information for the machine that was imaged."
  echo "NAME - Locates the given Computer Name from within the registry hive of the imaged machine."
  echo "METERTRACE - Locates any trace of the METERTERPRETER shell on the machine and prints available information on the likely infected process."
  echo "FILERECORDSEARCH - Locates information on data or information within a given MFT record address."
  echo "VADCHECKER - Checks VAD Nodes for protection status and information for a given memory address, or memory address range."
  echo "SCRIPTCHECK - Checks to see if there are any processes running a given extension, for example .vbs"
  echo "TIMEDATE - Checks to see what processes were running on the imaged machine at the given date / time - SPECIFIC FORMAT REQUIRED - SEE POPUP."
  echo "MANUAL - Allows the user to enter whatever volatility command they wish to run, along with any switches or modifiers, to simplify to process of general Volatiltiy use."
  echo " "
  echo "This is BASIC help only. Please see provided README file for additional, in-depth, help and explainations."
  exit 0
else
  echo "For help, type -h in CLI."
fi

echo "JAFSYS - C"
echo "VERSION: 1.0"
echo "
╱╱╭┳━━━┳━━━╮
╱╱┃┃╭━╮┃╭━━╯
╱╱┃┃┃╱┃┃╰━━╮
╭╮┃┃╰━╯┃╭━━╯
┃╰╯┃╭━╮┃┃
╰━━┻╯╱╰┻╯
"
zenity --info --title "Just Another Framework [JAF] - Version 1.0" --text "JAF - DISCLAIMER: This script is designed to act as a TRIAGE TOOL ONLY it is not a replacement for analysis. \n \nEscape sequence is Ctrl+C \n \nPlease press OK to accept and continue. \n Type jaf.sh -h from the terminal for help." --width=350 --height=150
sleep 0.2
TOTALSTART="$(date +%s)"

#USER INPUTS

FILE=$(zenity --file-selection --title "REQUIRED: Please specify target file for analysis:" --filename=/jaf/)
case $? in
  0)
  echo "Selected target is $FILE.";;
  1)
  echo "No file selected. Closing."
  exit 0;;
  -1)
  echo "An unexpected error occurred.";;
esac

OUTPUT=$(zenity --entry --title "Output Specification" --text "REQUIRED: Please enter filename for output \n(this will create a directory with this name and save all created outputs to this location):")

if [[ ! "$OUTPUT" != *[^[:alnum:]/_.]* ]];
then
  zenity --error --title "Input Error" --text "ERROR: \nInvalid characters entered, the following characters are valid: A-Z 0-9 - / ." --width=350 --height=150
  exit 0
fi

case $? in
  0)
  zenity --info --title "Just Another Framework [JAF]" --text "Output files will begin $OUTPUT followed by .[command]" --width=350 --height=150;;
  1)
  zenity --info --title "Just Another Framework [JAF]" --text "No output specified. Closing." --width=350 --height=150
  exit 0;;
  -1)
  echo "An unexpected error occurred.";;
esac

zenity --question --title "DIRECTORY CREATION" --text "Is this the first examination of the target image?" --no-wrap --ok-label "Yes" --cancel-label "No"
  case $? in
    0)
    mkdir $OUTPUT
    cd $OUTPUT
    DIRECTORY=$(pwd)
    zenity --info --title "Just Another Framework [JAF]" --text "New directory is $DIRECTORY. \nAll created files and folders will be saved to this location." --width=350 --height=150 ;;
    1)
    DIRECTORY=$(zenity --file-selection --directory --title "Please specify the Directory to store files:" --filename=/jaf)
    zenity --info --title "Just Another Framework [JAF]" --text "Working directory is $DIRECTORY. \nAll created files and folders will be saved to this location." --width=350 --height=150
    cd $DIRECTORY ;;
    -1)
    echo "An unexpected error occurred. Please try again. If error persists, please see README and contact author."
    exit 0 ;;
  esac

#VOLATILITY INSTALLATION SELECTION
echo "Determining volatility installation type..."
vol.py -h &> /dev/null
if [[ $? == 0 ]];
then
  volatility=$"vol.py"
  echo "SUCCESSFUL: Python Installation Detected."
  zenity --info --title "INSTALLATION DETECTION" --text "Python installation detected and used." --width=350 --height=150
else
  ./volatility -f /jaf/test.vmem pslist &> /dev/null
  if [[ $? == 0 ]];
  then
    volatility=$"./volatility"
    echo "SUCCESSFUL: Standalone Installation Detected."
    zenity --info --title "INSTALLATION DETECTION" --text "Default standalone installation detected and used." --width=350 --height=150
  else
    '/home/user/volatility/volatility' -f /jaf/test.vmem pslist &> /dev/null
    if [[ $? == 0 ]];
    then
      volatility=$"/home/user/volatility/volatility"
      echo "SUCCESSFUL: Custom Standalone Installation Detected."
      zenity --info --title "INSTALLATION DETECTION" --text "Custom standalone installation detected and used." --width=350 --height=150
    else
    volatility=$(zenity --entry --title "INSTALLATION DETECTION" --text "Automatic Detection Failed. \nREQUIRED: Please enter the full pathway of your volatility script:")
    $volatility -f /jaf/test.vmem pslist &> /dev/null
      if [[ $? == 0 ]];
      then
        echo "SUCCESSFUL: Manual Location Confirmed."
        zenity --info --title "INSTALLATION DETECTION" --text "Installation location confirmed. Proceeding."
      else
        zenity --entry --title "INSTALLATION DETECTION" --text "ERROR: Could not locate installation. Please check pathway and re-enter."
          volatility=$(zenity --entry --title "INSTALLATION DETECTION" --text "REQUIRED: Please enter the full pathway of your volatility script:")
            if [[ $? == 0 ]];
            then
              zenity --info --title "INSTALLATION DETECTION" --text "Installation location confirmed. Proceeding." --width=350 --height=150
            else
              echo "FAILED: Installation could not be verified. Please verify installation / pathway and try again."
              zenity --info --title "INSTALLATION DETECTION" --text "Installation location failed on second attempt. Please verify volatility tool location and retry." --width=350 --height=150
              exit 0;
            fi
          fi
        fi
      fi
fi

#DATA ASSURANCE

HASHSTART="$(date +%s)"
echo "*** DATA ASSURANCE: Generating hash for target file. ***"
sha256sum $FILE > $OUTPUT.sha256.txt
HASH="$(cat $OUTPUT.sha256.txt)"
hashend="$(date +%s)"
DURATIONHASH=$[ ${hashend} - ${HASHSTART} ]
echo "*** DATA ASSURANCE: The SHA256 Hash for the provided file is: $HASH ***"
echo "Hash generation took $DURATIONHASH (secs)"

#PROFILE LOCATION SECTION
#PROFILE LOCATION

echo " "
echo "-------------------- JAF --------------------"
echo " "
zenity --question --title "PROFILE GENERATION" --text "Do you know the profile of the specified target?" --no-wrap --ok-label "Yes" --cancel-label "No"
  case $? in
    0)
      PROFILESTART="$(date +%s)"
      zenity --question --title "PROFILE GENERATION" --text "Do you want to type out the profile, or is it stored in a file?" --no-wrap --ok-label "Type" --cancel-label "File"
      case $? in
        0)
          PROFILE=$(zenity --entry --title "Profile Specification" --text "Please enter profile:")
            if [[ ! "$PROFILE" != *[^[:alnum:]]* ]];
              then
                zenity --error --title "Input Error" --text "ERROR: \nInvalid characters entered, the following characters are valid: A-Z 0-9" --width 350 --height 150
                exit 0
              fi;;
        1)
          PRODOC=$(zenity --file-selection --title "Please specify the Directory to store files:" --filename=/jaf)
          PROFILE=$(cat $PRODOC)
        esac
        ;;
    1)
      PROFILESTART="$(date +%s)"
      echo "Locating appropriate profile for image. Please wait. This could take some time."
      PROFILE=$($volatility imageinfo -f $FILE | grep Profile | awk '{print $4}' | sed 's/,*$//g')
      IMAGEINFOPROFILEEND="$(date +%s)"
      IMAGEINFOPROFILETIME=$[ ${IMAGEINFOPROFILEEND} - ${PROFILESTART} ]
      echo "Imageinfo profile location took $IMAGEINFOPROFILETIME (secs)";;
   -1) echo "An unexpected error occurred, please try again."
       exit 0;;
   esac

   #PROFILE FAILURE GUESSING
        #KDBG ATTEMPT
        #IF ONE (KDBG)
            if [ "$PROFILE" == "No" ];
            then
              KDBGSTART="$(date +%s)"
              echo "ERROR: Profile could not be located."
                zenity --question --title "PROFILE GENERATION" --text "IMAGEINFO Profile generation failed - do you want to try KDBGSCAN to locate potential profiles?" --no-wrap --ok-label "Yes" --cancel-label "No"
                #CASE ONE
                case $? in
                  0) zenity --question --title "PROFILE GENERATION" --text "Do you want to review potential profiles manually (see README), or for JAF to guess the most likely profile and test it?" --no-wrap --ok-label "Manual" --cancel-label "Guess"
                        #CASE TWO
                        case $? in
                          0) echo "Generating potential profiles. Please wait."
                          $volatility -f $FILE kdbgscan | grep 'Profile\|PsA\|PsL' > $OUTPUT.potprofiles.txt
                          echo "Potential profiles saved. Please review $OUTPUT.potprofiles.txt and determine profile for entry. Please see README for guidance and information."
                          exit 0;;
                          1) echo "Guessing most likely profile. Please wait, this could take some time. All potential profiles will be saved to $OUTPUT.potprofiles.txt for future reference and use."
                          $volatility -f $FILE kdbgscan  | tee >(zenity --progress --pulsate)| grep 'Profile\|PsA\|PsL' | sed -n '/Profile suggestion/!d;h;n;/(0/d;n;//d;g;p' | awk '{print$4}' > $OUTPUT.potprofiles.txt
                          PROFILE=$(head -1 $OUTPUT.potprofiles.txt) && $volatility -f $FILE --profile=$PROFILE pslist > /dev/null
                          #IF TWO
                          if [ $? == 0 ];
                                  then
                                    echo "Profile located on first guess."
                                  else
                                    echo "First guess failed, trying second."
                                    PROFILE=$($OUTPUT.potprofiles.txt | sed '2q;d') && $volatility -f $FILE --profile=$PROFILE > /dev/null
                                    #IF THREE
                                      if [ $? == 0 ];
                                        then
                                          echo "Profile located on second guess."
                                        else
                                          zenity --question --title "PROFILE GENERATION" --text "Profile guessing unsuccessful. Do you want to try specifying the details of the system to see if there is a matching profile?" --no-wrap --ok-label "Yes" --cancel-label "No"
                                          #CASE THREE
                                          case $? in
                                            0)
                                            temp1=`mktemp -t temp1`
                                            zenity --list --radiolist --title "OS SELECTION" --text "Please select OS in use on the target at the time of imaging:" --height=350 --width=250 --column "Select" --column "Menu Item" FALSE WINDOWS FALSE LINUX FALSE MAC > $temp1
                                            selection=$(cat $temp1)
                                            #CASE FOUR
                                              case $selection in
                                              WINDOWS)
                                              VERSION=$(zenity --entry --title "PROFILE GENERATION" --text "REQUIRED: Please enter the version in use e.g. for Windows 10, enter 10:")
                                              SP=$(zenity --entry --title "PROFILE GENERATION" --text "OPTIONAL: Please enter the SP in use [Leave blank for none]:")
                                              POTPROFILE=$($volatility --info | grep "Profile" | grep "Windows" | grep "$VERSION" | grep "$SP") > $OUTPUT.manual.potprofiles.txt
                                              CARVEDPOTPROFILE=$(head -1 $OUTPUT.manual.potprofiles.txt)
                                              $volatility -f $FILE --profile=$CARVEDPOTPROFILE pslist > /dev/null
                                              #IF FOUR
                                              if [ $? == 0 ];
                                                  then
                                                    echo "Profile located as $CARVEDPOTPROFILE."
                                                    $PROFILE=$CARVEDPOTPROFILE
                                                  else
                                                    echo "Profile generation FAILED - Please see README for options." && exit 0
                                                fi;;
                                                #IF FOUR CLOSURE
                                              LINUX)
                                                echo "Manual profile location is ONLY available for Windows systems - please refer to the README for guidance on profile location."
                                                exit 0;;
                                              MAC)
                                                echo "Manual profile location is ONLY available for Windows systems - please refer to the README for guidance on profile location."
                                                exit 0;;
                                              esac
                                              #CASE FOUR CLOSURE
                                              ;;
                                            1)
                                              echo "Profile generation unsuccessful. Potential profiles have been saved. Please refer to README for next stages if analysis is still required."
                                              exit 0;;
                                            -1)
                                              echo "An unexpected error occurred. Please try again. If error repeats, please contact author."
                                              exit 0;;
                                              #CASE THREE CLOSURE
                                             esac
                                             #IF THREE CLOSURE
                                              fi
                                              #IF TWO CLOSURE
                                          fi
                                          #CASE TWO CLOSURE
                                    esac;;
                      1)
                      echo "Profile generation failed, KDBG denied by user. Closing."
                      exit 0;;
                      -1)
                      echo "An unexpected error occurred. Closing. Please try again."
                      exit 0;;
                  #CASE ONE CLOSURE
                    esac
                  KDBGEND="$(date +%s)"
                  KDBGTIME="$[ ${KDBGEND} - ${KDBGSTART} ]"
                  echo "KDBG Operation took $KDBGTIME (secs)"
                                      #IF ONE CLOSURE
                                      fi
echo "The profile of the given target file is $PROFILE."
profileend="$(date +%s)"
PROFILEDURATION=$[ ${profileend} - ${PROFILESTART} ]
echo "Profile generation operation took $PROFILEDURATION (secs)"

#SAVING PROFILE
cd $DIRECTORY
    zenity --question --title "PROFILE GENERATION" --text "Do you wish to save the profile for future use?" --no-wrap --ok-label "Yes" --cancel-label "No"
        case $? in
              0)
                touch $DIRECTORY/$OUTPUT.profile.txt && echo $PROFILE > $DIRECTORY/$OUTPUT.profile.txt && echo "Profile saved as $DIRECTORY/$OUTPUT.profile.txt"
                ;;
              1)
              zenity --info --title "PROFILE GENERATION" --text "Profile NOT saved - WARNING: Not saving profile may mean that this has to be generated every time the tool is restarted. This may take some time on each run." --width 350 --height 150
          esac

#DATA ASSURANCE FUNCTION
data_assurance () {
  echo "DATA ASSURANCE: Checking hash value of target file and comparing hashes before and after operation for any file alteration:"
  sha256sum --check $OUTPUT.sha256.txt
}

#DURATION FUNCTION
duration () {
  DURATION=$[ $(date +%s) - ${START} ]
  echo "Operation took $DURATION (sec) to complete."
}

#TRIAGE COMMAND
echo " "
echo "-------------------- JAF v0.9.3 - TRIAGE COMMAND --------------------"
echo " "
zenity --question --title "JAF v0.9.3" --text "If this is the first time reviewing this image, it is recommended that you allow JAF to conduct TRIAGE to obtain some initial information. \nDetails can be found in the README file. \nDo you want to run TRIAGE?" --no-wrap --ok-label "Yes" --cancel-label "No"
case $? in
  0)
  zenity --info --title "JAF v0.9.3 - TRIAGE COMMAND" --text "Running TRIAGE command, please note that this is TRIAGE ONLY and is not a replacement for full analysis." --height=150 --width=350
  USER=$(zenity --entry --title "JAF v0.9.3 - TRIAGE COMMAND" --text "Please enter the examiner's details:")
  EX=$(zenity --entry --title "JAF v0.9.3 - TRIAGE COMMAND" --text "Please enter any related exhibit reference for the image:")
    touch $OUTPUT.triage.txt
    echo "-------------------- EXAMINATION DETAILS --------------------" >> $OUTPUT.triage.txt
    echo "JAF v0.9 TRIAGE OUTPUT" >> $OUTPUT.triage.txt
    echo "EXHIBIT REFERENCE: $EX" >> $OUTPUT.triage.txt
    echo "TRIAGED FILE: $FILE" >> $OUTPUT.triage.txt
    echo "Volatility Profile Utilised: $PROFILE" >> $OUTPUT.triage.txt
    echo "Triage began at: " >> $OUTPUT.triage.txt
    date >> $OUTPUT.triage.txt
    echo "Examiner: $USER" >> $OUTPUT.triage.txt
    echo " " >> $OUTPUT.triage.txt
    echo "-------------------- DATA --------------------" >> $OUTPUT.triage.txt
    echo "DATA ASSURANCE : HASH Output (SHA256):" >> $OUTPUT.triage.txt
    cat $OUTPUT.sha256.txt >> $OUTPUT.triage.txt
    echo "--------------------" >> $OUTPUT.triage.txt
    echo "USERNAME AND PASSWORD HASH INFORMATION:" >>$OUTPUT.triage.txt
      MEMLOC=$($volatility hivelist -f $FILE --profile=$PROFILE | grep SAM | awk '{print$1}')
      $volatility hashdump --profile=$PROFILE -f $FILE -s $MEMLOC >> $OUTPUT.triage.txt
    echo "--------------------" >> $OUTPUT.triage.txt
    echo "IP INFORMATION:" >> $OUTPUT.triage.txt
      $volatility --profile=$PROFILE -f $FILE netscan | awk '{print $3}' | sed 's/:::$//' >> $OUTPUT.triage.txt
    echo "--------------------" >> $OUTPUT.triage.txt
    echo "NETWORK CONNECTIONS:" >> $OUTPUT.triage.txt
      $volatility --profile=$PROFILE -f $FILE netscan >> $OUTPUT.triage.txt
    echo "--------------------" >> $OUTPUT.triage.txt
    echo "HIDDEN PROCESSES:" >> $OUTPUT.triage.txt
      $volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' >> $OUTPUT.triage.txt
    echo "--------------------" >> $OUTPUT.triage.txt
    echo "SUSPICIOUS PROCESSES: (Hidden Processes communicating on the network)" >> $OUTPUT.triage.txt
      HPID=$($volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | awk '{print $3}')
        if [[ -z "$HPID" ]]; then
          echo "No hidden processes located." >> $OUTPUT.triage.txt
          echo "--------------------" >> $OUTPUT.triage.txt
        else
          $volatility --profile=$PROFILE -f $FILE netscan | grep -E $HPID >> $OUTPUT.triage.txt
          echo "--------------------" >> $OUTPUT.triage.txt
        fi
    echo "PROCESSES CONTAINING INJECTED OR HIDDEN CODE (MALFIND):" >> $OUTPUT.triage.txt
      $volatility --profile=$PROFILE -f $FILE malfind | grep Process >> $OUTPUT.triage.txt
      echo "--------------------" >> $OUTPUT.triage.txt
    echo "Triage complete at:" >> $OUTPUT.triage.txt
    date >> $OUTPUT.triage.txt
  zenity --info --title "JAF v0.9.3 - TRIAGE COMMAND" --text "TRIAGE command completed. Available output sent to report: $OUTPUT.triage.txt." --height=150 --width=250
  zenity --question --title "JAF v0.9.3 - TRIAGE COMMAND" --text "Do you wish to conduct any further commands?" --no-wrap --ok-label "Yes" --cancel-label "No"
    case $? in
      0)
        zenity --info --title "JAF v0.9.3" --text "Continuing to command selection."
        ;;
      1)
      data_assurance
      zenity --info --title "JAF v0.9.3" --text "User specified NO - Tool closing." --height=150 --width=250
      zenity --question --title "DATA ASSURANCE" --text "Data integrity has been checked and Passed. Do you wish to save target file hash?" --no-wrap --ok-label "Yes" --cancel-label "No"
              case $? in
                    0)
                      echo "Hash saved as $OUTPUT.sha256.txt"
                      ;;
                    1)
                      rm $OUTPUT.sha256.txt
                      echo "Hash not saved."
                      ;;
      esac
      zenity --question --title "SAVE?" --text "Do you want to save the directory and files created?" --no-wrap --ok-label "Yes" --cancel-label "No"
      case $? in
        0)
        echo "Directory and files saved. Location: $DIRECTORY";;
        1)
        rm -rf $DIRECTORY
        echo "Directory and files deleted.";;
      esac
      TOTALEND=$[ $(date +%s) - ${TOTALSTART} ]
      echo "JAF COMPLETE. TOTAL RUN TIME FOR JAF: ${TOTALEND} (secs)"
      exit 0
    esac
  ;;
  1)
  zenity --info --title "JAF V0.9.3" --text "Triage NOT run by user command. Continuing to command specification."
  echo "Triage command not run, continuing."
  ;;
esac

#COMMAND MENU
echo " "
echo "-------------------- JAF --------------------"
echo " "
temp2=`mktemp -t temp2.XXXXXX`
while opt=$(zenity --list --radiolist --title "COMMAND SELECTION" --text "Please select a COMMAND option, when finished, select QUIT" --height=650 --width=250 --cancel-label "ABORT" --column "Select" --column "Menu Item" FALSE PWHASH FALSE HP FALSE MALFIND FALSE SUSPROC FALSE NETWORK FALSE HPDLLDUMP FALSE CON FALSE NAMEDPROCINFO FALSE IPFINDER FALSE NAME FALSE METERTRACE FALSE FILERECORDSEARCH FALSE VADCHECKER FALSE SCRIPTCHECK FALSE TIMEDATE FALSE MANUAL FALSE QUIT)
  do
  case "$opt" in
    PWHASH)
      START="$(date +%s)"
      echo "Obtaining any available password hashes from image."
      MEMLOC=$($volatility hivelist -f $FILE --profile=$PROFILE | grep SAM | awk '{print$1}')
      $volatility hashdump --profile=$PROFILE -f $FILE -s $MEMLOC > $OUTPUT.logins.txt && echo "Hash extraction completed and stored as $OUTPUT.logins.txt"
      data_assurance
      duration;;
    HP)
      START="$(date +%s)"
      echo "Locating Hidden Processes within the provided image."
      $volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' > $OUTPUT.hiddenproc.txt && echo "Hidden process extraction completed and stored as $OUTPUT.hiddenproc.txt"
      data_asurance
      duration;;
    MALFIND)
      START="$(date +%s)"
      echo "Locating any known malware within the provided image."
      $volatility --profile=$PROFLE -f $FILE malfind | grep Process > $OUTPUT.malfind.txt && echo "Potential malware located and saved to $OUTPUT.malfind.txt"
      data_assurance
      duration;;
    SUSPROC)
      START="$(date +%s)"
      echo "Locating any suspicious processes i.e. hidden processes that are communicating on the network."
      SOCKID=$($volatility --profile=$PROFILE -f $FILE sockscan | awk '{print$2}' | tr '\n' '|')
        if [[ $? = 0 ]]; then
          $volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | grep -E $SOCKID > $OUTPUT.susproc.text && echo "Suspicious processes located and saved as $OUTPUT.susproc.txt"
        else
          HPID=$($volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | awk '{print $3}')
          $volatility --profile=$PROFILE -f $FILE netscan | grep -E $HPID > $OUTPUT.susproc.text && echo "Suspicious processes located and saved as $OUTPUT.susproc.txt"
        fi
      data_assurance
      duration;;
    NETWORK)
      START="$(date +%s)"
      echo "Conducting CONNSCAN to obtain network connectivity information."
      $volatility --profile=$PROFILE -f $FILE connscan > $OUTPUT.network.txt
        if [[ $? = 0 ]]; then
          echo "CONNSCAN failed. Trying NETSCAN."
          $volatility --profile=$PROFILE -f $FILE netscan > $OUTPUT.network.txt && echo "Network scan completed, information output to $OUTPUT.network.txt."
          else
            echo "Network scan completed, information output to $OUTPUT.network.txt"
        fi
      data_assurance
      duration;;
    HPDLLDUMP)
      START="$(date +%s)"
      echo "Locating hidden processes and obtaining DLLs of all identified hidden processes."
      OFFSET=$($volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | awk -F'[|]' '{print$1}')
      $volatility --profile=$PROFILE -f $FILE dlldump --offset=$OFFSET -D /home/user/$OUTPUT/HiddenProcDLLDump && echo "Success. DLLDump obtained for hidden processes. Obtained DLLs saved to /home/user/$OUTPUT/HiddenProcDLLDump folder."
      data_assurance
      duration;;
    CON)
      START="$(date +%s)"
      echo "Locating any available command history."
      $volatility --profile=$PROFILE -f $FILE consoles > $OUTPUT.console.txt
      $volatility --profile=$PROFILE -f $FILE cmdscan >> $OUTPUT.console.txt && echo "Success. Commands printed to $OUTPUT.console.txt."
      data_assurance
      duration;;
    NAMEDPROCINFO)
      START="$(date +%s)"
      PROC=$(zenity --entry --title "PROCESS FINDER" --text "Please enter the name of the required process:")
      $volatility --profile=$PROFILE -f $FILE pslist > $OUTPUT.temp
      awk 'NR > 1 { exit }; 1' $OUTPUT.temp > $OUTPUT.namedproc.txt
      grep $PROC $OUTPUT.temp >> $OUTPUT.namedproc.txt && echo "Success. Proc info printed to $OUTPUT.namedproc.txt"
      zenity --question --title "PROCESS FINDER" --text "Do you want to also locate child or parent processes associated with the target?" --no-wrap --ok-label "Yes" --cancel-label "No"
      case $? in
            0)
              ID=$(grep $PROC $OUTPUT.temp | awk '{print $3}')
              grep $ID $OUTPUT.temp >> $OUTPUT.namedproc.txt && echo "Success. Child and parent info added to $OUTPUT.namedproc.txt - PLEASE NOTE: This command seeks direct relationships. For full tree please run MANUAL command and specify PSTREE with GREP switch."
              ;;
            1)
            zenity --info --title "PROCESS FINDER" --text "Command completed - user specified NO to parent/child locator." --width 350 --height 150
        esac
      rm $OUTPUT.temp
      data_assurance
      duration;;
    IPFINDER)
      START="$(date +%s)"
      $volatility --profile=$PROFILE -f $FILE netscan | awk '{print $3}' > $OUTPUT.ip.txt && echo "Success. IP information printed to $OUTPUT.ip.txt"
      data_assurance
      duration;;
    NAME)
      START="$(date +%s)"
      temp3=`mktemp -t temp3.XXXXXX`
      zenity --list --radiolist --title "OS SELECTION" --text "Please select the OS in use (refer to profile for guidance)" --height=650 --width=250 --cancel-label "ABORT" --column "Select" --column "Menu Item" FALSE Win10 FALSE Win7 FALSE WinXP FALSE QUIT > $temp3
        selection=$(cat $temp3)
        case $selection in
          Win10)
          MEMOFFSET=$($volatility --profile=$PROFILE -f $FILE hivelist | grep -F 'MACHINE\SYSTEM' | awk '{print $1}')
          $volatility --profile=$PROFILE -f $FILE printkey -o $MEMOFFSET -K 'ControlSet001\Control\ComputerName\ComputerName' | grep -i "ComputerName" > $OUTPUT.name.txt && echo "Success. ComputerName information printed to $OUTPUT.name.txt"
          data_assurance
          duration;;
          Win7)
          MEMOFFSET=$($volatility --profile=$PROFILE -f $FILE hivelist | grep -F 'MACHINE\SYSTEM' | awk '{print $1}')
          $volatility --profile=$PROFILE -f $FILE printkey -o $MEMOFFSET -K 'ControlSet001\Control\ComputerName\ComputerName' | grep -i "ComputerName" > $OUTPUT.name.txt && echo "Success. ComputerName information printed to $OUTPUT.name.txt"
          data_assurance
          duration;;
          WinXP)
          MEMOFFSET=$($volatility --profile=$PROFILE -f $FILE hivelist | grep -F 'system32\config\system' | awk '{print $1}')
          $volatility --profile=$PROFILE -f $FILE printkey -o $MEMOFFSET -K 'ControlSet001\Control\ComputerName\ComputerName' | grep -i "ComputerName" > $OUTPUT.name.txt && echo "Success. ComputerName information printed to $OUTPUT.name.txt"
          data_assurance
          duration;;
          QUIT)
          echo "User Exited - Quitting"
          exit 0;;
        esac
      data_assurance
      duration;;
    METERTRACE)
      START="$(date +%s)"
      $volatility --profile=$PROFILE -f $FILE netscan > $OUTPUT.temp
      awk 'NR > 1 { exit }; 1' $OUTPUT.temp > $OUTPUT.metertrace.txt
      $volatility --profile=$PROFILE -f $FILE netscan | grep "4444" >> $OUTPUT.metertrace.txt
        if [[ $? == 0 ]]; then
          zenity --info --title "MeterTrace" --text "Meterpreter connection located. \nInformation printed to $DIRECTORY/$OUTPUT.metertrace.txt. \nContinuing analysis. \nPlease wait." --height=150 --width=350
        else
          zenity --info --title "MeterTrace" --text "Meterpreter connection not found. \nCommand closing."
          rm $OUTPUT.temp
          rm $OUTPUT.metertrace.txt
          exit 0
        fi
      mkdir MalDump
      MALPID=$(grep "4444" $OUTPUT.temp | awk '{print $6}')
      DUMPLOC=/jaf/$OUTPUT/MalDump
      $volatility --profile=$PROFILE -f $FILE malfind -D $DUMPLOC -p $MALPID &> /dev/null && echo "Success. Malfind proc dumped to $OUTPUT/MalDump/. Continuing."
      $volatility --profile=$PROFILE -f $FILE procdump -D $DUMPLOC -p $MALPID &> /dev/null && echo "Success. Process dumped to $OUTPUT/MalDump/. Continuing."
      $volatility --profile=$PROFILE -f $FILE memdump -D $DUMPLOC -p $MALPID &> /dev/null && echo "Success. Process memory information dumped to $OUTPUT/MalDump/."
      zenity --info --title "MeterTrace" --text "Command complete. Please see /jaf/$OUTPUT/MalDump for results. Send any relevant files to any virus checker for further information." --height=150 --width=350
      rm $OUTPUT.temp
      data_assurance
      duration;;
    FILERECORDSEARCH)
      START=$"$(date +%s)"
      RECORD=$(zenity --entry --title "FILE RECORD SEARCH" --text "Please enter the Record Number to be searched for:")
      $volatility --profile=$PROFILE -f $FILE mftparser > $OUTPUT.mft.temp
      sed -n "/Record Number: $RECORD/,/DATA/p" $OUTPUT.mft.temp > $OUTPUT.filerecord.txt && echo "Sucess. Named record located and stored as $OUTPUT.filerecord.txt."
        if [[ $? == 1 ]]; then
          zenity --info --title "FILE RECORD SEARCH" --text "Record could not be located within MFT. Please check record number and try again." --height=350 --width=350
        fi
      rm $OUTPUT.mft.temp
      data_assurance
      duration;;
    VADCHECKER)
    START=$"$(date +%s)"
    zenity --question --title "VADCHECKER" --text "Are you checking for a specific memory address or an address range?" --no-wrap --ok-label "SPECIFIC" --cancel-label "RANGE"
    case $? in
          0)
          MEMADD=$(zenity --entry --title "VADCHECKER" --text "Please enter the memory address to be located:")
          $volatility --profile=$PROFILE -f $FILE vadinfo > VAD.temp
          sed -n "/$MEMADD/,/^$/p" VAD.temp > $OUTPUT.vadchecker.txt && echo "Success. VAD information located and stored as $OUTPUT.vadchecker.txt."
          rm VAD.temp
          ;;
          1)
          MEMADD1=$(zenity --entry --title "VADCHECKER" --text "Please enter the START memory address:")
          MEMADD2=$(zenity --entry --title "VADCHECKER" --text "Please enter the END memory address:")
          $volatility --profile=$PROFILE -f $FILE vadinfo > VAD.temp
          sed -n "/Start $MEMADD1 End $MEMADD2/,/^$/p" VAD.temp > $OUTPUT.vadchecker.range.txt && echo "Success. VAD information located and stored as $OUTPUT.vadchecker.range.txt."
      esac
    data_assurance
    duration;;
    SCRIPTCHECK)
    START=$"(date +%s)"
    EXT=$(zenity --entry --title "SCRIPTCHECK" --text "Please enter the extension of the script to be checked:")
    $volatility --profile=$PROFILE -f $FILE cmdline | grep $EXT > $OUTPUT.scriptcheck.txt
    data_assurance
    duration;;
    TIMEDATE)
    START=$"(date +%s)"
    DATE=$(zenity --entry --title "TIMEDATE" --text "Please enter the DATE required: \nFORMAT = YYYY-MM-DD")
    TIME=$(zenity --entry --title "TIMEDATE" --text "Please enter the TIME required, if known. Leave blank if unknown. \nFORMAT = HH:MM")
    if [[ -z "$TIME" ]]; then
      $volatility --profile=$PROFILE -f $FILE shimcache | grep $DATE > $OUTPUT.date.txt && echo "Success. Running processes for the given DATE printed to $OUTPUT.date.txt."
    else
      $volatility --profile=$PROFILE -f $FILE shimcache | grep $DATE | grep $TIME > $OUTPUT.timedate.txt && "Success. Running processes for the given DATE and TIME printed to $OUTPUT.timedate.txt."
    fi
    data_assurance
    duration;;
    MANUAL)
      START="$(date +%s)"
          COMMAND=$(zenity --entry --title "Command Specification" --text "REQUIRED: Please enter desired command:")
              if [ -z "$COMMAND" ]
                then
                  echo "ERROR: Field cannot be blank, please specify a command."
                    exit 0
              fi
              if [[ ! "$COMMAND" != *[^[:alnum:]]* ]];
                then
                  echo "ERROR: Invalid characters entered. Only alphanumeric characters are accepted."
                    exit 0
              fi
          SWITCH=$(zenity --entry --title "Command Specification" --text "OPTIONAL: Please specify any required switches e.g. -s 0x92 [Leave blank for none]")
            if [[ ! "$SWITCH" != *[^[:alnum:]-]* ]];
              then
                echo "ERROR: Invalid characters entered, only alphanumeric characters and - are accepted."
                  exit 0
            fi
      echo "Running $COMMAND, please wait."
  $volatility --profile=$PROFILE -f $FILE $COMMAND ==output=text --output-file=$OUTPUT.manual.txt $SWITCH && echo "Operation complete. Output to $OUTPUT.manual.txt successful."
  data_assurance
  duration;;
  QUIT)
    echo "User Specified QUIT - Closing."
    data_assurance
    duration
    break;;
  ABORT)
  zenity --info --title "ABORT" --text "User selected abort. Tool aborted. Files may not have saved." --height=350 --width=150
  data_assurance
  duration
  exit 0;;
  esac
done
#DATA ASSURANCE OPTION
zenity --question --title "DATA ASSURANCE" --text "Data integrity has been checked and Passed. Do you wish to save target file hash?" --no-wrap --ok-label "Yes" --cancel-label "No"
        case $? in
              0)
                echo "Hash saved as $OUTPUT.sha256.txt"
                ;;
              1)
                rm $OUTPUT.sha256.txt
                echo "Hash not saved."
                ;;
esac

#VERSIONCONTROLNEW
TOTALEND=$[ $(date +%s) - ${TOTALSTART} ]
echo " "
echo "-------------------- JAF --------------------"
echo " "
echo "JAF COMPLETE. TOTAL RUN TIME FOR JAF: ${TOTALEND} (secs)"

exit 0
