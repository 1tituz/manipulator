#!/bin/bash
echo;echo;echo;
echo -e "\t${blue}${BOLD}##### GPG Key Erstellen${RESET}"
echo;echo;echo;
read -e -p $'\t Server Passwort eingeben: ' pass
echo;
echo -e "\tErstellte .secret Datei"
echo "$pass" > .secret
echo -e "\tErstelle gpg Key"
gpg -c .secret
if [[ $? -eq 0 ]]; then
    echo;
    echo -e "\t${green}\u2714${RESET} Key erfolgreich erstellt"
else
    echo -e "\t${red}${BOLD}ERROR... Irgend ein Fehler :(${RESET}"
fi
echo -e "\tLösche .secret datei"
rm .secret
echo;echo;echo;
read -e -p $'\tErledigt ' dafasf 
START

