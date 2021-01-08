#!/bin/bash 

# $1是文件名，绝对路径
# $2是起始行号，默认第4行。
# $3是列名  
# $4是要替换的值 

# 把文件从指定行起的指定列替换从某个值
# 首先判断文件是否存在
# 其次判断起始行号是不是数字（没判断是否大于总行数..） wc -l < file
# 找到指定列名的相应列号
# 从指定行开始替换该列
# 写回原文件

if [ -f $1 ];then
    echo $1 'exists!'
else
echo $1 'does not exist！'
   exit 1 
fi

# 判断行号
re='^[0-9]+$'
if ! [[ $2 =~ $re ]] ; then
   echo "error: The second parameter $2 is Not a number" >&2; 
   exit 1
fi


#awk -F, 'NR>=2 {$1=222} 1' $1 > file.tmp && mv file.tmp $1

#找到列名是多少列
column_id=`awk -v RS=',' '/'$3'/{print NR; exit}' $1`

echo $column_id,$4
#awk -v col="$column_id"  -v value="$4" 'BEGIN{FS=OFS=","} {if(NR>=4) {$col=value}}1' $1
awk -v col="$column_id"  -v value="$4" -v row_num="$2" 'BEGIN{FS=OFS=","} {if(NR>=row_num) {$col=value}}1' $1 > file.tmp && mv file.tmp $1