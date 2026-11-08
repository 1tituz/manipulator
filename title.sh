#!/bin/bash

load_title_arrays() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album" 


   mapfile -t paths < <(find "$AlbumPfad" -type f -iname "*.mp3" | sort -f)
   mapfile -t titles < <(eyeD3 --verbose "$AlbumPfad" | grep -a -F "title:" | cut -d : -f 2 | sed 's/^ //')
   mapfile -t old_titles < <(eyeD3 --verbose "$AlbumPfad" | grep -a -F "title:" | cut -d : -f 2 | sed 's/^ //')

   show_title_List
}

show_title_List() {
   clear
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album/"
   echo;echo;
   echo -e "\t${blue}${BOLD}##### TITLE BEARBEITEN${RESET}"
   echo;echo;
   echo -e "\t${white}${BOLD}Nr.   Title:${RESET}"
   echo;


   i=1
   for title in "${titles[@]}"; do
    if [[ $i -lt 10 ]]; then
       printf "\t${lightblue}${BOLD}%-4s${RESET} ${lightblue} %-4s \n" "0$i." "$title"
      else
       printf "\t${BOLD}%-4s${RESET} ${lightblue} %-24s \n" "$i." "$title"
    fi
    ((i++))
   done
   echo;echo;
   echo -e "${RESET}"
   echo -e "\t[Nr.] - Einzelne Titel bearbeiten | [s] - Suchen & Ersetzten | [t] - "artist - title" | [c] - CUT, Abschneiden | [g] - Groß/Kleinschreibung"
   echo;
   read -e -p $'\t$: ' work

   case $work in
   [0-9]*) einzeln_bearbeiten ;;
   t) artist_title ;;
   s) suchen_ersetzten ;;
   c) zeichen_navigation ;;
   g) schreibweise ;;
   *) unset titles; unset paths; load_array_table
   esac
}

artist_title() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album"
   mapfile -t art < <(eyeD3 --verbose "$AlbumPfad" | grep -a -F "artist:" | sed '/album/d' | cut -d : -f 2 | sed 's/^ //')
   #echo "${art[@]}"
   echo;
   echo -e "\t${lightblue}Schreibe Daten...${RESET}"
   n=0
   for track in "${titles[@]}"; do
      
      eyeD3 --title "${art[$n]} - $track" "${paths[$n]}" | grep "äNIXü"
      ((n++))
   done
   load_title_arrays
}

# [1] Auf id3tag.sh gedrückt 
artist_title_main() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album"
 # unset art
 #  mapfile -t art < <(eyeD3 --verbose "$AlbumPfad" | grep -a -F "artist:" | sed '/album/d' | cut -d : -f 2 | sed 's/^ //')
   echo;
   echo -e "\t${lightblue}Schreibe Daten...${RESET}"

   n=0
   for track in "${titles[@]}"; do
     # echo "art: ${art[$n]} | track: $track"
     # read -p "warten" fgdgdfgdfg
     # eyeD3 --title "${art[$n]} - $track" "${paths[$n]}" | grep "äNIXü"

     tit=$(kid3-cli -c "get "title" 2" "${paths[$n]}")
     arts=$(kid3-cli -c "get "artist" 2" "${paths[$n]}")

      eyeD3 --title "$arts - $tit" "${paths[$n]}" | grep "äNIXü"



      ((n++))
   done
  unset art
  load_array_table
}

zeichen_navigation() {

   echo;
   echo -e "\t${BOLD}[a] - Ab Zeichen abschneiden | [v] - nZeichen vorne löschen | [h] - nZeichen hinten löschen${RESET}" 
   echo;
   read -e -p $'\t$: ' slct

   case $slct in
   v) vorne_hinten_delete Vorne ;;
   h) vorne_hinten_delete Hinten ;;
   a) cut_hinten ;;
   *) load_title_arrays ;;
   esac
}

schreibweise() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album"
   echo;
   echo -e "\t${blue}${BOLD}Groß/Kleinschreibung anpassen:${RESET}"
   echo;echo;

      i=0
   for title in "${titles[@]}"; do

      #ctext=$(echo "$title" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
      ctext=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/\b\([[:alpha:]]\)/\U\1/g')

      printf "\t%-10s %-28s \n" "Bearbeite:" "$ctext"

      eyeD3 --title "$ctext" "${paths["$i"]}" | grep -E "üNixö"
      titles["$i"]="$ctext"

      ((i++))
   done

   load_title_arrays
}

