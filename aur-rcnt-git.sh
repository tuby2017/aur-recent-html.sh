#!/bin/sh
tmpaur=/tmp/aur
aurout=/tmp/xAUR.html
GOP=~/.local/share/golocal/bin
shit=/tmp/noshit
style=fancy-stuff-not2.txt
if [[ ! -f $tmpaur.html ]]; then
# "https://aur.archlinux.org/packages/?O=0&SeB=nd&K=&outdated=&SB=l&SO=d&PP=250&do_Search=Go" > $tmpaur.html
curl -# "https://aur.archlinux.org/packages/?O=0&SeB=nd&K=&outdated=&SB=l&SO=d&PP=100&do_Search=Go" > $tmpaur.html
# "https://aur.archlinux.org/packages/?SB=l&SO=d"
fi

cat $tmpaur.html | $GOP/pup 'td a:not('a[href$="SeB=m"]') text{}'|sed "s/.*/| & |/" >  $tmpaur'1'
cat $tmpaur.html | $GOP/pup 'tr td.wrap text{}'|sed "s/.*/& |/" > $tmpaur'2'

#fix if no info
[[ -z $(cat $tmpaur.html | $GOP/pup 'tr td.wrap:empty') ]] || err=1

if [[ $err = 1 ]]; then
printf '%s\n' `cat $tmpaur.html | $GOP/pup ':parent-of(td.wrap:empty)'|\
	$GOP/pup 'a:not('a[href$="SeB=m"]') text{}'` > $shit 
mapfile -t nnoshit < $shit; for i in "${nnoshit[@]}" 
do	varn=$(grep -n $i $tmpaur'1' |cut -f1 -d:)
	sed -i "$varn i\ n/a |" $tmpaur'2'
done
fi

#combine & html
paste $tmpaur'1' $tmpaur'2' > $tmpaur.md
sed -i "1i | Name | *Description* |\n| -------- | -------- |" $tmpaur.md
markdown2 -x tables $tmpaur.md > $aurout

#js,css
echo 'gg'
sed '15,47!d' $style >> $aurout #js
echo -e "$(cat $style|head -14)\n$(cat $aurout)" > $aurout #css
xdg-open $aurout
#fancy js: 24,58  css: 1,22
#mousepad $aurout
#http://www.colorzilla.com/gradient-editor/
#<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.6.0/clipboard.min.js"></script>
