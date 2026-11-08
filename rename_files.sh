#!/bin/bash
# Artist & Title == Dateiname
renameAT () {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album/"

    eyeD3 --encoding utf8 --rename='$artist - $title' --force-update "$AlbumPfad" 
    load_array_table
}



# Dateiname == Title
renameTAGS () {
    clear
    echo;echo;
    echo -e "\t${violett}"${BOLD}---\> Schreibe Dateinamen in TITLE Tags \<---${RESET}

    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album/"
    local dateien=$(find "$path/$selected_Album" -iname "*.mp3")

    # find variante
    #find "$path/$selected_Album" -type f -iname "*.mp3" -print0 | xargs -0 -I{} sh -c 'title=$(basename "{}" .mp3); eyeD3 -t "$title" "{}" | grep "äNIXö"'

    while IFS= read -r line; do
        local title=$(echo "$line" | sed -e 's/.*\///; s/.mp3//g');
        eyeD3 -t "$title" "$line" | grep "äNIXö"
    done <<< "$dateien"
    unset titles
    unset paths
    load_array_table
}


# Title == Dateiname
renameT() {
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    eyeD3 --rename='$title' --force-update "$AlbumPfad" | grep -E "äNIXü"
    unset titles
    unset paths
    load_array_table
}

# Tracknummer - Titel == Dateiname
renameNT() {

    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local AlbumPfad="$path/$selected_Album"

    eyeD3 --rename='$track:num - $title' --force-update "$AlbumPfad" | grep -E "äNIXü"
    unset titles
    unset paths
    load_array_table

}