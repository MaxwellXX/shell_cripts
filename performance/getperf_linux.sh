#!/bin/bash 

#get current CPU%, MEM% and network io and save to txt file
if [ -f 'perf.txt' ];then
   echo 'perf.txt exists. OK!'
else
   echo 'perf.txt not exist. creating it'
   touch perf.txt
fi

in_old=`cat /proc/net/dev | grep -w eth0 | sed -e "s/\(.*\)\:\(.*\)/\2/g" | awk '{ print $1 }' `
out_old=`cat /proc/net/dev | grep -w eth0 | sed -e "s/\(.*\)\:\(.*\)/\2/g" | awk '{ print $9 }' `

#garbage code
#pids =`ps -aux|grep www-data|grep uw|grep nightfury|awk '{print $2,$10}'|sort -t ' ' -k 2 -r|sed -n -e '1p'|awk '{print $1}'
#arr=( $(command) ) assign output to array
#pids =( $(ps -aux|grep www-data|grep uw|grep nightfury|awk '{print $2}'))
#pids=`ps -aux|grep www-data|grep uw|grep nightfury|awk -vORS='\\|' '{print $2}'`

#find out nightFury running pid, convert all pids from line to string and separated by /|
#option to grep two strings: grep 'word1\|word2' input
pids_old=$(ps -aux|grep www-data|grep uw|grep nightfury|awk -vORS='\\|' '{print $2}')
#remove the last /| as awk command doesn't like it ^_^
pids_new=${pids_old::${#pids_old}-2}
#echo "$pids_new"

while true
do
   #get toppest pid, and extract CPU%, MEM%
   app=`top -u www-data -b -n 1|grep "$pids_new" |sed -n -e '1p'|awk '{print $1","$9","$10}'`
   now=`date '+%Y-%m-%d %H:%M:%S'` 
   sleep 3s #can parameterize the inteval

   in=`cat /proc/net/dev | grep -w eth0 | sed -e "s/\(.*\)\:\(.*\)/\2/g" | awk '{ print $1 }' `
   out=`cat /proc/net/dev | grep -w eth0 | sed -e "s/\(.*\)\:\(.*\)/\2/g" | awk '{ print $9 }'`

   sub_in=$(( ($in-$in_old)/3 ))
   sub_out=$(( ($out-$out_old)/3))

   in=$((${sub_in}/1024)) # eth0 Recv kb/s
   out=$((${sub_out}/1024)) # eth0 Sent kb/s
   
   echo "$now, $app, $in, $out" >> perf.txt
   echo "$now, $app, $in, $out" 
done
