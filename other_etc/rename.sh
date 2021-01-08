#!/bin/bash
i=0;
function changeName(){
  #new=`echo $1|sed 's/^/abc/g'`
  #new=`echo $1|sed -r 's/abc(.*$)/\1/g'` 
  new=$2.jpg
  #echo $new
  mv $1 $new
}

function travFolder(){ 
  echo "travFolder"
  flist=`ls $1`
  cd $1
  #echo $flist
  for f in $flist
  do
    if test -d $f
    then
      #echo "dir:$f"
      travFolder $f
    else
      #echo "file:$f"     
      #echo $i
      mv $f $i.jpg
      #changeName $f,$i
      let i=i+1
    fi
  done
  cd ../ 
}
dir=/Users/xx/yy
travFolder $dir