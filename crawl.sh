#!/bin/bash
#november spider project, not for porn **obviously**

#opening+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

fileCount=0
url="https://yande.re/post"

#declaring paths
cd "$(dirname "$0")"
sysDir="$(pwd)"
cd ~
dir="$(pwd)"
configDir=$sysDir"/.config/"
configFile=$configDir"config.json"
tagList=$configDir"yande_tagList.txt"
outputDir=$sysDir outputDir+="/.output/"
outputFile=$outputDir"out.txt"
linkList=$outputDir"links.txt"
startTime=$(date +%s)

function init {

#numbers
isAlive=0
min=1
max=75
pageNum=0
pg=1

#extra
crawlSet='n'
run=1

}

init

#functions+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function elapsedTime () {

    elapsed=$(($2-$1))

    if (($elapsed < 60))
        then
            echo "
Process took $elapsed second(s).
            "
    elif (($elapsed < 3600)) && (($elapsed >= 60))
        then
            echo "
Process took $(($elapsed/60)) minute(s) and $(($elapsed%60)) second(s).
            "
    elif (($elapsed >= 3600))
        then
        echo "
Process took $(($elapsed/3600)) hour(s), $((($elapsed/60)-(60*($elapsed/3600)))) minute(s), and $((($elapsed-3600)%60)) second(s).
            "
    else
        echo "
A broken clock is right twice a day.
";

    fi

}

function cleanUp {
echo "Downloaded $fileCount files.
"
echo "Clearing stored data...
"

    cat /dev/null > $outputFile
    cat /dev/null > $linkList

    echo "Quitting!";
    run=0
    exit
}

function pageEnum {
        enumStart=$(date +%s)
        local count=0
        local exists=0
        local bounds=0
        local dif=0
        local stor=0
        local enumRun=1
        echo "Searching '$url' for '$tag1'.
Enumerating pages... Please wait."

#large ass binary search algorithm
        while ((enumRun != 0))
            do
                if curl -s -X GET $url -d "page=$pg&tags=$tag1" | grep -q "Nobody here but us chickens!"
                    then
                    exists=0

                    if (($pg <= 1))
                        then

                            enumRun=0
                            break
                    fi

                else
                    exists=1

                fi

                if ((exists == 1))
                    then

                    if (($pg < $bounds))
                        then
                            dif=$(($bounds-$pg))

                            if (($dif > 16))
                                then
                                    if ((($bounds-$stor) <= 16))
                                        then
                                            dif=$(($bounds-$stor))
                                            pg=$stor
                                    fi
                            fi

                            if (($dif <= 16))
                                then

                                for ((n=$pg; n<=$bounds; n++))
                                    do
                                        count=$((count+1))
                                        #echo $pg $count $dif $stor $bounds $n "22"

                                        if curl -s -X GET $url -d "page=$n&tags=$tag1" | grep -q "Nobody here but us chickens!"
                                            then
                                                pageNum=$(($pg-1+($n-$pg)))
                                                enumRun=0
                                                break

                                        fi

                                    done

                            else

                                dif=$(($dif/2))
                                if (($pg > $stor))
                                    then
                                        stor=$pg
                                fi
                                pg=$((pg+dif))

                                #echo $pg $max $stor $dif "1"

                            fi
                    else
                        pg=$((pg*2))
                        #echo $pg $max "09"
                    fi

                elif ((exists == 0))
                    then
                        bounds=$pg
                         if ((pg != 3))
                            then
                            pg=$((pg-(pg/4)))
                            else
                                pg=2
                        fi

                        #echo $pg $max $bounds "01"
                fi

        done
#End of binary search algorithm

        enumFinish=$(date +%s)
        echo "
$pageNum page(s) found!";
        elapsedTime $enumStart $enumFinish


}

function pingIt {
    if nc -z $url 22 2>/dev/null;
    then isAlive=1
    else
        isAlive=0
    fi
}

function makeDir() {

if (($1 == 0))
    then
        if mkdir "$path$tag1" >/dev/null 2>&1
            then
                echo "Created directory: $path$tag1."
        else
            echo "Folder exists. The program will utilize the existing folder."
        fi
elif (($1 == 1))
    then
        if mkdir "$2" >/dev/null 2>&1
            then
                echo "Created directory: $path$tag1." >/dev/null 2>&1
        else
            echo "Folder exists. The program will utilize the existing folder." >/dev/null 2>&1
        fi

else
    echo "
    Nothing... happened....
    ";

fi

}

