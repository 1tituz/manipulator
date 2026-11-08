#!/bin/bash
# reset funktion
echo;echo;
source multi_cd.sh
source title.sh

album_Anzeigen() {
    clear
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local mainPath="$path/$selected_Album"
    echo;
    # Check ob MultiCD
    check_filesizes
    # CHECK OB DATEINAMEN SONDERZEICHEN ENTHÄLT. Wenn ja Umbenennen.
    DATEI
    # Ordnername extrahieren
    ordner=$(basename "$mainPath")
strich_ordner "DATEIEN IM ORDNER: " "$ordner" #-------------------------------
    # Ordner Inhalt

    echo -e "${white}"
    local dateien=$(find "$path/$selected_Album" \( -name "*.mp3" -o -name "*.jpg" \) | sed -e 's/.*\///') # sed, alles nach dem letzten / löschen.
    printf '%s\n' "$dateien" | sed 's/^/        /' | sort -f

    echo -e "${RESET}";
    echo
strich "MAIN MP3 TAGS:" #-----------------------------------------------
echo;

        # Column breite definieren
        local track_WIDTH=3
        local titles_WIDTH=60
        local alb_WIDTH=40
        local art_WIDTH=30
        local gen_WIDTH=11

    # Header anzeigen
    printf "\t${lightblue}${BOLD}%-${track_WIDTH}s %-${titles_WIDTH}s %-${alb_WIDTH}s %-${art_WIDTH}s %-${gen_WIDTH}s${RESET}${lightblue}\n" "#" "Title" "Album" "Artist" "Genre"
    echo

    # titles abschneiden wenn Text zuviele Zeichen besitzt
    for i in "${!titles[@]}"; do
        # Abschneiden
        local track_truncated="${trackNr[i]:0:track_WIDTH}"
        local titles_truncated="${titles[i]:0:titles_WIDTH}"
        local alb_truncated="${alb[i]:0:alb_WIDTH}"
        local art_truncated="${art[i]:0:art_WIDTH}"
        local gen_truncated="${gen[i]:0:gen_WIDTH}"

        # Tabelle Anzeigen
        printf "\t%-${track_WIDTH}s %-${titles_WIDTH}s %-${alb_WIDTH}s %-${art_WIDTH}s %-${gen_WIDTH}s\n" \
            "$track_truncated" \
            "$titles_truncated" \
            "$alb_truncated" \
            "$art_truncated" \
            "$gen_truncated"
    done

    echo -e "${RESET}";
    echo;
strich "MP3 TAG OVERVIEW:" #-----------------------------------------------
    if [[ ! -z $sizeAlarm ]]; then
    echo
    printf "\t${RESET}${brown}${BOLD}%-28s ${RESET} \n" "$sizeAlarm"
    sizeAlarm=""
    fi
    if [[ ! -z $artistSZ ]]; then
    echo
    printf "\t${violett}${BOLD}%-28s ${RESET} \n" "$artistSZ"
    artistSZ=""
    fi
    echo -e "${lightblue}"
    printf "\t${BOLD}%-12s${RESET} ${lightblue} ${BOLD}%-28s\n" "Albumartist:" "$albumArtist"
    if [[ "$artist" == "### VARIOUS ARTISTS" ]]; then
    printf "\t${BOLD}%-12s${RESET} ${white}${BOLD} %-28s${lightblue}\n" "Artist:" "$artist"
    else
    printf "\t${BOLD}%-12s${RESET} ${lightblue}${BOLD} %-28s \n" "Artist:" "$artist"
    fi
    printf "\t${BOLD}%-12s${RESET} ${lightblue} %-28s\n" "Album:" "$album"
    echo;
    printf "\t${BOLD}%-12s${RESET} ${lightblue} %-28s \n" "Released:" "$date"
    printf "\t${BOLD}%-12s${RESET} ${lightblue} %-28s \n" "Genre:" "$genre"
    printf "\t${BOLD}%-12s${RESET} ${lightblue} %-28s \n" "Cover:" "$cover"
    printf "\t${BOLD}%-12s${RESET} ${lightblue} %-28s \n" "Publisher:" "$publisher"
    echo -e "${RESET}"

    if [[ ! $track_num =~ ^[0-9]+$ ]]; then
    printf "\t${BOLD}${red}%-28s ${RESET} \n" "$track_num"
    echo;
    track_num=""
    fi

    if [[ $cover == "NEIN" ]]; then
    printf "\t${BOLD}${red}%-28s ${RESET} \n" "KEIN COVER!"
    echo
    fi

    if [[ $multiCDMessage == "true" ]]; then
    printf "\t${brown}${BOLD}%-28s ${RESET} \n" "MULTI CD Album"
    echo
    fi

    strich_unten #-----------------------------------------------------

menu_Anzeigen
}

