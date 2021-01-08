#!/bin/bash 

# get process pid from ps and get %CPU, %MEM from top
c="$1 $2 $3 $4 ps -A| grep $5|awk '{ print "
c+='$1'
c+=" }'"
now=`date '+%Y%m%d%H%M%S'`
# shell里面字符串拼接用变量+的方式比较简便，但是也太丑了
# echo $c, $5
getpid=`$1 $2 $3 $4 ps -A| grep $5|awk '{ print $2 }'`
#echo $getpid

if [ -f 'cpu.csv' ];then
   echo 'cpu.csv exists. backup! '
   mv  cpu.csv "bak/cpu$now".csv
else
   echo 'no cpu.csv exits, OK'
fi


if [ -f 'mem.csv' ];then
   echo 'mem.csv exists. backup!'
   #rm -rf mem.csv
   mv  mem.csv "bak/mem$now".csv
else
   echo 'no mem.csv exits, OK'
fi

if [ -f 'gfx.csv' ];then
   echo 'gfx.csv exists. backup!'
   #rm -rf gfx.csv
   mv  gfx.csv "bak/gfx$now".csv
else
   echo 'no gfx.csv exits, OK'
fi


function get_gfxinfo(){
	getgfx=`$1 $2 $3 $4 dumpsys gfxinfo $5|sed -n '6,15p'|awk -F: '{print $2","}'|sed 's/(/,/g;s/)//g;s/ms//g;s/ns//g'`
    now=`date '+%Y-%m-%d %H:%M:%S'`
    les=`echo $getgfx`
   les=${les::${#les}-1}
 #getgfx=`$1 $2 $3 $4 dumpsys gfxinfo $5`
    echo $now, $les
}

# dumpsys meminfo com.localgravity.leap_android| sed -n '8,41p' | sed '3,16d'|sed '4,18d'
# dumpsys meminfo com.localgravity.leap_android| grep -e Realtime  -e 'Native Heap' -e 'Dalvik Heap' -e ViewRootImpl -e TOTAL -e AppContexts| sed '5,6d'|wc -l
function get_meminfo(){
	now=`date '+%Y-%m-%d %H:%M:%S'`
	#getmem=`$1 $2 $3 $4 dumpsys meminfo $5`
	getmem=`$1 $2 $3 $4 dumpsys meminfo $5|grep -e Realtime  -e 'Native Heap' -e 'Dalvik Heap' -e ViewRootImpl -e TOTAL -e AppContexts|sed '5,6d'`
	#time=`echo "$getmem"|wc -l`
	#echo "$getmem"
	time=`echo "$getmem"|grep Realtime|awk -F: '{print $3}'`

	pss=`echo "$getmem"|grep -e 'Native Heap' -e 'Dalvik Heap'|awk '{print $3,$4}'|tr '\n' ' '|sed -e "s/ /,/g"`
	total=`echo "$getmem"|grep TOTAL|awk '{print $2,$3}'|tr '\n' ' '|sed -e "s/ /,/g"`
	views=`echo "$getmem"|grep -e ViewRootImpl -e AppContexts|awk -F: '{print $2}'|awk '{print $1}'|tr '\n' ' '|sed -e "s/ /,/g"`
	views=${views::${#views}-1}
	echo $now, $pss $total $views
}

function get_totalcpu(){
	#user:从系统启动开始累计到当前时刻，处于用户态的运行时间，不包含 nice值为负进程。
    #nice:从系统启动开始累计到当前时刻，nice值为负的进程所占用的CPU时间
    #system 从系统启动开始累计到当前时刻，处于核心态的运行时间
    #idle 从系统启动开始累计到当前时刻，除IO等待时间以外的其它等待时间
    #iowait 从系统启动开始累计到当前时刻，IO等待时间(since 2.5.41)
    #irq 从系统启动开始累计到当前时刻，硬中断时间(since 2.6.0-test4)
    #softirq 从系统启动开始累计到当前时刻，软中断时间(since 2.6.0-test4)
    #stealstolen  这是时间花在其他的操作系统在虚拟环境中运行时（since 2.6.11）
    #guest 这是运行时间guest 用户Linux内核的操作系统的控制下的一个虚拟CPU（since 2.6.24）
   total=`$1 $2 $3 $4 cat /proc/stat|sed -n '1p'|awk '{print $2"+"$3"+"$4"+"$5"+"$6"+"$7"+"$8 }'|bc`
   #total1=`echo "$total"|bc`
   echo $total
}

function get_processcpu(){
  #total0=`$1 $2 $3 $4 cat /proc/$getpid/stat|sed -n '1p'|awk '{print $14"+"$15"+"$16"+"$17 }'`
  total=`$1 $2 $3 $4 cat /proc/$getpid/stat|sed -n '1p'|awk '{print $14"+"$15"+"$16"+"$17 }'|bc`
   #14,utime: 该进程处于用户态的时间，单位jiffies，此处等于166114
   #15,stime: 该进程处于内核态的时间，单位jiffies，此处等于129684
   #16,cutime：当前进程等待子进程的utime
   #17,cstime: 当前进程等待子进程的utime
   echo $total
}

function get_core(){
	core=`$1 $2 $3 $4 cat /proc/cpuinfo|grep processor|wc -l`
	echo $core
}


#get_core $1 $2 $3 $4 $5
echo "time", "process_cpu", "total_cpu", "percent" >> cpu.csv
echo "time", "since", "total_frame", "janky_frame", "janky_frame_percent","50th","90th","95th","99th","missed_vsync", "high_input_latency", "slow_ui_thread" >> gfx.csv
echo "time", "native_heap_pss", "native_heap_dirty","dalvik_heap_pss", "dalvik_heap_dirty", "total_heap_pss", "total_heap_dirty", "views", "app_contexts" >> mem.csv

while true
do
    now=`date '+%Y-%m-%d %H:%M:%S'`
	resetgfx=`$1 $2 $3 $4 dumpsys gfxinfo $5 reset`
	total_before=$(get_totalcpu $1 $2 $3 $4 $5)
	process_before=$(get_processcpu $1 $2 $3 $4 $5)
	sleep 3s
	
    process_after=$(get_processcpu $1 $2 $3 $4 $5)
    total_after=$(get_totalcpu $1 $2 $3 $4 $5)
	#数学运算用 $(())表达式
    temp=$(($process_after - $process_before))
    process=$(($temp * $(get_core $1 $2 $3 $4 $5)))
    total=$(($total_after-$total_before))
    #VAR=$(echo "scale=2; $IMG_WIDTH/$IMG2_WIDTH" | bc)
    rate=$(echo "scale=2; $process*100/$total"|bc)
    echo $now, $process, $total, $rate >> cpu.csv
    echo "CPU: "  $now, $process, $total, $rate
    
    gfx=$(get_gfxinfo $1 $2 $3 $4 $5)
    mem=$(get_meminfo $1 $2 $3 $4 $5)
    echo "GFX: " $gfx
    echo "MEM: " $mem
    echo $gfx >> gfx.csv
    echo $mem >> mem.csv


done
