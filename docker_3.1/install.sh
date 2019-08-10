#!/bin/bash
dir_tmp=/home/zule/tmp/git/docker/docker_3.1/install
mkdir $dir_tmp
#将bin中的二进制文件分离出来
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/dragonball_3.1.tar.gz" 2>/dev/null

#解压
cd $dir_tmp
tar -xvf dragonball_3.1.tar.gz

#加载镜像
echo '-----加载镜像-----'
docker load -i $dir_tmp/tar/tomcat01_1.0.tar  
docker load -i $dir_tmp/tar/tomcat02_1.0.tar
docker load -i $dir_tmp/tar/nginx_1.0.tar


mkdir -p /home/zule/tmp/git/docker/docker_3.1/logs

#生成容器并运行
echo '-------启动容器------'
docker run -d -it --name tomcat01 -v /home/zule/tmp/git/docker/docker_3.1/install/code:/tomcat/webapps -v /home/zule/tmp/git/docker/docker_3.1/logs:/tomcat/logs tomcat01:1.0
docker run -d -it --name tomcat02 -v /home/zule/tmp/git/docker/docker_3.1/install/code:/tomcat/webapps -v /home/zule/tmp/git/docker/docker_3.1/logs:/tomcat/logs tomcat02:1.0
docker run -d -ti --name nginx -p 81:81 --link tomcat01:tomcat01_link --link tomcat02:tomcat02_link nginx:1.0


exit 0
