if [ $# -lt 1 ]
then
    echo 'expected parameter'
fi

echo "Got $1"

if [ "$1" == "text" ] || [ "$1" == "all" ]
then
    echo "Generating text cv"
    pandoc cv.md -o cv.txt -t plain
fi

if [ "$1" == "pdf" ] || [ "$1" == "all" ]
then
    echo "Generating pdf cv"
    pandoc cv.md -o cv.pdf
fi

if [ "$1" == "pdf-linkedin" ] || [ "$1" == "all" ]
then
    echo "Generating pdf linked in cv"
    sed '/Telephone/d' cv.md | sed '/Address/d' > /tmp/cv.md
    pandoc /tmp/cv.md -o cv-linkedin.pdf
fi
