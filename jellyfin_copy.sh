#!/bin/bash
serienSenden() {
    echo;echo;
    mapfile -t srvSerien< <(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "find \"$SERVER_SERIEN_DIR2\" -mindepth 1 -type d")

    # Gefundene Serienordner auflisten
    echo -e "\t${BOLD}Gefundene Serien:${RESET}"
    echo;
        i=0
    for line in "${srvSerien[@]}"; do
        sTitle=$(basename "$line")
        echo -e "\t$i. $sTitle"
        ((i++))

    done

    # Gewünschten Serienordner auswählen
    echo;echo;
    read -e -p $'\tSerie auswählen, [n] Neue Serie: ' sctl
    echo;echo;

        # Wenn neue Serie, Ordner am Server erstellen
    if [[ $sctl == "n" ]]; then

        read -e -p $'\tSerienname: ' serienname
        gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP "mkdir -p \"$SERVER_SERIEN_DIR2/$serienname\""
        search

    fi

    # Pfad Variable erstellen
    sendPfad=$(echo "${srvSerien[sctl]}")

    # SERIE SENDEN
    for line in "${toSend[@]}"; do

        gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$line" $SERVER_USER@$SERVER_IP:"$sendPfad"

    done

    echo;echo;echo;
    read -e -p $'\tHit [enter] (löscht lokale Serienfiles) '  waiting

    for line in "${toSend[@]}"; do

        rm "$line"

    done
    START

}


kopieren(){
    echo;echo;
    case $2 in
        f) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_MOVIE_DIR2" ;;
        f1) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_MOVIE_DIR" ;;
        fn) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_MOVIE_NVME" ;;
        s) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_SERIEN_DIR2" ;;
        s1) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_SERIEN_DIR" ;;
        sn) gpg -dq .secret.gpg | sshpass rsync -va --ignore-existing --progress "$1" $SERVER_USER@$SERVER_IP:"$SERVER_SERIEN_NVME" ;;

    esac
}


speichplatzAnzeige() {
    # Verbleibenden speicherplatz anzeigen
    output2=$(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP df -h "/home/tituz/jellyDisk2" 2>/dev/null | awk 'NR==2 {print $4, $5}')
    verf2=$(echo $output2 | awk '{print $1}')
    verw_prozent2=$(echo $output2 | awk '{print $2}')
    output=$(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP df -h "/home/tituz/jellyDisk" 2>/dev/null | awk 'NR==2 {print $4, $5}')
    verf=$(echo $output | awk '{print $1}')
    verw_prozent=$(echo $output | awk '{print $2}')
    Noutput=$(gpg -dq .secret.gpg | sshpass ssh $SERVER_USER@$SERVER_IP df -h "/home/tituz/nvmeDisk" 2>/dev/null | awk 'NR==2 {print $4, $5}')
    Nverf=$(echo $Noutput | awk '{print $1}')
    Nverw_prozent=$(echo $Noutput | awk '{print $2}')

    echo -e "\t${BOLD}JellyDisk2${RESET}, ${BOLD}$verf2${RESET} verfügbar -> zu ${BOLD}$verw_prozent2${RESET} Voll"
    echo -e "\t${BOLD} JellyDisk${RESET}, ${BOLD}$verf${RESET} verfügbar -> zu ${BOLD}$verw_prozent${RESET} Voll"
    echo -e "\t ${BOLD} NVMEDisk${RESET}, ${BOLD}$Nverf${RESET} verfügbar -> zu ${BOLD}$Nverw_prozent${RESET} Voll"
}

BEARBEITEN(){
    clear
    echo;echo;
    echo -e "Vorhandene Streams:"
    echo
    echo -e "§1: $1"
    ffmpeg -i "$1" 2>&1 | grep Stream
    echo
    echo -e "\tBearbeite Audio [a] | Subs [s]"
    read -e -p $'\t$: ' slct
    echo;
    if [[ $slct == "a" ]]; then
        AUDIO "$1"
    elif [[ $slct == "s" ]]; then
        SUBS "$1"
    else
        search
    fi
}
AUDIO(){
    original_file="$1"
    basename=$(basename "$original_file")
    name_without_ext="${basename%.*}"
    extension="${basename##*.}"
    output=""$DOWNLOAD_DIR"/"${name_without_ext}"_a."${extension}""

    echo;echo;
    ffmpeg -i "$1" 2>&1 | grep Audio
    echo
    echo -e "\tAUDIO Stream auswählen:"
    read -e -p $'\t$: ' stream
    ffmpeg -i "$1" -map 0 -map -0:"$stream" -c copy "$output"
    read -e -p $'\t$: ' dfdf
    rm "$1"
    search
}
SUBS(){
    original_file="$1"
    basename=$(basename "$original_file")
    name_without_ext="${basename%.*}"
    extension="${basename##*.}"
    output=""$DOWNLOAD_DIR"/"${name_without_ext}"_s."${extension}""

    echo;echo;
    ffmpeg -i "$1" 2>&1 | grep Subtitle
    echo
    echo -e "\tSubtitle Stream auswählen:"
    read -e -p $'\t$: ' stream
    ffmpeg -i "$1" -map 0:"$stream" -c:s srt "$DOWNLOAD_DIR"/subtitles.srt
    sed -i '/MoviesMod/Id' "$DOWNLOAD_DIR"/subtitles.srt
    ffmpeg -i "$1" -i "$DOWNLOAD_DIR"/subtitles.srt -map 0:v -map 0:a -map 1 -c copy "$output"
    read -e -p $'\t$: ' dfdf
    rm "$DOWNLOAD_DIR"/subtitles.srt
    rm "$1"
    search
}

