#!/bin/bash

nummerieren() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album/"
    #local dateien=$(find "$path/$selected_Album" -iname "*.mp3" | sort -f)
    mapfile -t dirs< <(find "$path/$selected_Album" -iname "*.mp3" | sort -f)
    echo;echo;
    echo -e "\t${blue}${BOLD}### NUMMERIEREN${RESET}"
    echo;
    echo -e "\t${BOLD}[n]${RESET} Tracknummern zuerst in Dateinamen schreiben? (wichtig für alphabetische Sortierung/Nummerierung)"
    echo -e "\t${BOLD}[m]${RESET} Nur Total Tracks löschen"
    echo -e "\t${BOLD}[e]${RESET} Einzeln Nummerieren mit Browser"
    echo -e "\t${BOLD}[enter]${RESET} Standard Nummerierung"
    echo;
    read -p $'\t$: ' slct

    if [[ $slct == "n" ]]; then
            # Tracknummern in Datei Schreiben
            echo
            echo -e "\t1. Tracknummern in Dateinamen schreiben"
            for line in "${dirs[@]}"; do
                eyeD3 --rename='$track:num - $title' --force-update "$line" | grep -E "äNIXü"
            done
            echo -e "\t2. Tracknummern löschen"
            # Zuerst alle Tracknummern löschen
            eyeD3 --track 0 --track-total 0 "$path/$selected_Album"/*.mp3 | grep "öNIXä"

            # Array mit neuen Dateinamen einlesens
            unset dirs
            mapfile -t dirs< <(find "$path/$selected_Album" -iname "*.mp3" | sort -f)


            echo -e "\t3. Nummerieren"
            # Nummerieren
            local i=1
             for line in "${dirs[@]}"; do
                
                eyeD3 --track $i "$line" | grep -e "äNIXü"
                ((i++))
            done

        elif [[ -z $slct ]]; then
            # Zuerst alle Tracknummern löschen
            echo
            echo -e "\t1. Tracknummern löschen"
            eyeD3 --track 0 --track-total 0 "$path/$selected_Album"/*.mp3 | grep "öNIXä"

            # Nummerieren
            echo -e "\t2. Nummerieren"
            local i=1
             for line in "${dirs[@]}"; do
                
                eyeD3 --track $i "$line" | grep -e "äNIXü"
                ((i++))
            done

        elif [[ $slct == m ]]; then
            echo -e "\t1. Total Tracks löschen"
            eyeD3 --track-total 0 "$path/$selected_Album"/*.mp3 | grep "öNIXä"
            
            
      elif [[ $slct == e ]]; then
            clear;
            einzeln_nummerieren
        
        else
        START        
    fi





    load_array_table
}

# Einzeln Nummerieren Funktion
nummer_eingabe() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album/"

    mapfile -t dir< <(find "$path/$selected_Album" -iname "*.mp3" | sort -f)

    echo;echo;
    echo -e "\t${BOLD}TRACKLIST:${RESET}"
    echo;

    # Korrekte reihenfolge von Pfad in das array titles speichern
    for track in "${dir[@]}"; do

        title=$(eyeD3 --verbose "$track" | grep -oP 'title: \K.*')
        echo -e "\t$title"
        declare -a titles
        titles+=("$title")
    done
    echo;echo;

    echo -e "\tNavigation: ${BOLD}[z]${RESET} Einen Titel Zurück | ${BOLD}[enter]${RESET} Zum nächsten Track | ${BOLD}[x]${RESET} Abbruch"

    # array erstellen für doppelte eingabe Check
    declare -a numbers=()

    for ((i=0; "${#dir[@]}">i;  i++)); do

    local nextTrack=$(echo "${titles[i]}")
    local currentPfad=$(echo "${dir[i]}")

    echo -e "${lightblue}${BOLD}"
    read -p "        $nextTrack #: " trackNummer


     if [[ $trackNummer == ?(-)+([0-9]) ]]; then 
            # eingaben in array schreiben und checken ob es doppelt eingaben gibt.
            if [[ " ${numbers[@]} " =~ " $trackNummer " ]]; then
                echo -e "\t${red}${BOLD}Die Zahl $trackNummer wurde bereits eingegeben.${RESET}"
                ((i--))

            else
                numbers+=("$trackNummer")
                # trackNummer hinterlegen
                eyeD3 --track $trackNummer "$currentPfad" | grep -e "üNIXö"
            fi
            
            elif [[ $trackNummer = "x" ]]; then
            echo -e "\t${red}${BOLD}Abbruch${RESET}"
            sleep 1s
            album_Anzeigen

            elif [[ $trackNummer = "z" ]]; then
            echo -e "\t${blue}Zurück${RESET}"
            i=$((i-2))
                if [[ $i -le "0" ]]; then
                    echo -e "\t${green}${BOLD}Erster Track!${RESET}"
                    i=0
                fi

            else
            echo -e "\t${violett}${BOLD}Keine Eingabe${RESET}"
            ((i--))
        fi
    done 

    album_Anzeigen
}

einzeln_nummerieren() {
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### Nummerieren${RESET}"
    echo;echo;
    echo -e "${BOLD}";
    read -e -p $'\tBenötigen wir den Browser? [j/n]: ' browser
    echo -e "${RESET}"
    if [[ $browser == "j" ]]; then
        # Browser starten, $artist und $album sind globale Variablen
        firefox --new-window --search "$artis $album" &>/dev/null & disown
        
        nummer_eingabe
        elif [[ $browser == "n" ]]; then
        nummer_eingabe
        else
        album_Anzeigen
    fi
}