function query {
readable=1
makeDir 0
queryStart=$(date +%s)

echo "Downloading files..."

#page iterator
    for ((i=$min; i<=$pageNum; i++))
    do
    echo "Page $i of $pageNum.
Query/Tag: $tag1
===================================="
    #getting the links
    curl -s -X GET $url -d "page=$i&tags=$tag1" | grep -oi -P '(?<="directlink largeimg" href=).*?(?<=span)' > $outputFile
    #grep -oi '.*>'  "$outputDir/out.txt" > "$outputDir/out.txt"
    awk -F\" '{print $2}' $outputFile > $linkList
    curl -s -X GET $url -d "page=$i&tags=$tag1" | grep -oi -P '(?<="directlink largeimg" href=).*?(?<=span)' > $outputFile


    #now to download

    read lines <<< $(wc -l $linkList | tr ' ' '\n' | head -3)
    local count=1

    while read line;
    do

    #read fileName <<< $(grep -oi 'yande.re.*' $line | tr ' ' '%' | tr ' ' '&')

    echo "In progress... (Page: $i/$pageNum | File: $count/$lines (Approx Total: $(($pageNum-$min*40)) files.) $(((($pageNum-$i)*40)-$count))  approx. remaining.)"

    #wget -q -P "$path$tag1/page_$i" $line --progress=bar:force:noscroll --show-progress -nc -T60

    wget -q -P "$path$tag1" $line --progress=bar:force:noscroll --show-progress -nc -T60

    fileCount=$((fileCount+1))
    count=$((count+1))


    done < $linkList


    echo "Page $i of $pageNum downloaded.
===========================================
    ";

    done

    queryEnd=$(date +%s)
    elapsedTime $queryStart $queryEnd

}

function specify {

read -p "Please specify a file path. Home directory ($dir/crawler/download/) will be selected if left blank. " path

    if [[ $path == null ]]
        then path="$dir/crawler/download/"
    fi

read -p "Would you like to scan multiple pages? (y/n) " crawlDelim
if [ $crawlDelim == 'y' ] || [ $crawlDelim == 'yes' ]
    then
        read -p "Would you like to crawl all avaliable pages? (y/n)" crawlSet

fi


if [ "${crawlDelim,,}" == 'y' ] && [ "${crawlSet,,}" == 'y' ];
    then crawl=1

elif [ "${crawlSet,,}" == 'n' ] && [ "${crawlDelim,,}" != 'n' ];
    then crawl=3

else
    crawl=0
fi

if [[ $crawl != 1 ]] && [[ $crawl != 3 ]];
    then read -p "Enter a page number. (if any) " pageSelect
        max=$pageSelect
        pageNum=$pageSelect
        min=$pageSelect

elif [[ $crawl == 1 ]]
    then
        if (($pageNum > $max))
            then
                pageNum=$max
        fi
        echo "
The maximum amount of pages the program will auto scan is $max.
Please access the page selection menu for more page download options.
(This can be achieved by answering y, and then n to the first questions, after path specification.)
"

elif [ $crawl == 3 ];
    then
    read -p "Set the page you desire to start at." pageSelect
    read -p "Set the destination page." pageMax

    if (($pageMax > pageNum))
        then
        pageMax=$pageNum
    fi

    min=$pageSelect
    pageNum=$pageMax

fi

}

#if [[ $@ ]]
#    then
#        if  grep -o '-c' <<< $@ || grep -o '--configure' <<< $@
#            then
#            $1=$(grep -o '-c' <<< $@)
#            $1=$(grep -o '--configure' <<< $@)
#config edit mode+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                echo "Entering configuration mode...";
#                exit
#
#            else
#                echo "'$1' is not a valid argument!";
#                exit
#        fi
#
#    else
#main content+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


            #read -p "Select a server from the list of supported servers below...." server

            pingIt

            if [ $isAlive == 0 ];
                then
                echo "▄▄▄▄·▄▄▄▄·      ▄▄·▄▄▄  ▄▄▄·▄▄▌ ▐ ▄▄▄▌ ▄▄▄ ▄▄▄
▐█ ▀█▐█ ▀█▪    ▐█ ▌▀▄ █▐█ ▀███· █▌▐██• ▀▄.▀▀▄ █·
▐█▀▀█▐█▀▀█▄    ██ ▄▐▀▀▄▄█▀▀███▪▐█▐▐██▪ ▐▀▀▪▐▀▀▄
██▄▪▐██▄▪▐█    ▐███▐█•█▐█ ▪▐▐█▌██▐█▐█▌▐▐█▄▄▐█•█▌
·▀▀▀▀·▀▀▀▀     ·▀▀▀.▀  ▀▀  ▀ ▀▀▀▀ ▀.▀▀▀ ▀▀▀.▀  ▀"
                echo "Author: CALITHOS4136"
                echo "====================================================="
                echo "Connection successfully established with: https://yande.re!"
            else
                echo "The server you are trying to access seems to be unreachable. Please try again."
                exit
            fi

            while (($run != 0))
            do


            #read -p "Please enter the url you'd like to download images from:" url

            read -p "Enter a tag. " tag1

            pageEnum

            if (( $pageNum > 0 ))
                then
                    specify
                    query
                else
                    echo "There's nothing to download!"
            fi

            read -p "Download something else? (y/n) " contin

            if [ "${contin,,}" == 'y' ] || [ "${contin,,}" == 'yes' ]
                then
                    init
                    continue

                else
                terminateTime=$(date +%s)
                    elapsedTime $startTime $terminateTime
                    cleanUp
            fi

        done
#fi
