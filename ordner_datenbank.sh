#!/bin/bash
update_value() {
        if [[ ! -z $2 ]]; then 
            local key=$1
            local value=$2

            JSON_FILE=$(cat db.json | jq) 
            JSON_FILE=$(echo "$JSON_FILE" | jq --arg key "$key" --arg value "$value" '. += {($key): $value}')

            echo "$JSON_FILE" | jq
            echo "$JSON_FILE" | jq > db.json
        fi
    }


# Create Ordner-Datenbank
dbCREATE() {
    if [[ ! -f "db.json" ]]; then
        JSON_FILE=$(jq --null-input '{}')
        echo $JSON_FILE | jq > db.json  
    fi

# Funktion zum Hinzufügen oder Aktualisieren eines Wertes
    echo;echo;
    echo -e "\t${white}${BOLD}PFADE EINGEBEN${RESET}${white} (leer = keine Änderung)${RESET}"
    echo;echo;
    # Eingabeaufforderungen für jeden Wert
    read -e -p $'\tDownload Ordner: ' download_path
    update_value "DOWNLOAD_DIR" "$download_path"

    read -e -p $'\tMusikkollektions Ordner: ' music_collection
    update_value "COLLECTION_DIR" "$music_collection"
    echo

    read -e -p $'\tAlben Ordner: ' albums_folder
    update_value "ALBUM_DIR" "$albums_folder"

    read -e -p $'\tVarious Artist Ordner: ' various_artist
    update_value "VA_DIR" "$various_artist"

    read -e -p $'\tEPs Ordner: ' eps_folder
    update_value "EP_DIR" "$eps_folder"

    read -e -p $'\tEP Jahres Ordner: ' ep_year_folder
    update_value "EPYEAR_DIR" "$ep_year_folder"
    echo

    read -e -p $'\tBackup Ordner (Externe Festplatte): ' backup_folder
    update_value "BACKUP_DIR" "$backup_folder"
    
    read -e -p $'\tmp3 GUI App Startbefehl: ' mp3GUI
    update_value "mp3GUI" "$mp3GUI"
    echo

    echo -e "\t${BOLD}JELLYFIN Pfade:${RESET}"
    read -e -p $'\tUsername am Server: ' server_username
    update_value "SERVER_USER" "$server_username"

    read -e -p $'\tIP Adresse des Server: ' server_ip
    update_value "SERVER_IP" "$server_ip"

    read -e -p $'\tJellyfin Ordner (unter Downloads): ' jelly_dir
    update_value "JELLY_DIR" "$jelly_dir"

    read -e -p $'\tServer Pfad Filme: ' server_movie_dir
    update_value "SERVER_MOVIE_DIR" "$server_movie_dir"

    read -e -p $'\tServer Pfad Filme2: ' server_movie_dir2
    update_value "SERVER_MOVIE_DIR2" "$server_movie_dir2"

    read -e -p $'\tServer Pfad Filme (nvme Disk): ' server_movie_nvme_dir
    update_value "SERVER_MOVIE_NVME" "$server_movie_nvme_dir"

    read -e -p $'\tServer Pfad Serien: ' server_serien_dir
    update_value "SERVER_SERIEN_DIR" "$server_serien_dir"

    read -e -p $'\tServer Pfad Serien2: ' server_serien_dir2
    update_value "SERVER_SERIEN_DIR2" "$server_serien_dir2"

    # Aktualisiere die Werte in der JSON-Datei
    

    echo;echo;


    

    echo -e "\tDaten wurden gespeichert."
    echo;echo;

    echo -e "\t${white}${BOLD}Hit [Enter]${RESET}"
    read -p " " nada


    dbSHOW
}



