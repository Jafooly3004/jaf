#!/bin/bash

echo "JAFOOLY SYS: GIVING LINUX ALL IT DESERVES."
echo "
╱╱╭┳━━━┳━━━╮
╱╱┃┃╭━╮┃╭━━╯
╱╱┃┃┃╱┃┃╰━━╮
╭╮┃┃╰━╯┃╭━━╯
┃╰╯┃╭━╮┃┃
╰━━┻╯╱╰┻╯
"
zenity --info --title "Just Another Framework [JAF] - Version 0.4.7" --text "JAF - DISCLAIMER: This script is designed to act as a TRIAGE TOOL ONLY it is not a replacement for analysis. \n \nEscape sequence is Ctrl+C \n \nPlease press OK to accept and continue." --width 350 --height 150
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
  zenity --error --title "Input Error" --text "ERROR: \nInvalid characters entered, the following characters are valid: A-Z 0-9 - / ." --width 350 --height 150
  exit 0
fi

case $? in
  0)
  echo "Output files will begin $OUTPUT followed by .[command]";;
  1)
  echo "No output specified. Closing."
  exit 0;;
  -1)
  echo "An unexpected error occurred.";;
esac

mkdir /home/user/$OUTPUT
cd /home/user/$OUTPUT
DIRECTORY=$(pwd)
zenity --info --title "Just Another Framework [JAF]" --text "New directory is $DIRECTORY. \nAll created files and folders will be saved to this location." --width 350 --height 150

