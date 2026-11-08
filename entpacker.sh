#!/bin/bash
clear

EXTRACT_DIR="$DOWNLOAD_DIR/SoundZumEinordnen"
MP3BAK_DIR="$DOWNLOAD_DIR/.soundBackupFiles"
ORIGINAL_DIR="$DOWNLOAD_DIR/hiRes Dateien"
mkdir -p "$EXTRACT_DIR"
mkdir -p "$MP3BAK_DIR"

# Funktion zum Entpacken von Archiven
archives_extract() {
    echo;echo;
    echo -e "\t${blue}${BOLD}##### ENTPACKER${RESET}"
    echo;echo;echo;
    mapfile -t zArchives < <(find "$DOWNLOAD_DIR" -maxdepth 1 -type f -size +300k \( -iname "*.zip" -o -iname "*.rar" -o -iname "*.7z" \));

    if [[ $(echo ${#zArchives[@]}) -gt "0" ]]; then

        for zFile in "${zArchives[@]}"; do
            file=$(basename "$zFile")
            # Archiv entpacken
            7z x -bso0 "$zFile" -o"$EXTRACT_DIR" # 2>&1 |  echo -e "\t${red}${BOLD}FEHLER BEIM ENTPACKEN:${RESET} $file ${BOLD}-> [q] = quit${RESET}"; 




            # Ordner erstellen falls Dateien frei im zip File liegen.
                # Suche mp3 ohne Ordner  
            if [[ $(find "$EXTRACT_DIR" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.aiff" -o -iname "*.m4a" \) | wc -l) -gt "0" ]]; then
                mapfile -t looseMp3s < <(find "$EXTRACT_DIR" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.aiff" -o -iname "*.m4a" \));

                # Artist und Albumname hole
                albumINFO=$(eyeD3 --verbose "${looseMp3s[0]}");
                art=$(echo "$albumINFO" | grep -a -F "artist:" | sed '/album/d' | cut -d : -f 2 | sed 's/^ //');
                alb=$(echo "$albumINFO" | grep -a -F "album:" | cut -d : -f 2 | sed 's/^ //');

                # Ordner erstellen und Daten kopieren.
                mkdir -p "$EXTRACT_DIR/$art - $alb"
                                
                find "$EXTRACT_DIR" -maxdepth 1 -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.aiff" -o -iname "*.m4a" \) -exec mv "{}" "$EXTRACT_DIR/$art - $alb" \;


                echo;echo;
                echo -e "   Ordner für lose mp3s wurde erstellt: "$art" - "$alb""
                echo;echo;
            fi

            if [[ $? == 0 ]]; then
                echo -e "\t${green}\u2714${RESET} $file"
                else
                echo -e "\t${red}${BOLD}U+2717{RESET} $file"
            fi

            # Entpackte Datei löschen
            rm "$zFile"
        done


        # Kopiere Daten in den Backup Ordner
        find "$EXTRACT_DIR" -mindepth 1 -type d -exec cp -Ru "{}" "$MP3BAK_DIR" \;
        
        echo;echo;

        # Check ob flac oder aiff Dateien konvertiert werden sollen.
        convert_audio

        echo -e "\t${green}${BOLD}Alles entpackt!${RESET}"
        echo;
        read -p $'\tHit [Enter]' ggg

    else
        echo;echo;echo;
        echo -e "\t${red}${BOLD}KEINE ARCHIVE GEFUNDEN!${RESET}"
        echo;echo;echo;       
        echo -e "\t${white}${BOLD}Hit [Enter]${RESET}"
        echo;
        read -p " " nada
        START
    fi

}

# Funktion zur Konvertierung von FLAC/AIFF zu MP3
convert_audio() {
    mapfile -t fCon < <(find "$EXTRACT_DIR" -type f \( -name "*.flac" -o -name "*.aiff" -o -name "*.m4a" \) | sort -f)
    if [[ $(echo "${#fCon[@]}") -gt "0" ]]; then
    
    echo;echo;echo;
    echo -e "${blue}${BOLD}"
    read -e -p $'\tFLAC/AIFF/m4a-Dateien gefunden. Diese in MP3 konvertieren? [j/n]: ' convert_choice
    echo -e "${RESET}${white}"

        if [[ $convert_choice == "j" ]] || [[ -z $convert_choice ]]; then
            for file in "${fCon[@]}"; do
              #  ffmpeg -v quiet -stats -i "$audio" -c:a libmp3lame -b:a 320k -map_metadata 0 "${audio%.*}.mp3"
                cFile=$(basename "$file")
                echo -e "\t${lightblue}  Konvertiere:${BOLD} $cFile${RESET}"
                ffmpeg -loglevel error -stats -i "$file" -ab libmp3lame -b:a 320k -map_metadata 0 -id3v2_version 3 "${file%.*}.mp3"
             #   echo;
            done

            # Flacs/Aiffs behalten? Ordnername übergeben.
            local dir=$(echo "${fCon[0]}" | sed 's/\/[^/]*$//' | sed 's/.*\///')
            handle_originals "$dir"
        fi 
    echo -e "${RESET}"
    else

        echo;echo;
        echo -e "\t${green}Keine FLAC/AIFF-Dateien gefunden.${RESET}"
    fi
}

# Funktion zum Umgang mit Originaldateien
handle_originals() {
    echo;echo -e "${blue}${BOLD}"
    read -e -p $'\tDie Originaldateien behalten? (j/n): ' keep_originals
    echo -e "${RESET}${white}"

    if [[ $keep_originals == "j" ]]; then
        mkdir -p "$ORIGINAL_DIR/$1"
        find "$EXTRACT_DIR" -type f \( -name "*.flac" -o -name "*.aiff" -o -iname "*.m4a" \) -exec mv {} "$ORIGINAL_DIR/$1" \;
    else
        find "$EXTRACT_DIR" -type f \( -name "*.flac" -o -name "*.aiff" -o -iname "*.m4a" \) -delete
    fi

    echo -e "${RESET}"
}


# Wechsle direkt zu sort_ep.sh oder sort_alben.sh
forwardToSort() {
    mapfile -t dirSize< <(find "$EXTRACT_DIR" -mindepth 1 -type d  -exec  du -h {} + | cut -d'M' -f1 | sed '/K/d' | cut -d',' -f1)

    # Check ob es EP Ordner gibt
    for folder in "${dirSize[@]}"; do

        if [[ "$folder" -le "66" ]]; then  
            source sort_eps.sh
            display_folder_sizes
        fi
    done
    
    # Sonst zu Alben Sort springen
    source sort_alben.sh
    select_folder
}


# Hauptprogramm
archives_extract
forwardToSort
