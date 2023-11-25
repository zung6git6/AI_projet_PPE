#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo "On veut exactement un argument"
    exit
fi

cd ../URLs/ # pourquoi on a besoin d'aller dans le fichier URLs ?

URLS="$1"

if [ ! -f $URLS ]
then
    echo "On attend un fichier !"
fi

lineno=1
lang=$(basename $URLS .txt)
html_file="../tableaux/$lang.html"

#html_file="../tableaux/tableau.html"

echo "<html><head></head><body>" > $html_file
echo "<table border='1'>" >> $html_file
echo "<tr><th>Ligne</th><th>URL</th><th>Code HTTP</th><th>Encodage</th><th>Aspiration</th><th>Dump</th><th>Compte</th><th>Contexte</th></tr>" >> $html_file

while read -r URL
do
    response=$(curl -s -I -L -w "%{http_code}" -o /dev/null $URL)
    encoding=$(curl -s -I -L -w "%{content_type}" -o /dev/null $URL | grep -P -o "charset=\S+" | cut -d"=" -f2)
    aspi=$(curl -s -L -w "%{http_code}" -o "../aspirations/${lang}-${lineno}.html" $URL) # je pense qu'ici plus besoin de " -w "%{http_code}" "
    dumps=$(lynx -dump $URL > "../dumps-text/${lang}-${lineno}.txt")
    compte=$(grep -w -i -E "(IA|intelligence artificielle|AI|artificial intelligence)" "../dumps-text/${lang}-${lineno}.txt" | wc -w)
    Contextes=$(grep -w -i -E -o -C 2 "(IA|intelligence artificielle|AI|artificial intelligence)" "../dumps-text/${lang}-${lineno}.txt" >> "../Contextes/${lang}-${lineno}.txt")
    echo "<tr>
    <td>$lineno</td>
    <td>$URL</td>
    <td>$response</td>
    <td>$encoding</td>
    <td><a href ="../aspirations/${lang}-${lineno}.html">Aspiration</a></td>
    <td><a href ="../dumps-text/${lang}-${lineno}.txt">Dump</a></td>
    <td>$compte</td>
    <td><a href="../Contextes/${lang}-${lineno}.txt">Contextes</a></td>
    </tr>" >> $html_file
    lineno=$(expr $lineno + 1)
done < $URLS
echo "</table></body></html>" >> $html_file


