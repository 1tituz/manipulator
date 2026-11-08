#!/bin/bash
delUnusedTags() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    eyeD3 --remove-v1 --remove-frame TIPL --remove-frame COMM --remove-frame TPOS --remove-frame TXXX --remove-frame TCOM --remove-frame TPE3 --remove-frame TPE4 --remove-frame TIT1 --remove-frame TIT3 --remove-frame TLAN --remove-frame TBPM  --remove-frame TKEY --remove-frame TCOP --remove-frame TSRC --remove-frame WOAR --remove-frame WXXX --remove-frame USER --remove-frame USLT --remove-frame SYLT --remove-frame RVA2 --remove-frame EQU2 --remove-frame PCNT --remove-frame POPM --remove-frame RBUF --remove-frame LINK --remove-frame POSS --remove-frame COMR --remove-frame ENCR --remove-frame GRID  "$AlbumPfad" | grep -e "üNIXä"
}

keepOnlyRegularTags() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    echo -e "\t${blue}${BOLD}##### ALBUM EXPORT STARTED${RESET}"
    echo;echo;

    # Neue json Datei schreiben, weil Daten geändert.
    tags=$(eyeD3 -P json  "$AlbumPfad" 2>/dev/null)


    # objekte in arrays umschließen.
    allTags=$(echo "$tags" | jq -s .)

    # arrays zählen.
    arrayCount=$(echo "$allTags" | jq 'length')

    # Alle id3 Tags löschen. Ich verwende id3v2 weil eyeD3 beim löschen zurzeit eine python fehlermeldung auswirft und abbricht!
    id3v2 -D "$AlbumPfad"/*.mp3 &>/dev/null

    # Extrahiere die relevanten Daten mit jq
    for (( i=0; i<arrayCount; i++ )); do
        pfad=$(echo "$allTags" | jq -r ".[$i].path | tostring")
        TRACK=$(echo "$allTags" | jq -r ".[$i].track_num.count")
        ARTIST=$(echo "$allTags" | jq -r ".[$i].artist")
        ALBUM=$(echo "$allTags" | jq -r ".[$i].album")
        ALBUMARTIST=$(echo "$allTags" | jq -r ".[$i].album_artist")
        TITLE=$(echo "$allTags" | jq -r ".[$i].title")
        DATE=$(echo "$allTags" | jq -r ".[$i].best_release_date")
        GENRE=$(echo "$allTags" | jq -r ".[$i].genre")


        # Albumartist löschen falls null
        if [[ $ALBUMARTIST == null ]]; then

         # Tags ohne album-artist in die Datei schreiben
            eyeD3 --track="$TRACK" \
            --artist="$ARTIST" \
            --album="$ALBUM" \
            --title="$TITLE" \
            --recording-date="$DATE" \
            --genre="$GENRE" \
            --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" \
            "$pfad" &>/dev/null

        else

            # Tags mit album-artistin die Datei schreiben
            eyeD3 --track="$TRACK" \
            --album-artist="$ALBUMARTIST" \
            --artist="$ARTIST" \
            --album="$ALBUM" \
            --title="$TITLE" \
            --recording-date="$DATE" \
            --genre="$GENRE" \
            --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" \
            "$pfad" &>/dev/null
        fi
    done
}


coverTOid3() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"
    find_convert_img

    imgCheck=$(eyeD3 --verbose "$AlbumPfad" | grep -o "FRONT_COVER")
    if [[ -z "$imgCheck" ]]; then
        trax=$(find "$AlbumPfad" -iname "*.mp3")
        echo;
        echo -e "\t${lightblue}cover.jpg muss noch in id3 Tags geschrieben werden...${reset}"
        echo;
        OLDIFS="$IFS"
        IFS=$'\n'
        for file in $trax; do
            eyeD3 --add-image "$AlbumPfad/cover.jpg:FRONT_COVER" "$file" | grep "öNIXü"
        done
    fi
}

# Was tun am ende des Exportvorgangs.
delete_sortOrdner(){
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    if [[ $(find "$path" -mindepth 1 -type d | wc -l) -eq "0" ]]; then
        # Ordner löschen -> START
        rm -r "$path"
        START
    else
        # Alben Auswahl
        select_folder
    fi;
}

# Check ob es Dateinamen gibt die nicht mit dem NTFS Filesystem kompatibel sind.
sonderzeichen_check() {
    if echo "$artist" | grep -q '[\:\*\?\"\<\>\|]'; then
        artist=$(echo "$artist" | sed 's/[\:\*\?\"\<\>\|]/_/g')
    fi
    if echo "$album" | grep -q '[\:\*\?\"\<\>\|]'; then
        album=$(echo "$album" | sed 's/[\:\*\?\"\<\>\|]/_/g')
    fi
    for file in "$mainPath"/*.mp3; do
        newname=$(echo "$file" | sed 's/[\:\*\?\"\<\>\|]/_/g')
        mv "$file" "$newname" > /dev/null 2>&1
    done

    # Datum auf Jahrezahl schneiden, falls z.b. "2025-01-21" hinterlegt ist.
    date="${date:0:4}"
}

DATEI () {

    if [[ $(find "$mainPath" -type f -name "*[<>+=:|?$\*\"]*") ]]; then

        # Dateicheck nach Sonderzeichen und doppelte Leerzeichen
        echo;echo;
        echo -e "\t${blue}${BOLD}Komische Zeichen im Dateinamen gefunden - Dateiname wird konvertiert.${RESET}"
        echo;echo;


        find "$mainPath" -type f -name "*[<>+=:|?$\*\"]*" | while read FILE ; do
        newfile="$(echo ${FILE} | sed -e "s/[<>+=:|?$\*\"]/_/g")" ;
        echo "neuer Name: $newfile"
        mv -v "${FILE}" "${newfile}" ;
        done

        find "$mainPath" -type f -name "*  *" | while read FILE ; do
        newfile="$(echo ${FILE} | sed -e "s/  / /g")" ;
        echo "neuer Name: $newfile"
        mv -v "${FILE}" "${newfile}" ;
        done

    fi
}

dateinamen_check() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"
    # Dateinname auf Sonderzeichen checken
    sZeichen=$(find "$AlbumPfad" -type f | grep  '[\:\*\?\"\<\>\|]')
    if [[ -z "$sZeichen" ]]; then

        # Dateicheck nach Sonderzeichen und doppelte Leerzeichen
        echo -e "\t${blue}Komische Zeichen im Dateinamen gefunden - Dateiname wird konvertiert.${RESET}"
        echo;echo;

        find "$mainPath" -type f -name "*[<>+=:|,;?$\*\"]*" | while read FILE ; do
        newfile="$(echo ${FILE} | sed -e "s/[<>+=:|,;?$\*\"]/_/g")" ;
        echo "neuer Name: $newfile"
        mv -v "${FILE}" "${newfile}" ;
        done

        find "$mainPath" -type f -name "*  *" | while read FILE ; do
        newfile="$(echo ${FILE} | sed -e "s/  / /g")" ;
        echo "neuer Name: $newfile"
        mv -v "${FILE}" "${newfile}" ;
        done

    fi
}
# HAUPT EXPORT-SCRIPT
albenExport() {
    # Check ob es sich um ein multicd handelt

    if [[ "$(find "$mainPath" -type f -name "*CD*")" ]]; then
        hauptPfad="$1"
        mulidCD_albenExport
    fi
    echo;echo;
    # Sonderzeichen Check
    sonderzeichen_check

    # Nur Standard id3 Tags erhalten
    #delUnusedTags
    keepOnlyRegularTags

    # Check ob Cover in id3 Tags geschrieben sind
    coverTOid3

    # Dateien umbenennen
    eyeD3 --rename='$track:num - $artist - $title' --force-update "$mainPath"

    # Check ob Sonderzeichen das NTFS Filesystem nicht erkennt in Dateinamen enthalten sind.
    DATEI

    # Daten Kopieren
    # Zuerst Check ob Albumartist existiert
    if [[ -n "$albumArtist" ]]; then
        kunstler="$albumArtist"
    else
        kunstler="$artist"
    fi

    # Jetzt kopieren
    mkdir -p "$1/$kunstler/$album [$date]"
    find "$mainPath" -type f \( -iname "*.mp3" -o -iname "*.jpg" \) -exec cp -r "{}" "$1/$kunstler/$album [$date]" \;
    rm -r "$mainPath"
    echo;echo;

    echo -e "\t${blue}${BOLD}ALBUM EXPORT COMPLETED #####${RESET}"
    echo;echo;
    echo -e "\t${white}${BOLD}Hit [Enter]${RESET}"
    echo;
    read -p " " nada

    delete_sortOrdner


}

mulidCD_albenExport() {
    echo;echo;
    # Sonderzeichen Check
    sonderzeichen_check

    # Nur Standard id3 Tags erhalten
    #delUnusedTags
    keepOnlyRegularTags

    # Check ob Cover in id3 Tags geschrieben sind
    coverTOid3

    # Dateien umbenennen
    eyeD3 --rename='$track:num - $album - $title' --force-update "$mainPath"

    # Check ob Sonderzeichen das NTFS Filesystem nicht erkennt in Dateinamen enthalten sind
    DATEI

    # CDs zählen und Album Name holen (CDx löschen für Ordnername)
    albumCount=$(eyeD3 -P nfo "$mainPath" | grep -e "Album" | wc -l)
    albumName=$(eyeD3 -P nfo "$mainPath" | grep  -e "Album" | cut -d':' -f2 | sed 's/^ //' | cut -d'/' -f1 | sed 's/.$//' | sed -n '1p')
    # Daten Kopieren
    # Zuerst Check ob Albumartist existiert
    if [[ -n "$albumArtist" ]]; then
        kunstler="$albumArtist"
    else
        kunstler="$artist"
    fi

    # Jetzt kopieren
    # Erstelle korrekte anzahl an Unterordner
    for (( i=1; i<=$albumCount; i++)); do
        mkdir -p "$hauptPfad/$kunstler/$albumName [$date]/CD$i"

        # Daten Kopieren
        find "$mainPath" -type f \( -name "*CD$i*" -o -name "*.jpg" \) -exec cp -r "{}" "$hauptPfad/$kunstler/$albumName [$date]/CD$i" \;
    done
    find "$mainPath" -type f -name "*.jpg" -exec cp -r "{}" "$hauptPfad/$kunstler/$albumName [$date]" \;


    rm -rv "$mainPath"
    echo;echo;

    echo -e "\t${blue}${BOLD}ALBUM EXPORT COMPLETED #####${RESET}"
    echo;echo;
    echo -e "\t${white}${BOLD}Hit [Enter]${RESET}"
    echo;
    read -p " " nada

    delete_sortOrdner

}