menu_Anzeigen(){
    echo;
    echo -e "\t${blue}${BOLD}##### TOOLS:${RESET}"
    echo;
   # echo -e "\t${blue}${BOLD}UMWANDELN:${RESET}"
    echo -e "\t${BOLD}[1]${RESET} - ${lightblue}[Artist/Title] ==> [Title] ${lightblue}${RESET}\
    ${BOLD}[2]${RESET} ${lightblue}[Artist & Title] =${white}=> Dateiname ${lightblue}${RESET}\
    ${BOLD}[3]${RESET} ${white}Dateiname =${RESET}${lightblue}=> [Title]${RESET}\
    ${BOLD}[4]${RESET} ${lightblue}[Title] =${RESET}=> Dateiname" | column -x

   # echo -e "\t${blue}${BOLD}BEARBEITEN:"
    echo -e "\t${RESET}""${BOLD}[a]${RESET} - Interpret\
    ${BOLD}[A]${RESET} Album\
    ${BOLD}[t]${RESET} Titel\
    ${BOLD}[g]${RESET} Genre\
    ${BOLD}[d]${RESET} Jahr\
    ${BOLD}[n]${RESET} Nummerieren\
    ${BOLD}[c]${RESET} Cover\
    ${BOLD}[m]${RESET} Multi CD\
    ${blue}${BOLD}[k]${RESET} mehr..." | column -x




 info() {
    echo
    echo -e "\t${blue}...weitere Bearbeitungsmöglichkeiten:"
    echo -e "\t${RESET}${BOLD}[5]${RESET} s${lightblue}[TrackNr./Title] =${RESET}=> Dateiname${RESET} \
    ${RESET}${BOLD}[6]${RESET} Behalte nur Standart-Tags\
    ${BOLD}[aa]${RESET} Album Artist\
    ${BOLD}[nn]${RESET} Einzeln Nummerieren\
    ${BOLD}[rm]${RESET} Delete Album\
    ${BOLD}[ep]${RESET} zu EPs kopieren" | column -x
    echo -e "\t${BOLD}[r]${RESET} - Restore Tags\
    ${BOLD}[v]${RESET} Cover anzeigen\
    ${BOLD}[G]${RESET} GUI Editor" | column -x
}

echo;
read -e -p $'\t$: ' eingabe

    case $eingabe in
    #1) source rename_files.sh; renameAT ;;
    1) artist_title_main ;;
    2) source rename_files.sh; renameAT ;;
    3) source rename_files.sh; renameTAGS ;;
    4) source rename_files.sh; renameT ;;
    5) source rename_files.sh; renameNT ;;
    6) standart_tags ;;
    f) load_title_arrays ;;
    a) input "## ARTIST" \-a ;;
    A) input "## ALBUM NAME" \-A ;;
    g) input "## GENRES" \-G ;;
    d) input "## ERSCHEINUNGS JAHR" --recording-date ;;
    aa) albumArtist ;;
    t) source title.sh; load_title_arrays;;
    n) source numbers.sh; nummerieren ;;
    nn) source numbers.sh; einzeln_nummerieren ;;
    G) bash -c "$mp3GUI"; album_Anzeigen ;;
    k) info; menu_Anzeigen ;;
    s) cover_suchen ;;
    c) cover ;;
    v) cover_anzeigen ;;
    r) tags_reset ;;
    rm) delete_Album ;;
    ep) find "$mainPath" -type f \( -iname "*.json" -o -iname "*.nfo" -o -iname "*.txt" -o -iname "*.csv" \) -exec rm "{}" \; ; mkdir -p ""$EP_DIR"/"$EPYEAR_DIR""; cp -rv "$mainPath" ""$EP_DIR"/"$EPYEAR_DIR""; rm -r "$mainPath"; START ;;
    e) exportieren ;;
    j) json_show ;;
    m) source multi_cd.sh; show_fileList ;;
    *) unset titles; unset paths; cdCount=(); START
    esac
}

