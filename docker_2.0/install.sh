#!/bin/bash
dir_tmp=/home/zule/dockerfiles/bin/install
mkdir $dir_tmp
#将bin中的二进制文件分离出来
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/dragonball_1.0.tar.gz" 2>/dev/null

#解压
cd $dir_tmp
tar -xvf dragonball_1.0.tar.gz

#构建镜像
cd $dir_tmp/tomcat1_ubuntu/
pwd
docker build -t tomcat01:1.0 .
cd $dir_tmp/tomcat2_ubuntu/
docker build -t tomcat02:1.0 .
cd $dir_tmp/nginx_ubuntu/
docker build -t nginx:1.0 .

#生成容器并运行
docker run -d -it --name tomcat01 tomcat01:1.0
docker run -d -it --name tomcat02 tomcat02:1.0
docker run -d -ti --name nginx -p 81:81 --link tomcat01:tomcat01_link --link tomcat02:tomcat02_link nginx:1.0

exit 0
