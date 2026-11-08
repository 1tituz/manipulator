#!/bin/bash
directory="$DOWNLOAD_DIR/SoundZumEinordnen"

# Vorhanden Ordner Anzeigen
function display_folder_sizes() {
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}###### EPs EINSORTIEREN${RESET}";
    echo;echo;echo;echo;
    #local directory="soundEinsortieren"

    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' not found."
        return 1
    fi

    for folder in "$directory"/*; do
        if [ -d "$folder" ]; then
            folder_name=$(basename "$folder")
            folder_size=$(du -sh "$folder" | cut -f1)
            size_in_bytes=$(du -s "$folder" | cut -f1)

            if [ $size_in_bytes -gt "66000" ]; then
                echo -e "\t$folder_size ... $folder_name"
            else
                echo -e "\t${BOLD}$folder_size ... $folder_name${RESET}"
            fi
        fi
    done
echo;echo;echo;
echo -e "${BOLD}"
read -p "	Kleinste EP Dateigröße im MB eingeben ([enter] = 66MB): " epSIZE
echo -e "${RESET}"
if [[ -z $epSIZE ]]; then
    epSIZE=$((66 * 1048576))
    copy_small_folders $epSIZE
elif [[ ! -z $epSIZE ]]; then 
    epSIZE=$(($epSIZE * 1048576))
    copy_small_folders $epSIZE
else
    echo -e "\t...keine Angabe?!?!"
    sleep 2s
    START
fi
}

# EPs Ordner Kopieren
function copy_small_folders() {
    echo;echo;echo;
    local dest_dir="$EP_DIR"
    local epYear="$EPYEAR_DIR"
    local max_size=$1  # 66MB in bytes
    # Check if source directory exists
    if [ ! -d "$directory" ]; then
        echo "Error: Source directory '$directory' not found."
        return 1
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Counter for copied folders
    copied_folders=0

    # Iterate through all immediate subdirectories in the source directory
    for folder in "$directory"/*; do
        if [ -d "$folder" ]; then
            # Get folder size
            folder_size=$(du -sb "$folder" | cut -f1)

            # Check if folder is smaller than 66MB
            if [ "$folder_size" -lt "$max_size" ]; then
                # Copy folder to destination directory
                cp -R "$folder" "$dest_dir/$EPYEAR_DIR"
                ((copied_folders++))
                echo -e "\t${BOLD}Kopiere: $(basename "$folder"${RESET})"
                # Kopierte Ordner löschen
                rm -r "$folder"
            fi
        fi
    done
    echo
    echo -e "\t${green}${BOLD}EPs einsortiert: $copied_folders${RESET}"
    echo;
    echo -e "\t${white}Hit [Enter]${RESET}"
    echo;
    read -p " " nada

    # Check ob weitere Ordner zum Einordnen existieren.
    if [[ $(find "$directory" -mindepth 1 -type d | wc -l) -eq "0" ]]; then
        rm -r "$directory"
        START
    else
    # Zu ID3 Tagger weiterleiten
    source sort_alben.sh
    select_folder
    fi;
}

display_folder_sizes