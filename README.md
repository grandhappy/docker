 # Docker容器化
 
 ![enter description here](https://github.com/grandhappy/docker/blob/master/images/0.png)

以nginx+tomcat集群为例进行说明，如何搭建服务，常规的方式是下载、安装、配置、部署代码。如何简化这些操作呢，这次我们提供了利用docker容器化这些服务，从而降低软件迁移所带来的困扰，减少了重复安装、配置、部署等。

## *千里之行，始于足下*
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
>docker run –d –it --name tomcat01 tomcat02:1.0  
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
![enter description here](https://github.com/grandhappy/docker/blob/master/images/6.png)
