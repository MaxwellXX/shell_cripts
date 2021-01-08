#!/bin/bash 
#if [ -f 'sys_data.txt' ];then
#   rm -f sys_data.txt
#else
#   touch sys_data.txt
#fi

#this script is used to monitor if some key backend apis are working
#we get issues like users were not able to login system or macros cannot be used before
#the reasons are many, e.g. system is down because of poor performance or server is rebooted 
#but some services needs to be started manually and we forget to
#this script is to avoid such problems later, it is daily ran and will send result to slack channel after finishes
touch sys_data.txt

now=`date '+%Y-%m-%d %H:%M:%S.%3N'` 
echo "\n $now, start to work.... ">>sys_data.txt
#echo "$now, see if we can login to XXX..." >>sys_data.txt

status=$(curl -w "%{http_code}\\n"  -H "Content-Type:application/json" --data '{"username":"xxx","password":"xxx"}' https://xx.xxx.xxx.com.cn/login -s -o /dev/null)

now=`date '+%Y-%m-%d %H:%M:%S.%3N'`

if [ $status == 200 ];then
	echo "$now, xxx login to XXX successfully, XXX is not down! " >>sys_data.txt
else 
	echo "$now, unable to login XXX, status_code: $status, please look into it ASAP!" >>sys_data.txt
fi

#echo "$now, see if we can login to YYY...">>sys_data.txt

status=$(curl -w "%{http_code}\\n"  -H "Content-Type:application/json" --data '{"username":"xxx","password":"silver"}' https://yy.yyy.yyy.com.cn/login -s -o /dev/null)
#echo "status: $status"
now=`date '+%Y-%m-%d %H:%M:%S.%3N'` 

if [ $status == 200 ];then
	echo "$now, xxx login to YYY successfully, YYY is not down! " >>sys_data.txt
else 
	echo "$now, unable to login YYY, status_code: $status, please look into it ASAP!" >>sys_data.txt
fi

#echo "$now, see if we can login to ZZZ Tool..." >>sys_data.txt

status=$(curl -w "%{http_code}\\n"  -H "Content-Type:application/json" --data '{"username":"yyy","password":"yyyy"}' https://yy.yyy.yyy.com.cn/yyy/login -s -o /dev/null)

now=`date '+%Y-%m-%d %H:%M:%S.%3N'` 

if [ $status == 200 ];then
	echo "$now, zzz login to ZZZ Tool successfully, ZZZ Tool is not down! " >>sys_data.txt
else 
	echo "$now, unable to login ZZZ Tool, status_code: $status, please look into it ASAP!">>sys_data.txt
fi

file_name=`date '+%Y-%m-%d'`
#save the curl result to local file and grep contents in the file to see if api is working as expected
curl 'http://aaa.aaa.a/bbb/bbb?format=string&bb=&bb=QQQ'  -s -o /root/xxx/log/a_check_$file_name.txt
ok=$(grep -c "STR" "/root/xxx/log/a_check_$file_name.txt")
now=`date '+%Y-%m-%d %H:%M:%S.%3N'` 
#echo "$ok"
if [ "$ok"  -gt 0 ];then
	echo "$now, get response from aaa api, aaa is not down! " >>sys_data.txt
else 
	echo "$now, aaa has problem, please look into it ASAP!">>sys_data.txt
fi

#echo "$now, see if autosegment is working..." >>sys_data.txt

curl 'http://bbb/ccc/'  -s -o /root/xxx/log/b_check_$file_name.txt
ok=$(grep -c "VCL" "/root/xxx/log/b_check_$file_name.txt")
now=`date '+%Y-%m-%d %H:%M:%S.%3N'` 
#echo "$ok"
if [ "$ok"  -gt 0 ];then
	echo "$now, get response from bbb api, bbb is not down! " >>sys_data.txt
else 
	echo "$now, bbb has problem, please look into it ASAP!">>sys_data.txt
fi

#while IFS= read -r line; do
#    echo "Text read from file: $line"
#done < sys_data.txt

text=$(tail -6 sys_data.txt|sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g' )
#echo "text: $text"

datas='{"message": "Hooray!","text": "'
datas+="$text"
datas+='","username": "SYS_STATUS"}'
echo "datas： $datas"
curl --location --request POST 'https://hooks.slack.com/services/dddddd/eee/fffffff'  --header 'Content-Type: application/json'  --data "$datas"


