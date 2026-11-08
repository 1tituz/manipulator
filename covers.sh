#!/bin/bash


cover() {
    echo;
    strich_unten
    echo -e "\t${blue}${BOLD}Cover bearbeiten:${RESET}"
    echo;
    echo -e "\t[1] - Cover aus ID3 Tags laden"
    echo -e "\t[2] - Cover in ID3 Tags schreiben"
    echo -e "\t[s] - Cover suchen"
    echo -e "\t[d] - Alle Bilddateien löschen"
    echo -e "\t[v] - Cover anzeigen"
    echo
    read -e -p $'\t$: ' eingabe

    case $eingabe in
        1) get_cover ;;
        2) write_cover ;;
        s) cover_suchen ;;
        d) delete_all_images ;;
        v) cover_anzeigen ;;
        *) album_Anzeigen ;;
    esac 
}

find_convert_img() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    if [[ -f "$AlbumPfad"/cover.jpg ]]; then        
        cover="Ja"

        elif [[ $(find "$AlbumPfad" -type f \( -iname "*.jpg" -o -iname "*.webp" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \)) ]]; then
        # Falls nur irgendeine Bilddatei im Ordner liegt - Konvertieren zu cover.jpg und löschen.
            
            coverIMG=$(find "$AlbumPfad" -type f \( -iname "*.jpg" -o -iname "*.webp" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \))
            magick "$coverIMG" "$AlbumPfad"/cover.jpg
            rm "$coverIMG"

                # NEUER Check ob ein cover gefunden wurde
                if [[ -f $AlbumPfad/cover.jpg ]]; then
                    cover="Ja"
                    else
                    cover="NEIN"
                fi

        else
        # Sonst Check ob cover in id3 Tags enthalten ist 
           
            track=$(find "$AlbumPfad" -iname "*.mp3")
            one=$(echo "$track" | sed -n '1p')
            eyeD3 --write-images="$AlbumPfad" "$one" | grep "#+nix+."
            
            # extrahiertes jpg umbenennen und löschen
            find "$AlbumPfad" -type f \( -iname "*.jpg" -o -iname "*.webp" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -exec magick "{}" "$AlbumPfad"/cover.jpg \;
            find "$AlbumPfad" -type f \( -iname "FRONT_COVER.jpg" -o -iname "*.webp" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -exec rm "{}" \;
                    
                # NEUER Check ob ein cover gefunden wurde
                if [[ -f $AlbumPfad/cover.jpg ]]; then
                    cover="Ja"
                    else
                    cover="NEIN"
                fi
    fi
}
# cover datei in mp3 speichern
write_cover() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    find_convert_img

    trax=$(find "$path/$selected_Album" -iname "*.mp3")
    OLDIFS="$IFS"
    IFS=$'\n'
    for file in $trax; do
        eyeD3 --remove-all-images "$file"
        eyeD3 --add-image "$path/$selected_Album/cover.jpg:FRONT_COVER" "$file"
    done
    echo;echo;
    read -e -p $'\tHit [enter] ' dfsdf
    cover
}

delete_all_images() {
    find "$path/$selected_Album" -type f \( -iname "*.webp" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.jpg" \) -exec rm "{}" \;
    while IFS= read -r file; do
    eyeD3 --remove-all-images "$file"
    done < <(find "$path/$selected_Album" -type f -iname "*.mp3")
    echo;
    echo -e "\t${green}${BOLD}Bilder gelöscht${RESET}"
    echo;
    cover
}

# cover datei aus mp3 laden.
get_cover() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"

    trax=$(find "$path/$selected_Album" -iname "*.mp3")
    OLDIFS="$IFS"
    IFS=$'\n'
    for file in $trax; do
        eyeD3 --write-images="$path/$selected_Album/" $file
        if [[ $? -eq 0 ]]; then 
            mv "$path/$selected_Album/FRONT_COVER.jpg" "$path/$selected_Album/cover.jpg"
            album_Anzeigen
        else
            echo "keine jpg gefunden"
            sleep 2s
        fi
    done
}
# cover anzeigen mit imagemagick
cover_anzeigen() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    find_convert_img
    display -resize $(xdpyinfo | grep dimensions | awk '{print $2}') "$path/$selected_Album/cover.jpg"
    if [[ "$eingabe" == "v" ]]; then
        album_Anzeigen
    else
        cover
    fi
}

cover_suchen() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"

    firefox --new-tab --search "$artist $album"

    find_convert_img
    
	cover
}