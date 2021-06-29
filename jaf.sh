#!/bin/bash
#WRITETEST
echo "JAFOOLY SYS: GIVING LINUX ALL IT DESERVES."
echo "VERSION: 0.6"
echo "
╱╱╭┳━━━┳━━━╮
╱╱┃┃╭━╮┃╭━━╯
╱╱┃┃┃╱┃┃╰━━╮
╭╮┃┃╰━╯┃╭━━╯
┃╰╯┃╭━╮┃┃
╰━━┻╯╱╰┻╯
"
zenity --info --title "Just Another Framework [JAF] - Version 0.6" --text "JAF - DISCLAIMER: This script is designed to act as a TRIAGE TOOL ONLY it is not a replacement for analysis. \n \nEscape sequence is Ctrl+C \n \nPlease press OK to accept and continue." --width=350 --height=150
sleep 0.2
TOTALSTART="$(date +%s)"

#USER INPUTS

FILE=$(zenity --file-selection --title "REQUIRED: Please specify target file for analysis:" --filename "${HOME/USER/}")
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
    mkdir /jaf/$OUTPUT
    cd /jaf/$OUTPUT
    DIRECTORY=$(pwd)
    zenity --info --title "Just Another Framework [JAF]" --text "New directory is $DIRECTORY. \nAll created files and folders will be saved to this location." --width=350 --height=150 ;;
    1)
    DIRECTORY=$(zenity --entry --title "Just Another Framework [JAF]" --text "Please enter the Directory name, including pathway. For example: /jaf/TEST1:" --width=350 --height=150)
    zenity --info --title "Just Another Framework [JAF]" --text "New directory is $DIRECTORY. \nAll created files and folders will be saved to this location." --width=350 --height=150 ;;
    -1)
    echo "An unexpected error occurred. Please try again. If error persists, please see README and contact author."
    exit 0 ;;
  esac

#VOLATILITY INSTALLATION SELECTION
echo "Determining volatility installation type..."
vol.py -f /jaf/test.vmem pslist &> /dev/null
if [[ $? == 0 ]];
then
  volatility=$"vol.py"
  echo "SUCCESSFUL: Python Installation Detected."
  zenity --info --title "INSTALLATION DETECTION" --text "Python installation detected and used." --width=350 --height=150
else
  /home/user/volatility/volatility -f /jaf/test.vmem pslist &> /dev/null
  if [[ $? == 0 ]];
  then
    volatility=$"/home/user/volatility/volatility"
    echo "SUCCESSFUL: Standalone Installation Detected."
    zenity --info --title "INSTALLATION DETECTION" --text "Default standalone installation detected and used." --width=350 --height=150
  else
    volatility=$(zenity --entry --title "INSTALLATION DETECTION" --text "Automatic Detection Failed. /nREQUIRED: Please enter the full pathway of your volatility script:")
    volatility -f /jaf/test.vmem pslist &> /dev/null
      if [[ $? == 0 ]];
      then
        echo "SUCCCESSFUL: Manual Location Confirmed."
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
    PROFILE=$(zenity --entry --title "Profile Specification" --text "REQUIRED: Please enter profile:")
    if [[ ! "$PROFILE" != *[^[:alnum:]]* ]];
    then
      zenity --error --title "Input Error" --text "ERROR: \nInvalid characters entered, the following characters are valid: A-Z 0-9" --width 350 --height 150
      exit 0
    fi;;
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
                          $volatility -f $FILE kdbgscan | grep 'Profile\|PsA\|PsL' | sed -n '/Profile suggestion/!d;h;n;/(0/d;n;//d;g;p' | awk '{print$4}' > $OUTPUT.potprofiles.txt
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

