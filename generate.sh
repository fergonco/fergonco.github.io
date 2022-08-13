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
