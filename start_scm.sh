#!/bin/bash

# Farbcodes
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
violett='\033[0;35m'
white='\033[0;37m'
brown='\033[0;33m'
lightblue='\033[0;36m'

# Hintergrund
brownBG='\033[43m'
underscore='\033[4m'

# Formatierung
BOLD='\033[1m'
RESET='\033[0m'

# Fenstergröße
printf '\033[8;45;160t'

source export_files.sh
source covers.sh
source title.sh

START() {
clear

echo;echo;echo;
echo  -e "${lightblue}${BOLD}"
echo -e '        __  __ ____ _____     '                                            
echo -e '       |  \/  |  _ \___ /     '                                            
echo -e '       | |\/| | |_) ||_ \      '                                           
echo -e '       | |  | |  __/___) |      '                                          
echo -e '       |_|  |_|_|  |____/        '                                         
echo -e '        __  __    _    _   _ ___ ____  _   _ _        _  _____ ___  ____  '
echo -e '       |  \/  |  / \  | \ | |_ _|  _ \| | | | |      / \|_   _/ _ \|  _ \ '
echo -e '       | |\/| | / _ \ |  \| || || |_) | | | | |     / _ \ | || | | | |_) |'
echo -e '       | |  | |/ ___ \| |\  || ||  __/| |_| | |___ / ___ \| || |_| |  _ < '
echo -e '       |_|  |_/_/   \_\_| \_|___|_|    \___/|_____/_/   \_\_| \___/|_| \_\ '                                                                  
echo -e "${RESET}"

echo;echo;echo;echo;echo;
echo -e "\t${white}${BOLD}1${RESET} ... ${white}${BOLD}ZIP${RESET} Dateien entpacken"
echo -e "\t${white}${BOLD}2${RESET} ... ${white}${BOLD}EPs${RESET} einordnen"
echo -e "\t${white}${BOLD}3${RESET} ... ${white}${BOLD}ID3 TAGS${RESET} bearbeiten"
echo;
echo -e "\t${white}${BOLD}s${RESET} ... Alben ${white}${BOLD}zum Server kopieren${RESET}"
echo -e "\t${white}${BOLD}d${RESET} ... Alben ${white}${BOLD}vom Server löschen${RESET}"
echo
echo -e "\t${white}${BOLD}r${RESET} ... ${white}${BOLD}Wiederherstellen${RESET} gelöschter Alben"
echo -e "\t${white}${BOLD}b${RESET} ... ${white}${BOLD}Backup${RESET} vom Soundordner auf externe Festplatte"
echo;
echo -e "\t${white}${BOLD}f${RESET} ... ${white}${BOLD}Filme${RESET} zum Jellyfin Server kopieren"
echo;
echo -e "\t${white}${BOLD}c${RESET} ... ${white}${BOLD}CONFIGS${RESET} - Bearbeiten/Anzeigen der hinterlegten Ordner"
echo;echo;
read -e -p $'\t$: ' auswahl

case $auswahl in 
    1) source entpacker.sh;;
    2) source sort_eps.sh ;;
    3) source sort_alben.sh;;
    c) source ordner_datenbank.sh; dbSHOW;;
    d) source sound_serverdelete.sh; search ;;
    r) restore_folder ;;
    s) source sound_servercopy.sh; search ;;
    f) source jellyfin_copy.sh; search ;;
    b) source backup.sh; CHECKFREEDISK ;;
    *) exit 0
esac
}


## SCRIPT STARTET HIER ###

#### ALS ERSTES DIE DATENBANK json Variablen laden
JSON_FILE="db.json"

# Überprüfen, ob die JSON-Datei existiert
if [ ! -f "$JSON_FILE" ]; then
    echo "Die Datei $JSON_FILE existiert nicht."
    source ordner_datenbank.sh
fi

# Alle Schlüssel-Wert-Paare aus der JSON-Datei extrahieren und in Variablen speichern
while IFS="=" read -r key value
do
    # Entfernen von Anführungszeichen und Leerzeichen
    key=$(echo "$key" | tr -d '"' | xargs)
    value=$(echo "$value" | tr -d '"' | xargs)
    
    # Variablen mit dem Namen des Schlüssels erstellen und den Wert zuweisen
    declare "$key=$value"
done < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" "$JSON_FILE") 

# RESTORE auf Backup-Ordner
restore_folder() {
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}### ALBUM WIEDERHERSTELLEN ###${RESET}"
    echo;echo;
    echo -e "${white}"

    local list=$(find "$DOWNLOAD_DIR/.soundBackupFiles" -mindepth 1 -type d -printf "%Td-%Tm %TH:%TM %p\n" | sort -r)

    printf '%s\n' "$list" | sed 's/^/   /' | sed 's|/.*\/||' | nl
    echo;echo;
    echo -e "${RESET}${blue}${BOLD}"
    read -e -p $'\t$: ' selected
    echo;echo;
    echo -e "${RESET}${white}"
    if [[ -z $selected ]]; then
        START
        elif [[ $selected =~ ^[0-9]+$ ]]; then
            local restoreFolder=$(echo "$list" | sed -n ""$selected"p")
            restoreFolder=$(echo "$restoreFolder" | sed 's|^[^/]*||')
            mkdir -p "$DOWNLOAD_DIR/SoundZumEinordnen"
            cp -rv "$restoreFolder" "$DOWNLOAD_DIR/SoundZumEinordnen/"
            if [[ $? -eq 1 ]]; then
                echo -e "\t${red}${BOLD}KEIN GÜLTIGE ZAHL EINGEGBEN!!!"
                sleep 2s
                restore_folder
            fi
        else
            echo -e "${red}${BOLD}\tZahl eingeben!"
            sleep 2s
            restore_folder
    fi

    echo;echo;
    echo -e "\t${blue}${BOLD}Album wiederhergestellt."
    read -e -p $'\tHit [enter]' nada

    START    
}
# Lösche alte Backup Ordner älter als 7 Tage
delete_old_BackupFolder() {
    find "$DOWNLOAD_DIR/.soundBackupFiles" -mindepth 1 -type d -mtime +7 -exec rm -r "{}" \;
}
delete_old_BackupFolder
# Script Starten
START
