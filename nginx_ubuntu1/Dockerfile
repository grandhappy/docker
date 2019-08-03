#继承镜像
FROM ubuntu:14.04
#作者
MAINTAINER docker_user (zule@qq.com)

#===============ssh===============
#安装SSH
RUN apt-get update
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh
#安装vim
RUN apt-get remove -y vim-common
RUN apt-get install -y vim-gtk

#取消PAM限制
RUN sed -ri 's/session	required	pam_loginuid.so/#session	required	pam_loginuid.so/g' /etc/pam.d/sshd
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
# 设置root ssh远程登录密码为123456
RUN echo "root:123456" | chpasswd
#复制配置文件到相应位置，并赋予脚本可执行权限
#ADD authorized_keys /root/.ssh/authorized_keys

#开放端口
EXPOSE 22

#===========nginx=============
#复制nginx到镜像
ADD ./nginx-1.13.0 /opt/nginx-1.13.0

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

