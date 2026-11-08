#!/bin/bash

CHECKFREEDISK () {
    # Platz übrig auf Platte | $verf $verw_prozent
    output=$(df -h "$BACKUP_DIR" 2>/dev/null | awk 'NR==2 {print $4, $5}')
    verf=$(echo $output | awk '{print $1}')
    verw_prozent=$(echo $output | awk '{print $2}')

    if [[ $(echo "$output" | grep "%") ]]; then
        # Starte Backup
        BACKUP

        else
        # Fehlermeldung
        echo;echo;echo;
        echo -e "\t${red}${BOLD}FEHLER! FESTPLATTE NICHT GEFUNDEN!${RESET}"
        echo;echo;
        read -e -p $'\tHit [enter]'
        START
    fi
}

BACKUP() {

    clear
    echo;echo;
    echo -e "\t${blue}${BOLD}##### SOUND BACKUP${RESET}"
    echo;echo;
    echo -e "\tFreier Speicher ${BOLD}$verf${RESET}. In Verwendung sind ${BOLD}$verw_prozent${RESET} der Festplatte."
    echo;echo;

    # Eingabe vergangene Tage
    echo -e "\t${white}Die vergangenen Tag seit dem letzten Backup?"
    read -e -p $'\t$: ' slct
    if [[ -z $slct ]]; then
        START
        else

        # BACKUP FILES mit rsync starten
        find $COLLECTION_DIR -atime -$slct -printf %P\\0\\n | rsync -avmh --files-from=- $COLLECTION_DIR $BACKUP_DIR



        echo -e "${RESET}"
        echo;echo;echo;
        output=$(df -h "$BACKUP_DIR" 2>/dev/null | awk 'NR==2 {print $4, $5}')
        verf=$(echo $output | awk '{print $1}')
        verw_prozent=$(echo $output | awk '{print $2}')

        echo -e "\tÜbriger Speicher ${BOLD}$verf${RESET}. In Verwendung sind ${BOLD}$verw_prozent${RESET} der Festplatte."

        # Zurück zu Startseite
        echo;echo;
        read -e -p $'\tHit [enter]'
        START
    fi
}
