#-------------
#  psnil 
#  2013-3-26
#  pm 20:00
#  文件目录组织有点差阿,需要锻炼
#-------------
#!/bin/bash  
#set -x #调试
declare -i flag=0            #判断此行是文件名字还是漫画url
declare -i i=2
declare -i count=0
declare -i exist=0
declare -a src
declare -i test=1
filename=`date +"%Y_%m_%d"`.zip

# 判断smtp是否启动
source test.sh              #用来判断各项服务是否开启了
smtp
net

echo "begin collect..."

pwd=`pwd`                   #这些可以自己设置路径
tmp=/tmp/$$                 #下载urlfile所指路径的网页，下载上面的图片链接
des=pic/                    #下载后存放图片的文件夹
urlfile=baozou_url          #存放要下载的暴走图片所在网站的url   
data=baozou_data            #存放已经下载过的暴走 图片的url

#取得url列表
for url in `cat $urlfile`
do
src[$count]=$url
#echo ${src[$count]}
((count++))
done
((count--)) 

if [ ! -f $data ];then
    echo "there is no baozou_data,please touch "
fi

cd $des

while [[ $count -ge 0  ]] 
do
    source=${src[$count]}
#    echo $source
    ((count--))
#done
#if [ $test -eq 0 ];then 

#get the source file
	lynx -source $source > $tmp  

#get the  comic url 
	for line in `cat $tmp  | egrep "'pic'" |  awk -F\' '{print $4}'`
	do
	comic=$line
	#测试文件是否存在,若不存在，写入保存文件，供以后比对
	exist=`grep $comic $data | wc -l`
	if [ $exist -eq 0 ];then
	    echo $comic >> $data
	    wget $comic   
	fi
	done
done
rm $tmp
	    #打包发送操作
	    exist=`ls  | wc -l`
	    if [ $exist -ne 0 ];then
        echo "find comic !"

        #仅发送50张否则过大（不能超过50M）,so 删除多与图片
            if [ $exist -gt 50 ];then
                rm ` ls | tail -$(($exist-50)) `
            fi

        #里采用convert合成图片为一张pdf来发送
	    convert * +compress baozou.pdf
	    zip -m $filename baozou.pdf
        echo -n  "mutt now ... wait... the size of file is :"
        echo `du -h $filename`
	    echo "kindle" | mutt -s "baozou" XXXXXXXXXX@free.kindle.com -a $filename  
        echo "mutt ok!"
	    rm *
	    cd $pwd
        else
            echo "there is no comic !"
   	    fi
exit
