#!/bin/bash

#check privileges before starting
if (($EUID != 0)) ; then
    echo "Script running without root privileges"
    echo "If you want to see all connection set sudo before run"
fi

#set variables
programm_name=''
connection='ESTABLISHED'
out_lines=5

#TODO: rework script to input connection states like WAIT/LISTEN/etc
print_usage () {
    echo "Usage: netstat_scr -p {programm_name}"
    echo "Optional args:"
    echo "-l {LineNumbers} : number of output lines. By default output 5 lines"
    echo "-a : output all connection states. By default output ESTABLISHED only connections"
}

#check arguments before start
if [ $# -lt 1 ]
then
echo "No valid options found."
print_usage
exit 1
fi

#parse arguments
while getopts "p:l:a" opt
do
case $opt in
p) programm_name=$OPTARG
;;
a) connection='ALL' 
;;
l) if [[ "$OPTARG" =~ [^0-9]+ ]]; then
  echo "Incorrent line numbers in -l option. Output $out_lines lines only"
   else 
   out_lines=$OPTARG
fi

;;
*) echo "Found invalid option!"
print_usage;;
esac
done

#check programm name for netstat
if [[ $programm_name == '-a' ]] | [[ $programm_name == '-l' ]]; then
    echo "Not found programm name."
    print_usage
    exit 1
fi

#check netstat connections 
if (( $connection == "ALL" )); then
    ip="$(netstat -tunapl)"
else
    ip="$(netstat -tunapl| grep "$connection")"
fi


#check app connections
ip=$(echo "$ip" | awk '/'"$programm_name"/' {print $5}')

#Exit if blank output
if [ -z "$ip" ]; then
     echo "Not found connections for $programm_name"
     exit 1
fi

#convert netstat output to simple IP-addresses
ip=$(echo "$ip" |cut -d: -f1 | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+')

echo $ip

# cut -d: -f1 | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done