vorne_hinten_delete() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album"
   echo;
   echo -e "\t${blue}${BOLD}$1 nZeichen Abschneiden${RESET}"
   read -e -p $'\tNummer (0-9) #: ' n
     if [[ -z $slct ]]; then
      load_title_arrays
   fi

   echo;echo;
      i=0
   for title in "${titles[@]}"; do

      if [[ $1 == "Hinten" ]]; then
         # Berechne die neue Länge des Strings
         new_length=$((${#title} - n))
         # Extrahiere den Teilstring bis zur neuen Länge
         ctext="${title:0:new_length}"
      else 
         ctext="${title:n}"
      fi
      printf "\t%-10s %-28s \n" "Bearbeite:" "$ctext"

      eyeD3 --title "$ctext" "${paths["$i"]}" | grep -E "üNixö"
      titles["$i"]="$ctext"

      ((i++))
   done

   load_title_arrays
}

cut_hinten() {
   local path="$DOWNLOAD_DIR/SoundZumEinordnen"
   local AlbumPfad="$path/$selected_Album"
   echo;
   echo -e "\t${blue}${BOLD}Text ab welchen Zeichen Abschneiden${RESET}"
   read -e -p $'\tZeichen: ' slct
     if [[ -z $slct ]]; then
      load_title_arrays
   fi
   read -e -p $'\tBehalte: vorne = [1] <|> hinten = [2]: ' chse
   if [[ -z $chse ]]; then
      #cut_hinten
      load_title_arrays
   fi

   echo;echo;
      i=0
   for title in "${titles[@]}"; do

      ctext=$(echo "$title" | cut -d "$slct" -f $chse)
      printf "\t%-10s %-28s \n" "Bearbeite:" "$ctext"

      eyeD3 --title "$ctext" "${paths["$i"]}" | grep -E "üNixö"
      titles["$i"]="$ctext"
      ((i++))
   done

   load_title_arrays
}


suchen_ersetzten() {
   echo;echo;
   echo -e "\t${blue}${BOLD}Suchen und Ersetzten${RESET} | ${white}Leerzeichen müssen escaped werden, z.b.:\ &\ .${RESET}"
   echo -e "\t"
   echo;
   read -e -p $'\t   Suchen $: ' suche
   read -e -p $'\tErsetzten $: ' ersatz

   # Wenn leer, zurückspringen
   if [[ -z $suche || -z $ersatz ]]; then
      load_title_arrays
   fi

   n=$(find "$AlbumPfad" -type f -iname "*.mp3" | wc -l)
   echo "N: $n"
   for (( i=0; i<$n; i++ )); do
   
   echo "Titel vor änderung:  ${titles[$i]}"
   echo "Suche nach: $suche"
   echo "Ersatz mit: $ersatz"
  #echo "${titles[$i]}" | sed "s|$suche|$ersatz|g"
   ersetzt="${titles[$i]//"$suche"/"$ersatz"}"
   #ersetzt=$(echo "${titles[$i]}" | sed "s|$suche|$ersatz|g") 
   echo "Ersetzt mit: $ersetzt"
   eyeD3 --title "$ersetzt" "${paths["$i"]}"

   
   titles["$i"]="$ersetzt"

   echo "Titel nach änderung: ${titles[$i]}"

   #read -e -p $'\t   Suchen $: ' egete
     
   done 

   load_title_arrays
}

einzeln_bearbeiten() {
   # Arrays zählen ab 0
   if [[ "$work" == ?(-)+([0-9]) ]]; then
      ((work--))
   fi
   echo;echo;
   echo -e "\tEinzeln Bearbeiten:"
   echo;
   echo -e "\t   ${lightblue}${titles[$work]}${RESET}"
   read -e -p  $'\t$: ' btext

   if [[ -z $btext ]]; then
      show_title_List

   else
      eyeD3 --title "$btext" "${paths["$work"]}" | grep -E "üNixö"
      titles["$work"]="$btext"

      load_title_arrays
   fi
}