#DATA ASSURANCE - STAGE 1
HASHSTART="$(date +%s)"
echo "*** DATA ASSURANCE: Generating hash for target file. ***"
sha256sum $FILE > $OUTPUT.sha256.txt
HASH="$(cat $OUTPUT.sha256.txt)"
hashend="$(date +%s)"
DURATIONHASH=$[ ${hashend} - ${HASHSTART} ]
echo "*** DATA ASSURANCE: The SHA256 Hash for the provided file is: $HASH ***"
echo "Hash generation took $DURATIONHASH (secs)"

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
      PROFILE=$(/home/user/volatility/volatility -f $FILE imageinfo | grep Profile | awk '{print $4}' | sed 's/,*$//g') && echo "Profile location successful."
      IMAGEINFOPROFILEEND="$(date +%s)"
      IMAGEINFOPROFILETIME=$[ ${IMAGEINFOPROFILEEND} - ${PROFILESTART} ]
      echo "Imageinfo profile location took $IMAGEINFOPROFILETIME (secs)"
          if [ $PROFILE == No ]
            then
              KDBGSTART="$(date +%s)"
              echo "ERROR: Profile could not be located."
                zenity --question --title "PROFILE GENERATION" --text "IMAGEINFO Profile generation failed - do you want to try KDBGSCAN to locate potential profiles?" --no-wrap --ok-label "Yes" --cancel-label "No"
                case $? in
                  0)
                    zenity --question --title "PROFILE GENERATION" --text "Do you want to review potential profiles manually (see README), or for JAF to guess the most likely profile and test it?" --no-wrap --ok-label "Manual" --cancel-label "Guess"
                        case $? in
                          0)
                          echo "Generating potential profiles. Please wait."
                          /home/user/volatility/volatility -f $FILE kdbgscan | grep 'Profile\|PsA\|PsL' > $OUTPUT.potprofiles.txt
                          echo "Potential profiles saved. Please review $OUTPUT.potprofiles.txt and determine profile for entry. Please see README for guidance and information."
                          exit 0;;
                          1)
                          echo "Guessing most likely profile. Please wait, this could take some time. All potential profiles will be saved to $OUTPUT.potprofiles.txt for future reference and use."
                          /home/user/volatility -f $FILE kdbgscan | grep 'Profile\|PsA\|PsL' | sed -n '/Profile suggestion/!d;h;n;/(0/d;n;//d;g;p' | awk '{print$4}' > $OUTPUT.potprofiles.txt
                          PROFILE=$(head -1 $OUTPUT.potprofiles.txt) && /home/user/volatility/volatility -f $FILE --profile=$PROFILE pslist > /dev/null
                            if [[ test $? -eq 0 ]];
                              then
                                echo "Profile located on first guess."
                              else
                                PROFILE=$($OUTPUT.potprofiles.txt | sed '2q;d') && /home/user/volatility/volatility -f $FILE --profile=$PROFILE > /dev/null
                                  if [[ test $? -eq 0 ]];
                                  then
                                    echo "Profile located on second guess."
                                  else
                                    zenity --question --title "PROFILE GENERATION" --text "Profile guessing unsuccessful. Do you want to try specifying the details of the system to see if there is a matching profile?" --no-wrap --ok-label "Yes" --cancel-label "No"
                                    case $? in
                                    0)
                                    temp1=`mktemp -t temp1.XXXXXX`
                                    zenity --list --radiolist --title "OS SELECTION" --text "Please select OS in use on the target at the time of imaging:" --height=350 --width=250 --column "Select" --column "Menu Item" FALSE WINDOWS FALSE LINUX FALSE MAC FALSE QUIT > $temp1
                                      selection=$(cat $temp1)
                                      case $selection in
                                        WINDOWS)
                                        VERSION=$(zenity --entry --title "PROFILE GENERATION" --text "REQUIRED: Please enter the version in use e.g. for Windows 10, enter 10:")
                                        SP=$(zenity --entry --title "PROFILE GENERATION" --text "OPTIONAL: Please enter the SP in use [Leave blank for none]:")
                                        POTPROFILE=$(/home/user/volatility/volatility --info | grep "Profile" | grep "Windows" | grep "$VERSION" | grep "$SP") > $OUTPUT.manual.potprofiles.txt
                                        CARVEDPOTPROFILE=$(head -1 $OUTPUT.manual.potprofiles.txt)
                                            /home/user/volatility/volatility -f $FILE --profile=$CARVEDPOTPROFILE pslist > /dev/null
                                              if [[ test $? -eq 0 ]];
                                                then 
                                                echo "Profile located as $CARVEDPOTPROFILE."
                                                  $PROFILE=$CARVEDPOTPROFILE
                                                else
                                                  echo "Profile generation FAILED - Please see README for options."
                                                  exit 0;
                                              fi
                                        LINUX) echo "Manual profile location is ONLY available for Windows systems - please refer to the README for guidance on profile location."
                                        exit 0;
                                        MAC) echo "Manual profile location is ONLY available for Windows systems - please refer to the README for guidance on profile location."
                                        exit 0;
                                    esac
                                    1)
                                    echo "Profile generation unsuccessful. Potential profiles have been saved. Please refer to README for next stages if analysis is still required."
                                    exit 0;;
                                    -1)
                                    echo "An unexpected error occurred. Please try again. If error repeats, please contact author."
                                    exit 0;;
                                  fi
                            fi
                fi
                          -1)
                          echo "An unexpected error occurred. Please try again. If error repeats, please contact author."
                          exit 0;;
                        esac
                KDBGEND="$(date +%s)"
                KDBGTIME=$[ ${KDBGEND} - ${KDBGSTART} ]
                echo "KDBG Operation took $KDBGTIME (secs)"
                exit 0;;
                  1)
                  echo "Profile generation failed, KDBG denied by user. Closing."
                  exit 0;;
                  -1)
                  echo "An unexpected error occurred. Closing. Please try again."
                  exit 0;;
                esac
          else
              echo "The profile of the given target file is $PROFILE."
          fi
        profileend="$(date +%s)"
        PROFILEDURATION=$[ ${profileend} - ${PROFILESTART} ]
          echo "Profile generation operation took $PROFILEDURATION (secs)"
