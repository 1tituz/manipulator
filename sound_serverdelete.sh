#!/bin/bash
### SOUNDSERVER COPY ##############################################################################

search(){
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### VOM SOUNDSERVER LÖSCHEN${RESET}"
    echo;echo;echo;
    echo -e  "\t${BOLD}Nach welchen Kriterien suchen?${RESET}"
    echo -e  "\t${white}[zahl]${RESET} = Nach Tage, ${white}[Suchbegriff]${RESET} = Textsuche"
    echo;
    read -e -p $'\t$: ' slct

    if [[ "$slct" == ?(-)+([0-9]) ]]; then
        #ZAHL EINGEGEBEN


        # Falls Zahl Speichern für später
        local zahl="$slct"
        mapfile -t serResult< <(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "find ./bigDisk/Navidrome/music -mindepth 1 -type d -mtime -"$slct"")
        
        senden "$zahl"

        elif [[ "$slct" =~ [[:alpha:]] ]]; then
        #IRGEND EIN TEXT (BUCHSTABEN) EINGEGEBEN

        mapfile -t serResult< <(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "find ./bigDisk/Navidrome/music -mindepth 1 -type d -iname "$slct*"")

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
    echo -e "\t${red}${BOLD}GEFUNDENE ARTISTS/ALBEN:${RESET}"
    echo;
            i=0
        for dir in "${serResult[@]}"; do

            folderName=$(basename "$dir")
            echo -e "\t${BOLD}$i. "$folderName"${RESET}"
            ((i++))
        done
        echo;echo;

        # Select Unterordner
        read -e -p $'\t$: ' slct

        if [[ -z $slct ]]; then
            search
        fi
        echo;echo

        # Suchpfad hinterlegen - weil das ausgegebene Array als suchpfad nicht funktioniert?! 
        ser=$(echo "${serResult[slct]}")

        if [[ -n $1 ]]; then
        # Suche limitiert mit oben eingegebener Zahl
            mapfile -t serCD< <(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "find \"${serResult[slct]}\" -type d -mtime -\"$1\"")
        #    mapfile -t serCD< <(find "${serResult[slct]}" -type d -mtime -"$1")
        else
            mapfile -t serCD< <(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "find \"${serResult[slct]}\" -type d")
        #    mapfile -t serCD< <(find "${serResult[slct]}" -type d)
        fi

        echo -e "\t${red}${BOLD}GEFUNDENE UNTERORDNER:${RESET}"
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
        delFile=$(echo "${serCD[slct]}")
        artist=$(basename "${serCD[0]}")
        echo;echo;
        echo -e "\t    Lösche: $sendFile"
        echo -e "\tVom Ordner: $artist"
        
        ##### $delfile Löschen
        echo;echo;
        gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "rm -rv \"$delFile\""
        echo;echo;
        read -e -p $'\tHit [enter]' wait
        START
}
search