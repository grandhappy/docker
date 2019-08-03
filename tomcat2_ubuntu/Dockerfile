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

