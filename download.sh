#!/usr/bin/env bash
downpath=download
monkpath=monkcoder_dust


function monkcoder()
{
	#创建download文件夹
	if [[ ! -d $downpath ]]; then
	mkdir $downpath
	fi
	#创建monk_coder文件夹
	if [[ ! -d $monkpath ]]; then
	mkdir $monkpath
	fi
	
	default_root_id="$(curl -s https://share.r2ray.com/dust/ | grep -oE "default_root_id[^,]*" | cut -d\' -f2)"
	folders="$(curl -sX POST "https://share.r2ray.com/dust/?rootId=${default_root_id}" | grep -oP "name.*?\.folder" | cut -d, -f1 | cut -d\" -f3 | grep -v "backup\|rewrite\|member" | tr "\n" " ")"
	test -z "$folders" && return 0 || rm -rf $downpath/*
	for folder in $folders; do
	    jsnames="$(curl -sX POST "https://share.r2ray.com/dust/${folder}/?rootId=${default_root_id}" | grep -oP "name.*?\.js\"" | grep -oE "[^\"]*\.js\"" | cut -d\" -f1 | tr "\n" " ")"
	    for jsname in $jsnames; do 
	        curl -s --remote-name "https://share.r2ray.com/dust/${folder}/${jsname}" 
             mv $jsname $downpath/
             #获取下载文件大小，空文件内容是null大小是4
	        FileSize=$(stat --format=%s $downpath/$jsname)
	        #echo -e "FileSize:"$FileSize
             if [[ $FileSize != "4" ]]; then
               #连接错误后会把错误提示页面下载成Js文件，捕获错误页面内容并排除
               grep "What happened?" $downpath/$jsname >> /dev/null
		     if [ $? -ne 0 ]; then
		        #echo -e "已下载["$folder"]目录中的["$jsname"]文件."
		        #sleep 1 #等待1s下一个文件
		        #判断是否新增脚本
			   if [ ! -f "$monkpath/$jsname" ];then
			     cp $downpath/$jsname $monkpath/
				echo -e "新增加文件"$jsname
			   else
			     md5download=$(md5sum $downpath/$jsname|cut -d ' ' -f1)
			     md5monkcoder=$(md5sum $monkpath/$jsname|cut -d ' ' -f1)
			     #echo -e "md5download_"$jsname":"$md5download
			     #echo -e "md5monkcode_"$jsname":"$md5monkcoder
			     #判断已存在的脚本是否更新了内容
		          if [[ $md5download != $md5monkcoder ]]; then
		             yes|cp -rf $downpath/$jsname $monkpath/
		             echo -e "更新文件"$jsname
		          fi
			   fi
		     else
		       echo -e $jsname"下载地址错误,页面404！！！"
		     fi 
             else
                echo -e $jsname"文件下载为null,不进行文件替换！！！"
             fi
	    done
	done
	#echo -e "全部下载完成, 脚本下载目录:"$downpath", 脚本更新目录:"$monkpath
}

function main()
{
    monkcoder
}

main
