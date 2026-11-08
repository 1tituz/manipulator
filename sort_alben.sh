#!/bin/bash

function select_folder() {
    clear
    echo;echo;
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local folders=()
    local i=1

    # Überprüfen, ob der Pfad existiert
    if [ ! -d "$path" ]; then
        clear
        echo;echo;
        echo -e "\t${red}${BOLD}KEINE ORDNER VORHANDEN${RESET}"
        sleep 1s
        START
    fi

    # Ordner auflisten und nummerieren
    echo -e "\t${blue}${BOLD}##### VERFÜGBARE ALBEN:${RESET}"
    echo;echo;echo;
    for folder in "$path"/*; do
        if [ -d "$folder" ]; then
            folders+=("$folder")
            echo -e "\t${white}${BOLD}$i${RESET}${white} ... $(basename "$folder")${RESET}"
            ((i++))
        fi
    done

    # Wenn keine Ordner gefunden wurden
    if [ ${#folders[@]} -eq 0 ]; then
        echo -e "\t${red}Keine Ordner in Vorhanden gefunden.${BOLD}"
        sleep 1s
        START
    fi

    # Benutzer zur Auswahl auffordern
    while true; do
        echo
        read -p "	Ordner auswählen (1-${#folders[@]}), [m] MultiCD: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#folders[@]}" ]; then
            selected_folder="${folders[$choice-1]}"
            #echo -e "\tSie haben ausgewählt: $(basename "$selected_folder")"
            selected_Album=$(basename "$selected_folder")
            source id3tag.sh
           # return 0
           elif [[ -z $choice ]]; then
            START
            elif [[ $choice == "m" ]]; then
                # Bei Doppelalben in eigenen Ordner - Unterordner in einen Ordner zusammenführen
                clear
                echo;
                echo;
                echo -e "\t${brown}${BOLD}##### MULTI CD - Ordner Zusammenführen${RESET}"
                echo;echo;
                # Ordner auflisten und nummerieren
                multiCD_list

                echo;
                echo;
                echo -e "\tWähle Ordner aus (z.b.: 1 3)"
                read -p $'\t$: ' slct
                echo;echo;
                # Ausgewählte cds in array speichern
                IFS=' ' read -ra CD <<< "$slct"
                mkdir -p "$DOWNLOAD_DIR"/SoundZumEinordnen/multiCD
                    d=1
                for i in "${!CD[@]}"; do
                    # Ausgewählte cds in multiCD Ordner kopieren
                    n=$(echo "${CD[i]}")
                    ((n--))
                    pfad="$(echo ${folders[n]})"
                    mv "$pfad" "$DOWNLOAD_DIR"/SoundZumEinordnen/multiCD
                    #eyeD3 
                done

                # folder array leeren 
                unset folders
                clear
                select_folder




                
        else
            echo
            echo -e "\t${red}Album existiert nicht, eine Nummer von${BOLD} 1 - ${#folders[@]}${RESET}${red} auswählen!.${RESET}"
            echo;echo;
        fi
    done
}

multiCD_list() {
# Ordner auflisten und nummerieren

    echo;echo;
    echo -e "\t${BOLD}### VERFÜGBARE ALBEN:${RESET}"
    echo;echo;echo;
    local i=1

    for folder in "$path"/*; do
        if [ -d "$folder" ]; then
            folders+=("$folder")
            echo -e "\t${white}${BOLD}$i${RESET}${white} ... $(basename "$folder")${RESET}"
            ((i++))
        fi
    done

    # Wenn keine Ordner gefunden wurden
    if [ ${#folders[@]} -eq 0 ]; then
        echo -e "\t${red}Keine Ordner in Vorhanden gefunden.${BOLD}"
        sleep 1s
        START
    fi
}


select_folder