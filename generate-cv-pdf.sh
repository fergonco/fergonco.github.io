cat cv.txt | iconv -f utf8 -t iso-8859-1 | enscript -b '' -p /tmp/a.ps
ps2pdf /tmp/a.ps cv.pdf