search(){
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### FILME ZU JELLYFIN SENDEN${RESET}"
    echo;

    ### Speicherplatz Panel aufrufen
    speichplatzAnzeige


    echo;echo;echo;

    ### Gefundene Filmdaten auflisten
    mapfile -t dirs< <(find "$DOWNLOAD_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.srt" \) | sort -f )
        i=0
    for line in "${dirs[@]}"; do
        film=$(basename "$line")
        echo -e "\t$i. $film"
        ((i++))
    done
    echo;echo;


    echo -e  "\t${BOLD}Welche Daten sollen kopiert werden?${RESET}"
    echo -e  "\tMehrere Angaben möglich${white} z.b. [2 3]${RESET}"
    echo;
    read -e -p $'\t$: ' slct

    if [[ -z $slct ]]; then
        START
    fi

    # Gewünschte Ordner in Array schreiben
    IFS=' ' read -ra files <<< "$slct"
    echo;echo;


    ### Ausgewählte Dateien anzeigen

    for i in "${!files[@]}"; do
        # Hinterlegte eingegebene Zahlen in die Variable n speichern
        n=$(echo "${files[i]}")
        unset pfad # unbeding löschen
        # Pfad the des hinterlegten dirs auslesen
        pfad="$(echo ${dirs[n]})"
        showPfad=$(basename "$pfad")

        # Pfad in neuen Array speichern
        unset toSend # unbeding löschen
        toSend+=("$pfad")
    echo -e "${violett}"
    ffmpeg -i "$toSend" 2>&1 | grep Stream
    echo -e "${RESET}"
    echo;

       echo -e "\t${brown}${BOLD}$showPfad${RESET}"
       echo;echo;

    done

    echo;echo;
    echo -e "\t[f] Film2, [f1] Film, [fn] Film (NVME Disk)"
    echo -e "\t[s] Serie, [b] Bearbeiten"
    echo;
    read -e -p $'\t$: ' kind

    if [[ $kind == "s" ]]; then
        # Serien funktion aufrufen
        serienSenden "$toSend" "$kind"

        elif [[ $kind == "b" ]]; then
        BEARBEITEN "$toSend"
        elif [[ -z $kind ]]; then
        START

    fi
    echo;
    echo -e "${brown}${BOLD}"
    read -e -p $'\tFilmname: ' filmname
    read -e -p $'\tRelease: ' year
    echo -e "${RESET}"

    echo;
    if [[ $kind == "f" ]]; then
        platte="jellyDisk2"
        elif [[ $kind == "f1" ]]; then
            platte="jellyDisk"
        elif [[ $kind == "fn" ]]; then
            platte="nvme Disk"
        else
        echo -e "   error! Fehler in der Festplatten-Auswahl..."
    fi

    echo -e "\tSende ${blue}${BOLD}$filmname [$year]${RESET} zu ${blue}${BOLD}$platte${RESET}"
    echo;echo;
    echo -e  "\t${white}[enter]${RESET} to Send. ${white}[x]${RESET} to Abort"
    read -e -p $'\t$: ' slct
    echo;echo;
    if [[ -z $slct ]]; then

            # Ordner Erstellen
            mkdir -p "$JELLY_DIR/$filmname [$year]"
            dir=$(echo "$JELLY_DIR/$filmname [$year]")

            # Dateien in Ordner kopieren
            for line in "${toSend[@]}"; do
                mv "$line" "$dir"
            done

            # Zu SERVER Kopieren
            kopieren "$dir" "$kind"

        else
            unset dirs
            unset files
            unset "$toSend"
            unset slct
            declare -A files
            declare -A dirs
            declare -A toSend
            search
    fi


    echo;echo;
    read -e -p $'\tHit [enter] ' wait
    echo;echo;

    # Ordner löschen wenn nur 1 Unterordner existiert.
    if [[ $(find "$JELLY_DIR" -mindepth 1 -type d | wc -l) -lt "2" ]]; then
        rm -r "$JELLY_DIR"
        else
        rm -r "$dir"
    fi

    START
}