DEPENDENCIES() {
# HIER DIE NOTWENDIGEN PROGRAMME EINGEBEN
    dependencies=("jq" "eyeD3" "sed" "awk" "cut")
    missing_deps=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -eq 0 ]; then
        dependMessage=$(echo -e "\t${green}Alle Dependencies sind vorhanden!${RESET}")
        
    else
        echo -e "\t${violett}${BOLD}Die folgenden Programme sind nicht installiert:${RESET}${white}"
        for dep in "${missing_deps[@]}"; do
            echo "- $dep"
        done
        echo;
        echo -e "${violett}${BOLD}Diese MÜSSEN installiert sein um den Manipulator verwenden zu können!${RESET}"
        exit 1
    fi
}




dbSHOW() {
# Überprüfen, ob die JSON-Datei existiert
if [ ! -f "db.json" ]; then
    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### DATENBANK ERSTELLEN${RESET}"
    echo;echo;
    echo -e "\t${red}${BOLD}Die Datenbank muss eingerichtet werden.${RESET}"
    echo;echo;
    echo;echo;
    dbCREATE
fi

clear

# Lade Pfade in Array
mapfile -t json < <(jq -r "to_entries|map(\"\(.key)=\(.value)\")|.[]" "db.json")


for zeile in "${json[@]}"; do

    key=$(echo "$zeile" | cut -d "=" -f 1)
    value=$(echo "$zeile" | cut -d "=" -f 2)
    declare "$key=$value"

done
#echo "$DOWNLOAD_PATH"
echo;echo;
# Ausgabe der gespeicherten Variablen
echo -e "\t${blue}${BOLD}AKTUELL HINTERLEGTE PFADE"
echo -e "\t_________________________${RESET}"
echo;echo;
echo -e "\t${BOLD}MP3 DATEIN CONFIGS${RESET}"
echo -e "\t${white}${BOLD}Download Ordner:${RESET} $DOWNLOAD_DIR"
echo -e "\t${white}${BOLD}Musikkollektions Ordner:${RESET} $COLLECTION_DIR"
echo -e "\t${white}${BOLD}Alben Ordner:${RESET} $ALBUM_DIR"
echo -e "\t${white}${BOLD}Various Artist Ordner:${RESET} $VA_DIR"
echo -e "\t${white}${BOLD}EPs Ordner:${RESET} $EP_DIR"
echo -e "\t${white}${BOLD}EP Jahres Ordner:${RESET} $EPYEAR_DIR"
echo;
echo -e "\t${white}${BOLD}mp3 GUI Software:${RESET} $mp3GUI"
echo -e "\t${white}${BOLD}Backup Ordner:${RESET} $BACKUP_DIR"
echo;echo;
echo -e "\t${BOLD}JELLYFIN CONFIGS${RESET}"
echo -e "\t${white}${BOLD}Username am Server:${RESET} $SERVER_USER"
echo -e "\t${white}${BOLD}IP Adresse des Server:${RESET} $SERVER_IP"
echo;
echo -e "\t${white}${BOLD}Lokaler Pfad zum Jellyfin Ordner:${RESET} $JELLY_DIR"
echo -e "\t${white}${BOLD}Serverpfad Filme:${RESET} $SERVER_MOVIE_DIR"
echo -e "\t${white}${BOLD}Serverpfad Filme2:${RESET} $SERVER_MOVIE_DIR2"
echo -e "\t${white}${BOLD}Serverpfad Filme (nvme Disk):${RESET} $SERVER_MOVIE_NVME"
echo -e "\t${white}${BOLD}Serverpfad Serien:${RESET} $SERVER_SERIEN_DIR"
echo -e "\t${white}${BOLD}Serverpfad Serien2:${RESET} $SERVER_SERIEN_DIR2"

echo;echo;
if [[ -f ".secret.gpg" ]]; then
    echo -e "\t${green}\u2714${RESET} gpg Keyfile gefunden"
    else
    echo -e "\tgpg Keyfile fehlt"
fi
echo;echo;
read -e -p $'\t[g] gpg Key erstellen, Ordner anpassen? [j/n]: ' anpassen
if [[ -z $anpassen ]]; then
    START
    elif [[ $anpassen == "j" ]]; then
    dbCREATE
    elif [[ $anpassen == "g" ]]; then
    source create_gpgKey.sh
    else
    START
fi
}
DEPENDENCIES
dbSHOW