strich_ordner() {
echo -e "${blue}>------ ${BOLD}"$1"${white}${BOLD}"$2"${RESET} ${blue}---------------------------------------->${RESET}"
}
strich() {
echo -e "${blue}>------ ${BOLD}"$1"${white}"$2"${RESET}${blue} ---------------------------------------------------------------------------------------------------------------------------------->${RESET}"
}
strich_unten() {
echo -e "${blue}>----------------------------------------------------------------------------------------------------------------------------------------------------------->${RESET}"
}

# Verschiedene TAGs ändern (Artist, Album, Genre, Year)
input() {
    echo;
    echo -e "\t${blue}${BOLD}$1 EINGEBEN${RESET}"
    echo;
    read -e -p $'\t$: ' value
    echo;
    if [[ -z $value ]]; then
        album_Anzeigen
    else
        echo -e "\t${lightblue}Schreibe Daten...${RESET}"
        eyeD3 $2 "$value" "$path/$selected_Album" | grep "ä*ü"
        # Variablen updaten für sofortige Anzeige.
        case $2 in
        '-G') genre="$value"; eyeD3 --genre="$genre" "$AlbumPfad"/*.mp3 ;;
        '--recording-date') date="$value"; eyeD3 --recording-date="$date" "$AlbumPfad"/*.mp3 ;;
        '-a') artist="$value"; eyeD3 --artist="$artist" "$AlbumPfad"/*.mp3 ;;
        '-A') album="$value"; eyeD3 --album="$album" "$AlbumPfad"/*.mp3 ;;
        '--album-artist') albumArtist="$value"; eyeD3 --album-artist="$albumArtist" "$AlbumPfad"/*.mp3 ;;
        esac
        unset art
        unset alb
        unset aArtist
        unset date
        load_array_table
    fi
}

# mp3 Tags in Arrays Laden
load_array_table() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    # allInfo.json erstellen (nur wenn nicht existent) - check ob es Various Artists sind (Verschiedene Artists in den id3 tags)
    if [[ ! -f "$AlbumPfad/allTags.json" ]]; then
        eyeD3 -P json "$AlbumPfad" > "$AlbumPfad/allTags.json" 2>/dev/null
    fi

    unset paths
    unset art
    unset alb
    unset titles
    unset trackNr
    unset gen
    unset date
    unset old_titles

    echo;
    echo -e "\tLade mp3 Tags..."
    albumINFO=$(eyeD3 --verbose "$AlbumPfad")
    mapfile -t paths < <(find "$AlbumPfad" -type f -iname "*.mp3" | sort -f)
    mapfile -t aArtist < <(echo "$albumINFO" | grep -E 'album artist:' | cut -d':' -f2 | sed 's/^ //')
    mapfile -t art < <(echo "$albumINFO" | grep -a -F "artist:" | sed '/album/d' | cut -d : -f 2 | sed 's/^ //')
    mapfile -t alb < <(echo "$albumINFO" | grep -a -F "album:" | cut -d : -f 2 | sed 's/^ //')
    mapfile -t titles < <(echo "$albumINFO" | grep -a -F "title:" | cut -d : -f 2 | sed 's/^ //')
    mapfile -t trackNr < <(echo "$albumINFO" | grep "track:" | cut -d':' -f2| sed 's/[A-Za-z ]//g' | sed 's/[[:space:]]*$//g')
    mapfile -t gen < <(echo "$albumINFO" | grep "genre:" | cut -d':' -f3 | sed 's/ (.*$//g' | sed 's/^ //')
    mapfile -t recording < <(echo "$albumINFO" | grep 'recording date:' | cut -d':' -f2 | sed 's/^ //')
    mapfile -t pub < <(echo "$albumINFO" | grep 'Publisher/label:' | cut -d':' -f2 | sed 's/^ //')
    #mapfile -t old_titles < <(eyeD3 --verbose "$AlbumPfad" | grep -a -F "title:" | cut -d : -f 2 | sed 's/^ //')


    albumArtist=$(echo "${aArtist[0]}")
    artist=$(echo "${art[0]}")
    album=$(echo "${alb[0]}")
    date=$(echo "${recording[0]}")
    genre=$(echo "${gen[0]}")
    publisher=$(echo "${pub[0]}")


find_convert_img
check_variousArtists
album_Anzeigen
}

albumArtist() {
    echo;
    echo -e "\t${BOLD}[enter]${RESET} Album Artist löschen"
    echo -e "\t    ${BOLD}[a]${RESET} Album Artist eingeben"
    echo -e "\t    ${BOLD}[x]${RESET} Abbruch"
    echo
    read -e -p $'\t$: ' slct
    echo;
    if [[ -z $slct ]]; then
            eyeD3 --album-artist "" "$AlbumPfad"
            unset aArtist

        elif [[ $slct == "x" ]]; then
            album_Anzeigen

        elif [[ $slct == "a" ]]; then
        input "## ALBUM ARTIST" --album-artist "$AlbumPfad"
        else
        album_Anzeigen

    fi

    load_array_table
}

# CHECK ob es Various Artists gibt.
check_variousArtists() {

   # Annahme: Alle Elemente sind gleich
    local all_equal=true

    # Erstes Element als Referenz speichern
    local first_element="${art[0]}"

    # Schleife durch das Array
    for element in "${art[@]}"; do
        if [[ "$element" != "$first_element" ]]; then
            all_equal=false
            break
        fi
    done

    # Ergebnis ausgeben
    if [[ "$all_equal" == false ]]; then
        artist="### VARIOUS ARTISTS"
    fi

}


# Check ob mehrere Ordner im Folder liegen.
doppel_album_check() {

    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"



    # Wenn 2 Unterordner existieren (Doppelalbum) - Dateien in einen Ordner kopieren und Album Tags (cd1, cd2,..) setzten
    mapfile -t dCount < <(find "$AlbumPfad" -mindepth 1 -type d | sort -f)

    if [[ "${#dCount[@]}" -gt "0" ]]; then
        clear
        echo;
        echo -e "\t${blue}${BOLD}##### ACHTUNG - MEHRERE UNTERORDNER GEFUNDEN!${RESET}"
        echo;echo;echo;

        # Inhalt der Unterordner schön anzeigen ---------
        local folder=$(echo "$AlbumPfad" | sed -e 's/.*\///')
        echo -e "\t${white}${BOLD}$folder${RESET}"
        echo;

            local n=1
        for folder in "${dCount[@]}"; do

            echo -e "\t${brown}${BOLD}CD $n${RESET}"
            echo
            content=$(find "$folder" -type f | sed "s#"$DOWNLOAD_DIR"##g" | sed 's/[^/]*\/[^/]*\///g'  | sort -f)

            printf "${white}%s${RESET}\n" "$content" | sed 's/^/        /'
            echo;echo;

            ((n++))
        done

        echo -e "\t[enter] - Starte bearbeitung | [x] - zurück"
        read -e -p $'\t$: ' slct

        # Dateien Zusammenfügen zur Bearbeitung ---------
            albumname=$(eyeD3 -P nfo "$(echo "${dCount[0]}")" | grep -e "Album" | cut -d':' -f2 | sed 's/ //')

        if [[ -z $slct ]]; then
                 local n=1
            # Album in einem Ordner zusammenfügen
            for folder in "${dCount[@]}"; do

                # CD Nummer in id3tag schreiben
                eyeD3 -A "$albumname / CD$n" "$folder"/*.mp3

                # Dateinamen ändern (CD Nummer sichtbar)
                eyeD3 --rename='$track:num - $album - $title' --force-update "$folder"/*.mp3

                ((n++))
            done

            # Kopieren in Stammordner
            find "$AlbumPfad" -type f -exec mv "{}" "$AlbumPfad" \;

            # Unterordner löschen
            find "$AlbumPfad" -mindepth 1 -type d -exec rm -r "{}" \;

            # MultiCD Hinweis
            multiCDMessage="true"


        elif [[ $slct == "x" ]]; then
            START
        else
            echo;
            echo -e "\terror...verklickt!"
            sleep 1s
            doppel_album_check
        fi

    fi
}


# Tags aus json Datei wiederherstellen.
tags_reset() {
    clear
   # echo;echo;
   # echo -e "\t${red}${BOLD}ACHTUNG!${RESET} ${BOLD}Tag Restore${RESET} funktioniert nicht bei ${BOLD}##VARIOUS ARTISTS##${RESET}."
   # echo -e "\tAm besten Album löschen und aus Backup wiederherstellen."
   # echo;
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    eyeD3 --remove-all "$AlbumPfad"

    items=$(jq -r '.title' "$AlbumPfad/allTags.json" | wc -l)

    for (( i=1; i<=$items; i++ )); do

        local artist=$(jq -r '.artist' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local album_artist=$(jq -r '.album_artist' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local album=$(jq -r '.album' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local title=$(jq -r '.title' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local genre=$(jq -r '.genre' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local date=$(jq -r '.recording_date' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local publisher=$(jq -r '.publisher' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local track_num=$(jq -r '.track_num.count' "$AlbumPfad/allTags.json" | sed -n ""$i"p")
        local path=$(jq -r '.path' "$AlbumPfad/allTags.json" | sed -n ""$i"p")

        eyeD3 --title "$title" --album "$album" --artist "$artist" --track "$track_num" --recording-date "$date" --genre "$genre" --album-artist "$album_artist" --publisher "$publisher" --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" "$path"


    done
    # trackInfo.json löschen und neu erstellen.
    rm -v "$AlbumPfad"/trackInfo.json
    unset titles
    unset paths

    # Auf various artists checken
    check_variousArtists

    album_Anzeigen
}

# json Datei anzeigen
json_show() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"
    cat "$AlbumPfad/allTags.json" | jq
    echo;echo;
    read -e -p $'\tHit [enter]' nixxxx
    album_Anzeigen

}

# Alle Tags löschen - Standard Tags einlesen
standart_tags() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    # Falls $date nicht nur Jahreszahl besitzt (2025-01-02), dann alles hinter den ersten 4 Zeichen löschen.
    if [ ${#date} -gt 4 ]; then
    date="${date:0:4}"
    fi
    #seyeD3 --remove-all --artist="$artist" --album="$album" --title="$title" --recording-date="$date" --genre="$genre" --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" "$AlbumPfad"
    eyeD3 --remove-all "$AlbumPfad"
    # json Datei laden
    json=$(cat "$AlbumPfad/allTags.json" | jq)

    n=$(find "$AlbumPfad" -type f -iname "*.mp3" | wc -l)

    # Arrays deklarieren
    declare -a path=()
    declare -a artist=()
    declare -a title=()
    declare -a tracknr=()
    declare -a genre=()


    for (( i=1; i<=$n; i++ )); do

     # Hole Daten aus json
        get_path=$(echo "$json" | jq -r '.path' | sed -n ""$i"p");
        get_artist=$(echo "$json" | jq -r '.artist' | sed -n ""$i"p");
        get_title=$(echo "$json" | jq -r '.title' | sed -n ""$i"p");
        get_tracknr=$(echo "$json" | jq -r '.track_num.count' | sed -n ""$i"p");
        get_genre=$(echo "$json" | jq -r '.genre' | sed -n ""$i"p");

        if [[ $i -eq 1 ]]; then
            album=$(echo "$json" | jq -r '.album' | sed -n "1p");
            date=$(echo "$json" | jq -r '.recording_date' | sed -n "1p");
        fi


        path+=("$get_path")
        artist+=("$get_artist")
        title+=("$get_title")
        tracknr+=("$get_tracknr")
        genre+=("$get_genre")

        # Arrays zählen ab 0:
        ((i--))

        if [ ${#date} -gt 4 ]; then
            date="${date:0:4}"
        fi
        # Schreib Daten in id3 Tags.
        echo;
        echo -e "\t${lightblue}id3 Tags löschen - Standard Tags erhalten...${reset}"
        echo;
        eyeD3 -a "${artist[$i]}" -t "${title[$i]}" -n "${tracknr[$i]}" -G "${genre[$i]}" -A "$album" --recording-date "$date" --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" "${path[$i]}" | grep "öNIXÜ"
        ((i++))

    done

    check_variousArtists
    album_Anzeigen

}

delete_Album() {
    # Ausgewähltes Album Löschen
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"
    rm -r "$AlbumPfad"
    START
}

exportieren() {
    echo;
    strich_unten
    echo;
    echo -e "\t${blue}${BOLD}##### ALBUM EXPORTIEREN${RESET}"
    echo;echo;
    echo -e "\t${BOLD}[a]${RESET}lbum oder ${BOLD}[v]${RESET}arious artists"
    echo;
    read -e -p $'\t$: ' slct
    case $slct in
    a) source export_files.sh; albenExport "$ALBUM_DIR";;
    v) source export_files.sh; albenExport "$VA_DIR" ;;
    *) album_Anzeigen
    esac
}

doppel_album_check
load_array_table
