 # Docker容器化
 
 ![enter description here](https://github.com/grandhappy/docker/blob/master/images/0.png)

以nginx+tomcat集群为例进行说明，如何搭建服务，常规的方式是下载、安装、配置、部署代码。如何简化这些操作呢，这次我们提供了利用docker容器化这些服务，从而降低软件迁移所带来的困扰，减少了重复安装、配置、部署等。

# *千里之行，始于足下*
让我们制作服务的docker镜像
### 1.制作镜像
#### 1.1制作tomcat01镜像
- 创建相应目录，下载jdk和tomcat

![enter description here](https://github.com/grandhappy/docker/blob/master/images/1.png)
> <i class="far fa-folder"></i>code目录: 用于存放我们的服务源代码，源程序是index.html。
> <i class="far fa-folder"></i>shell目录: 用于存放我们的sh脚本，启动tomcat服务。
> <i class="far fa-folder"></i>software目录: 用于存放运行服务的软件，例如jdk和tomcat。
> <i class="far fa-file"></i>Dockerfile文件：用于制作docker镜像的文件，也是我们核心文件。
- 编写Dockerfile内容
```
#继承镜像
FROM ubuntu:14.04
#作者
MAINTAINER docker_user (zule@qq.com)

#===========tomcat=============
#设置环境变量,所有操作非交互式
ENV DEBIAN_FRONTEND noninteractive
#修改时区
RUN echo "Asia/Shanghai" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
#安装跟tomcat用户认证相关软件
RUN apt-get update
RUN apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#配置tomcat环境变量
ENV JAVA_HOME=/jdk
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV CATALINA_HOME /tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/lib:$CATALINA_HOME/bin
#复制tomcat和jdk到镜像
ADD software/tomcat8-01 /tomcat
ADD software/jdk1.8 /jdk
ADD code/index.html /tomcat/webapps
#ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD shell/run.sh /run.sh
RUN chmod +x /*.sh
RUN chmod +x /tomcat/bin/*.sh
#开放端口
EXPOSE 8080


#设置自启动命令
CMD ["/run.sh"]
```
- 制作镜像：进入tomcat1_ubuntu目录下，执行docker builder命令
>docker builder –t tomcat01:1.0 .
 
#### 1.2制作tomcat02镜像
重复章节1.1
#### 1.3制作nginx镜像
- 创建相应目录，下载nginx安装包

![enter description here](https://github.com/grandhappy/docker/blob/master/images/2.png)
- 编写Dockerfile内容
```
#继承镜像
FROM ubuntu:14.04
#作者
MAINTAINER docker_user (zule@qq.com)

#===========nginx=============
#复制nginx到镜像
ADD ./nginx-1.13.0 /opt/nginx-1.13.0
RUN apt-get update
RUN apt-get install build-essential -y \
    && apt-get install libtool -y \
    && apt-get update \
    && apt-get install libpcre3 libpcre3-dev -y \
    && apt-get install zlib1g-dev -y
RUN cd /opt/nginx-1.13.0 \
    && ./configure --prefix=/opt/nginx \
    && make && make install \
    #修改端口
    && sed -i 's/listen       80;/listen       81;/g' /opt/nginx/conf/nginx.conf \
    #删除nginx安装包
    && rm -rf /opt/nginx-1.13.0
#开放端口
EXPOSE 81


ADD run.sh /opt/run.sh
RUN chmod 755  /opt/run.sh
#设置自启动命令
CMD ["/opt/run.sh"]
```
- 修改nginx配置
> vim nginx/conf/nginx.conf
 
![enter description here](https://github.com/grandhappy/docker/blob/master/images/3.png)
- 制作镜像：进入nginx_ubuntu目录下，执行docker builder命令
>docker builder –t nginx:1.0 .
 
### 创建容器
>docker run –d –it --name tomcat01 tomcat01:1.0  
>docker run –d –it --name tomcat02 tomcat02:1.0  
>docker run -d -ti --name nginx -p 81:81 --link tomcat01:tomcat01_link --link tomcat02:tomcat02_link nginx:1.0  
### 测试
打开浏览器进行测试

![enter description here](https://github.com/grandhappy/docker/blob/master/images/4.png)

![enter description here](https://github.com/grandhappy/docker/blob/master/images/5.png)
### 疑问
#### 1.Dockerfile CMD指令不执行？
docker run –t –it --name tomcat01 tomcat01:1.0 /bin/bash，会覆盖cmd，应该去掉/bin/bash
#### 2.容器互通互联
docker run –t –id –name nginx –link tomcat01:tomcat01_link，使用—link，在容器内建立会建立hosts
![enter description here](https://github.com/grandhappy/docker/blob/master/images/6.png

# *百尺竿头更进一步*
从实际出发让我们对上一节成果继续优化
如果客户想要的产品是苹果，有2个方案，一个是提供种子、水、肥料原材料，然后去客户的田园种苹果；另一个是在自己的田园播种，待开花结果之后，把苹果卖给客户。客户最关系的是能够吃到苹果，而不是怎么种苹果树。
### 1.bin包
我们可以把构建镜像、创建容器、配置服务、启动服务等一系列的操作放到黑盒里，并再黑盒子设计一个启动按钮。当客户拿到这个黑盒子时，仅仅需要点击启动按钮，我们的产品就会最终效果呈现出来。

+ 构建bin包

> cd docker_1.0  
> tar -cvzf dragonBall.tar.gz nginx_ubuntu1 tomcat1_ubuntu   tomcat2_ubuntu
> vim install.sh  
> cat install.sh dragonball_1.0.tar.gz > dragonball_1.0.bin  
> chmod +x dragonball_1.0.bin  
```
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
```
成功生成了我们的黑盒，dragonball_1.0.bin。
+ 启动
客户拿到黑盒，如何启动黑盒？只需要执行下边命令即可。
> ./dragonball_1.0.bin  
+ 测试
打开浏览器进行测试

![enter description here](https://github.com/grandhappy/docker/blob/master/images/4.png)

![enter description here](https://github.com/grandhappy/docker/blob/master/images/5.png)

## *只要工夫深,铁杵磨成针*
在上面章节内容，不知道大家在实操过程中有没有发现比较严重的问题。比如客户拿到黑盒执行的时间非常长；源程序和服务能不能分离等等。下面我们针对这两个鸡肋问题进行优化升级。
### 1.缩短黑盒执行时间
黑盒里我们都干了什么？仔细研究一下install.sh我们就会发现，无非就是一下几个动作。
 　　1. 构建镜像 
 　　2. 创建容器 
 　　3. 启动服务
 在bin包执行的过程中我们会发现，第一步的执行时间最长，因为构建镜像的过程中，实际去docker的远程仓库下载各种软件包。第二步、三步，执行比较快，因为都是在本地完成。依据“木桶原则”，只需优化第一步就会立竿见影！如何解决这个问题呢？答案有两个，其一，搭建一套本地仓库，依赖从本地仓库下载；其二，提前构建好我们的镜像。显然第二种更来自实在。
 - 导出镜像tar文件
 > docker images  
 
![enter description here](https://github.com/grandhappy/docker/blob/master/images/7.png)
 >docker save -o /home/zule/tmp/git/docker/docker_3.0/tomcat01_1.0.tar tomcat01:1.0  
 >docker save -o /home/zule/tmp/git/docker/docker_3.0/tomcat02_1.0.tar tomcat02:1.0
 >docker save -o /home/zule/tmp/git/docker/docker_3.0/nginx_1.0.tar nginx:1.0
 
![enter description here](https://github.com/grandhappy/docker/blob/master/images/8.png)
 - 构建bin包
 >tar -cvzf dragonball_2.0.tar.gz nginx_1.0.tar  tomcat01_1.0.tar  tomcat02_1.0.tar
 >vim install.sh
```
#!/bin/bash  
dir_tmp=/home/zule/tmp/git/docker/docker_3.0/install  
mkdir $dir_tmp  
#将bin中的二进制文件分离出来  
sed -n -e '1,/^exit 0$/!p' $0 > "${dir_tmp}/dragonball_2.0.tar.gz" 2>/dev/null  

#解压  
cd $dir_tmp  
tar -xvf dragonball_2.0.tar.gz  
  
#加载镜像  
docker load -i tomcat01_1.0.tar  
docker load -i tomcat02_1.0.tar  
docker load -i nginx_1.0.tar  

#生成容器并运行  
docker run -d -it --name tomcat01 tomcat01:1.0  
docker run -d -it --name tomcat02 tomcat02:1.0  
docker run -d -ti --name nginx -p 81:81 --link tomcat01:tomcat01_link --link tomcat02:tomcat02_link nginx:1.0  

exit 0  
```

>cat install.sh dragonball_2.0.tar.gz > dragonball_2.0.bin
- 执行bin包
> docker stop $(docker ps -qa)
> docker rm $(docker ps -qa)
> docker rmi $(docker images -q)
> sh ./dragonball_2.0.bin

![enter description here](https://github.com/grandhappy/docker/blob/master/images/9.png)
 - 测试
 打开浏览器进行测试

![enter description here](https://github.com/grandhappy/docker/blob/master/images/4.png)

![enter description here](https://github.com/grandhappy/docker/blob/master/images/5.png)
