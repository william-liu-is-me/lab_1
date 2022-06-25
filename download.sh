#!/bin/zsh

export DOCDIR='/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/docs'
export LOGDIR='/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/logs'

filenametime1=$(date +"%m%d%Y%H%M%S")

exec > >(tee ${LOGDIR}/script_${filenametime1}.log)
exec 2> >(tee ${LOGDIR}/script_${filenametime1}.log >&2)
#what is the meaning of this one? exec tee nad >&2 ???

echo "Downloading data from Climate Canada..."
for i in {2020..2022}
do
    wget --content-disposition "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=48549&Year=${i}&Month=2&Day=14&timeframe=1&submit= Download+Data"
    #curl "https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=csv&stationID=48549&Year=${i}&Month=2&Day=14&timeframe=1&submit= Download+Data" -O
    done

RC1=$?
if [ $RC1 -ne 0 ]; then
    echo "Download failed. Exiting..."
    exit 1
fi

echo "\nSUCCESSFULLY DOWNLOADED DATA FROM CLIMATE CANADA!"

echo "STARTING PYTHON SCRIPT TO PROCESS DATA... ON ${hostname}..."

#cd "/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/script"

python "/Users/yangliu/Desktop/Data Engineering/Linux/learning/climate_folder/script/concat.py"

RC1=$?
if [ $RC1 -ne 0 ]; then
    echo "Python script failed. Exiting..."
    echo "ERROR: ${RC1}"
    echo "ERROR: REFER TO LOG FILE: ${LOGDIR}/script_${filenametime1}.log"
    exit 1
fi

echo "SUCCESSFULLY PROCESSED DATA!"

echo "REMOVING DOWNLOADED FILES..."


echo "END RUNNING PROCESS"

echo "PROCESS END AT $(date +"%m%d%Y%H%M%S")"


: '
if [ -f all_years.csv ]; then
    echo "all_years.csv exists"
else
    echo "all_years.csv does not exist"
    exit 1
fi 
'