#!/bin/bash
### SOUNDSERVER COPY ##############################################################################

search(){
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### KOPIERE ZUM SOUNDSERVER${RESET}"
    echo;echo;echo;
    echo -e  "\t${BOLD}Nach welchen Kriterien suchen?${RESET}"
    echo -e  "\t${white}[zahl]${RESET} = Nach Tage, ${white}[Suchbegriff]${RESET} = Textsuche"
    echo;
    read -e -p $'\t$: ' slct

    if [[ "$slct" == ?(-)+([0-9]) ]]; then
        #ZAHL EINGEGEBEN

        # Falls Zahl Speichern für später
        local zahl="$slct"
        mapfile -t serResult< <(find "$ALBUM_DIR" "$VA_DIR" -mindepth 1 -maxdepth 1 -type d -mtime -"$slct")
        
        senden "$zahl"

        elif [[ "$slct" =~ [[:alpha:]] ]]; then
        #IRGEND EIN TEXT (BUCHSTABEN) EINGEGEBEN

        mapfile -t serResult< <(find "$ALBUM_DIR" "$VA_DIR" -mindepth 1 -maxdepth 1 -type d -iname "*$slct*")
            if [[ $(echo "${#serResult[@]}") == "0" ]]; then
                echo;echo;echo;
                echo -e "\t${red}${BOLD}NICHTS GEFUNDEN :(${RESET}"
                echo;echo;
                read -e -p $'\tHit [enter] ' warten
                search
                else
                senden
            fi
        elif [[ -z "$slct" ]]; then
            START
    fi
}

senden() {
    echo;echo;
    echo;echo;echo;
    echo -e "\t${green}${BOLD}GEFUNDENE ARTISTS/ALBEN:${RESET}"
    echo;
            i=0
        for dir in "${serResult[@]}"; do

            folderName=$(basename "$dir")
            echo -e "\t${BOLD}$i. $folderName${RESET}"
            ((i++))
        done
        echo;echo;

        # Select Unterordner
        read -e -p $'\t$: ' slct

        if [[ -z $slct ]]; then
            search
        fi
        echo;echo

        if [[ -n $1 ]]; then
        # Suche limitiert mit oben eingegebener Zahl
            mapfile -t serCD< <(find "${serResult[slct]}" -type d -mtime -"$1")
        else
            mapfile -t serCD< <(find "${serResult[slct]}" -type d)
        fi

        echo -e "\t${green}${BOLD}GEFUNDENE UNTERORDNER:${RESET}"
        echo;
            i=0
        for dir in "${serCD[@]}"; do

            folderName=$(basename "$dir")
            echo -e "\t${BOLD}$i. $folderName${RESET}"
            ((i++))
        done

        echo;echo;
        # Selektiere Ordner/Album zum kopieren
        read -e -p $'\t$: ' slct
        if [[ -z $slct ]]; then
            search
        fi

        # Selektierte Ordner und Unterordner-Variablen erstellen
        sendFile=$(echo "${serCD[slct]}")
        artist=$(basename "${serCD[0]}")
        echo;echo;
        echo -e "\t     Sende: $sendFile"
        echo -e "\tZum Ordner: $artist"
        
        ##### $sendfile Verschicken
        echo;echo;
        gpg -dq .secret.gpg | sshpass rsync -arhv  "$sendFile" "$SERVER_USER@$SERVER_IP:/home/tituz/bigDisk/Navidrome/music/$artist"
        echo;echo;
        read -e -p $'\tHit [enter]' wait
        START
}
search