#COMMAND MENU
echo " "
echo "-------------------- JAF --------------------"
echo " "
temp2=`mktemp -t temp2.XXXXXX`
zenity --list --radiolist --title "COMMAND SELECTION" --text "Please select a COMMAND option, when finished, select QUIT" --height=650 --width=250 --cancel-label "ABORT" --column "Select" --column "Menu Item" FALSE PWHASH FALSE HP FALSE MALFIND FALSE SUSPROC FALSE SOCKSCAN FALSE HARDWARE FALSE HPDLLDUMP FALSE CON FALSE NAMEDPROCINFO FALSE MANUAL FALSE QUIT > $temp2
  selection=$(cat $temp2)
  case $selection in
    PWHASH)
      START="$(date +%s)"
      echo "Obtaining any available password hashes from image."
      MEMLOC=$($volatility hivelist -f $FILE --profile=$PROFILE | grep SAM | awk '{print$1}')
      $volatility hashdump --profile=$PROFILE -f $FILE -s $MEMLOC > $OUTPUT.logins.txt && echo "Hash extraction completed and stored as $OUTPUT.logins.txt"
      data_assurance
      duration
      break;;
    HP)
      START="$(date +%s)"
      echo "Locating Hidden Processes within the provided image."
      $volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' > $OUTPUT.hiddenproc.txt && echo "Hidden process extraction completed and stored as $OUTPUT.hiddenproc.txt"
      data_asurance
      duration
      break;;
    MALFIND)
      START="$(date +%s)"
      echo "Locating any known malware within the provided image."
      $volatility --profile=$PROFLE -f $FILE malfind | grep Process > $OUTPUT.malfind.txt && echo "Potential malware located and saved to $OUTPUT.malfind.txt"
      data_assurance
      duration
      break;;
    SUSPROC)
      START="$(date +%s)"
      echo "Locating any suspicious processes i.e. hidden processes that are communicating on the network."
      SOCKID=$($volatility --profile=$PROFILE -f $FILE sockscan | awk '{print$2}' | tr '\n' '|')
      $volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | grep -E $SOCKID > $OUTPUT.susproc.text && echo "Suspicious processes located and saved as $OUTPUT.susproc.txt"
      data_assurance
      duration
      break;;
    SOCKSCAN)
      START="$(date +%s)"
      echo "Conducting SOCKSCAN to obtain network connectivity information."
      $volatility --profile=$PROFILE -f $FILE sockscan > $OUTPUT.sockscan.txt && echo "Network Scan completed, information output to $OUTPUT.sockscan.txt"
      data_assurance
      duration
      break;;
    HARDWARE)
      START="$(date +%s)"
      echo "WORK IN PROGRESS - DO NOT USE"
      exit 0;;
      #echo "Obtaining hardware information from volatile memory locations."
      #XXXX - WORK IN PROGRESS - DO NOT USE
      #echo "Hardware configuration located and stored as $OUTPUT.hardware.txt"
      #data_assurance
      #duration;;
    HPDLLDUMP)
      START="$(date +%s)"
      echo "Locating hidden processes and obtaining DLLs of all identified hidden processes."
      OFFSET=$($volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | awk -F'[|]' '{print$1}')
      $volatility --profile=$PROFILE -f $FILE dlldump --offset=$OFFSET -D /home/user/$OUTPUT/HiddenProcDLLDump && echo "Success. DLLDump obtained for hidden processes. Obtained DLLs saved to /home/user/$OUTPUT/HiddenProcDLLDump folder."
      data_assurance
      duration
      break;;
    CON)
      START="$(date +%s)"
      echo "Locating any available command history."
      $volatility --profile=$PROFILE -f $FILE consoles > $OUTPUT.console.txt && echo "Success. Commands printed to $OUTPUT.console.txt."
      data_assurance
      duration
      break;;
    NAMEDPROCINFO)
        START=
        PROC=$(zenity --entry --title "PROCESS FINDER" --text "Please enter the name of the required process:")
        $volatility --profile=$PROFILE -f $FILE pslist | grep $PROC > $OUTPUT.namedproc.txt && echo "Success. Proc info printed to $OUTPUT.namedproc.txt"
        data_asurance
        duration
        break;;
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
  duration
  break;;
  1)
  zenity --info --title "ABORT" --text "User selected abort. Tool aborted. Files may not have saved." --height=350 --width=150
  data_assurance
  duration
  exit 0;;
    QUIT)

#SAVING
zenity --question --title "SAVE?" --text "Do you want to save the directory and files created?" --no-wrap --ok-label "Yes" --cancel-label "No"
case $? in
  0)
  echo "Directory and files saved. Location: /home/user/$OUTPUT";;
  1)
  rm -rf /home/user/$OUTPUT
  echo "Directory and files deleted.";;
esac
#DATA ASSURANCE OPTION
zenity --question --title "DATA ASSURANCE" --text "Data integrity has been checked and Passed. Do you wish to save target file hash?" --no-wrap --ok-label "Yes" --cancel-label "No"
        case $? in
              0)
                echo "Hash saved as $OUTPUT.sha256.txt"
                exit 0;;
              1)
              rm $OUTPUT.sha256.txt
              echo "Hash not saved."
              exit 0;;
esac
zenity --info "User specified QUIT - closing."
exit 0;;
esac

#VERSIONCONTROLNEW
TOTALEND=$[ $(date +%s) - ${TOTALSTART} ]
echo "TOTAL RUN TIME FOR JAF: ${TOTALEND} (secs)"