#SAVING PROFILE
    zenity --question --title "PROFILE GENERATION" --text "Do you wish to save the profile for future use?" --no-wrap --ok-label "Yes" --cancel-label "No"
        case $? in
              0)
                touch $FILE.profile.txt && echo $PROFILE > $FILE.profile.txt && echo "Profile saved as $FILE.profile.txt"
                break;;
              1)
              zenity --info --title "PROFILE GENERATION" --text "Profile NOT saved - WARNING: Not saving profile may mean that this has to be generated every time the tool is restarted. This may take some time on each run." --width 350 --height 150
          esac
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
zenity --list --radiolist --title "COMMAND SELECTION" --text "Please select a COMMAND option" --height=350 --width=250 --column "Select" --column "Menu Item" FALSE PWHASH FALSE HP FALSE MALFIND FALSE SUSPROC FALSE SOCKSCAN FALSE HARDWARE FALSE HPDLLDUMP MANUAL FALSE QUIT > $temp2
  selection=$(cat $temp2)
  case $selection in
    PWHASH)
      START="$(date +%s)"
      echo "Obtaining any available password hashes from image."
      MEMLOC=$(/home/user/volatility/volatility hivelist -f $FILE --profile=$PROFILE | grep SAM | awk '{print$1}')
      /home/user/volatility/volatility hashdump --profile=$PROFILE -f $FILE -s $MEMLOC > $OUTPUT.logins.txt && echo "Hash extraction completed and stored as $OUTPUT.logins.txt"
      data_assurance
      duration;;
    HP)
      START="$(date +%s)"
      echo "Locating Hidden Processes within the provided image."
      /home/user/volatility/volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' > $OUTPUT.hiddenproc.txt && echo "Hidden process extraction completed and stored as $OUTPUT.hiddenproc.txt"
      data_assurance
      duration;;
    MALFIND)
      START="$(date +%s)"
      echo "Locating any known malware within the provided image."
      /home/user/volatility/volatility --profile=$PROFLE -f $FILE malfind | grep Process > $OUTPUT.malfind.txt && echo "Potential malware located and saved to $OUTPUT.malfind.txt"
      data_assurance
      duration;;
    SUSPROC)
      START="$(date +%s)"
      echo "Locating any suspicious processes i.e. hidden processes that are communicating on the network."
      SOCKID=$(/home/user/volatility/volatility --profile=$PROFILE -f $FILE sockscan | awk '{print$2}' | tr '\n' '|')
      /home/user/volatility/volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | grep -E $SOCKID > $OUTPUT.susproc.text && echo "Suspicious processes located and saved as $OUTPUT.susproc.txt"
      data_assurance
      duration;;
    SOCKSCAN)
      START="$(date +%s)"
      echo "Conducting SOCKSCAN to obtain network connectivity information."
      /home/user/volatility/volatility --profile=$PROFILE -f $FILE sockscan > $OUTPUT.sockscan.txt && echo "Network Scan completed, information output to $OUTPUT.sockscan.txt"
      data_assurance
      duration;;
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
      OFFSET=$(/home/user/volatility --profile=$PROFILE -f $FILE psxview | awk '$4=="True"' | awk '$5=="False"' | awk -F'[|]' '{print$1}')
      /home/user/volaility --profile=$PROFILE -f $FILE dlldump --offset=$OFFSET -D /home/user/$OUTPUT/HiddenProcDLLDump && echo "Success. DLLDump obtained for hidden processes. Obtained DLLs saved to /home/user/$OUTPUT/HiddenProcDLLDump folder."
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
  /home/user/volatility/volatility --profile=$PROFILE -f $FILE $COMMAND ==output=text --output-file=$OUTPUT.manual.txt $SWITCH && echo "Operation complete. Output to $OUTPUT.manual.txt successful."
  data_assurance
  duration;;
    QUIT)
      zenity --info "User specified QUIT - closing."
      exit 0;;
    esac

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


TOTALEND=$[ $(date +%s) - ${TOTALSTART} ]
echo "TOTAL RUN TIME FOR JAF: ${TOTALEND} (secs)"
