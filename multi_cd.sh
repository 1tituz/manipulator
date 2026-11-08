#!/bin/bash

# wird auf id3tag.sh ausgeführt
check_filesizes() {

    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local mainPath="$path/$selected_Album"

    mapfile -t filesizes < <(find "$mainPath" -type f -iname "*.mp3" -exec  du -h {} + | cut -d'M' -f1 | sed '/K/d' | cut -d',' -f1)
    for file in "${filesizes[@]}"; do
        if [[ $file -gt "50" ]]; then
            sizeAlarm="Track mit "$file"MB Größe. Mögliches Multi CD Album!"
        fi
    done

}

show_fileList() {
    clear
    local path="$DOWNLOAD_DIR/SoundZumEinordnen"
    local mainPath="$path/$selected_Album"

    echo;
    ordner=$(basename "$mainPath")
    strich_ordner "MULTIALBUM SELECTOR: " "$ordner" # ----------------------------------------
    echo;
    echo -e "\t${brown}Immer zuerst die Großen Dateien auswählen und am Schluss den Rest.${RESET}"
    echo;


    mapfile -t fileList < <(find "$mainPath" -type f -iname "*.mp3" -exec  du -h {} +)

    n=1
    for line in "${fileList[@]}"; do

        local size=$(echo "$line" | cut -d'M' -f1 | cut -d'K' -f1 | sed 's/,/./g')
        local path=$(echo "$line" | sed -e 's/.*\///')
 
        # wenn size ($size) größer ist als 50 (limit) - dann ${BOLD} hervorgehoben
        if awk -v size="$size" -v limit="50" 'BEGIN { exit !(size > limit) }'; then
            if [[ $n -le "9" ]]; then
                printf "\t${RESET}${BOLD}%-5s %-7s %-5s \n${RESET}"  "0$n." "$size"MB"" "$path"
                else 
                printf "\t${RESET}${BOLD}%-5s %-7s %-5s \n${RESET}"  "$n." "$size"MB"" "$path"
            fi
        else
            if [[ $n -le "9" ]]; then
                printf "\t${white}%-5s %-7s %-5s \n${RESET}"  "0$n." "$size"MB"" "$path"
                else 
                printf "\t${white}%-5s %-7s %-5s \n${RESET}"  "$n." "$size"MB"" "$path"
            fi
        fi

    ((n++))
    done
    echo;echo;echo;echo;


    echo -e "\t${RESET}Track auswählen (1-${#fileList[@]}) | [r] = Restliche Trax kopieren:"
    read -e -p $'\t$: ' slct


if [[ "$slct" =~ ^[0-9]+$ ]] && [ "$slct" -ge 1 ] && [ "$slct" -le "${#fileList[@]}" ]; then
        # Check ob gültige Zahl eingegeben.
        slct=$(($slct-1))
        local slctTrack=$(echo "${fileList[slct]}" | sed -e 's/.*\///')

        if [[ "${#cdCount[@]}" -ge "1" ]]; then

            # counter +1
            cdCount+=("CD")
            n=$(echo "${#cdCount[@]}")

            eyeD3 --track 1 -A "$album / CD$n" "$mainPath/$slctTrack"
            eyeD3 --rename='$track:num - $album - $title' --force-update "$mainPath/$slctTrack"


        else

            eyeD3 --track 1 -A "$album / CD1" "$mainPath/$slctTrack"
            eyeD3 --rename='$track:num - $album - $title' --force-update "$mainPath/$slctTrack"
            
            cdCount+=("CD")
        fi        
    
        show_fileList
   
    elif [[ "$slct" == "r" ]]; then

        # Restliche Tracks bearbeiten
            t=1
            # counter +1
            cdCount+=("CD")
            n=$(echo "${#cdCount[@]}")


        while IFS= read -r line; do

            eyeD3 --track $t -A "$album / CD$n" "$line"
            eyeD3 --rename='$track:num - $album - $title' --force-update "$line"
            
            ((t++))
        done < <(find "$mainPath" -type f -iname "*.mp3" -not -name "*CD*" | sort -f)
        
        show_fileList
       
    elif [[ -z "$slct" ]]; then
        load_array_table
    else
        echo -e "\t${red}${BOLD}error...irgendwas ist in der function show_fileList() falsch gelaufen :(${RESET}"
        sleep 2s
        show_fileList
fi

}
