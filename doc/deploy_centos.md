

# 依赖


## 系统依赖安装

    yum -y install epel-release
    yum -y update
    yum -y groupinstall Base "Development Tools" "Perl Support"
    yum install -y telnet aspell bzip2 collectd-postgresql collectd-rrdtool collectd.x86_64 curl db4 expat.x86_64 gcc gcc-c++ gd gdbm git gmp ImageMagick java-1.8.0-openjdk java-1.8.0-openjdk-devel libcollection libedit libffi libicu libpcap libtidy libwebp libxml2 libXpm libxslt libyaml.x86_64 mailcap ncurses ncurses npm openssl openssl-devel pcre perl perl-Business-ISBN perl-Business-ISBN-Data perl-Collectd perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Config-General perl-Data-Dumper perl-Digest perl-Digest-MD5 perl-Encode-Locale perl-ExtUtils-Embed perl-ExtUtils-MakeMaker perl-GD perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Date perl-HTTP-Message perl-IO-Compress perl-IO-HTML perl-JSON perl-LWP-MediaTypes perl-Regexp-Common perl-Thread-Queue perl-TimeDate perl-URI python readline recode redis rrdtool rrdtool-perl sqlite systemtap-sdt.x86_64 tk xz zlib rng-tools python36-psycopg2.x86_64 python34-psycopg2.x86_64 python-psycopg2.x86_64 python-pillow python34-pip screen unixODBC unixODBC-devel pkgconfig libSM libSM-devel ncurses-devel libyaml-devel expat-devel libxml2-devel pam-devel pcre-devel gd-devel bzip2-devel zlib-devel libicu-devel libwebp-devel gmp-devel curl-devel postgresql-devel libtidy-devel libmcrypt libmcrypt readline-devel libxslt-devel vim docbook-dtds docbook-style-xslt fop


## 添加host

    # vim /etc/hosts
    添加下面一行
    127.0.0.1 startalk.com


## 新建postgresql账号

    groupadd postgres
    useradd -g postgres postgres
    passwd postgres


## 新建安装目录

    mkdir /startalk
    # 此处修改成你的账号
    # 通过下面命令查看当前的组
    groups
    # 查看当前用户
    whoami
    # 授权目录
    chown zhangchao11:zhangchao11 /startalk


## redis

    $ sudo yum install -y redis
    
    $ sudo vim /etc/redis.conf
    将对应的配置修改为下面内容 
    daemonize yes
    requirepass 123456
    maxmemory 134217728
    
    启动redis
    $ sudo redis-server /etc/redis.conf
    
    确认启动成功：
    $ sudo netstat -antlp | grep 6379
    tcp        0      0 127.0.0.1:6379          0.0.0.0:*               LISTEN      8813/redis-server 1


## postgresql

    １ 下载源代码
    $ wget https://ftp.postgresql.org/pub/source/v11.1/postgresql-11.1.tar.gz
    
    2 编译安装
    #解压
    $ tar -zxvf postgresql-11.1.tar.gz
    $ cd postgresql-11.1/
    $ sudo ./configure --prefix=/opt/pg11 --with-perl --with-libxml --with-libxslt
    
    $ sudo make world
    #编译的结果最后必须如下，否则需要检查哪里有error
    #PostgreSQL, contrib, and documentation successfully made. Ready to install.
    
    $ sudo make install-world
    #安装的结果做后必须如下，否则没有安装成功
    #PostgreSQL installation complete.
    
    3. 添加postgres OS用户
    $ sudo mkdir -p /export/pg110_data
    
    $ sudo chown postgres:postgres /export/pg110_data
    
    4. 创建数据库实例
    $ su - postgres
    
    $ /opt/pg11/bin/initdb -D /export/pg110_data
    
    5. 修改数据库配置文件
    
    将/export/pg110_data/postgresql.conf中的logging_collector的值改为on
    
    6. 启动DB实例
    
    $ /opt/pg11/bin/pg_ctl -D /export/pg110_data start
    确认启动成功
    $ sudo netstat -antlp | grep 5432
    tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      4751/postmaster     
    
    7. 初始化DB结构
    
    # 修改为你的qtalk 所在的路径
    $ /opt/pg11/bin/psql -U postgres -d postgres -f qtalk.sql
    $ /opt/pg11/bin/psql -U postgres -d ejabberd -f init.sql
    # 初始化客服系统的sql语句
    $ /opt/pg11/bin/psql -U postgres -d ejabberd -f qchatAdminOpen.sql
    
    8. 初始化DB user: ejabberd的密码
    
    $ /opt/pg11/bin/psql -U postgres -d postgres -c "ALTER USER ejabberd WITH PASSWORD '123456';"
    
    9 psql连接数据库
    
    $ psql -U postgres -d ejabberd -h 127.0.0.1
    psql (9.2.24, server 11.1)
    WARNING: psql version 9.2, server version 11.0.
             Some psql features might not work.
    Type "help" for help.
    
    ejabberd=# select * from host_users;


# 端口情况


## redis


### 6379


## PostgreSql


### 5432


## ejabberd


### 5202长连接端口


### 10050 HTTPAPI的端口号


### 5280 WebSocket对应的端口号


### 5269 s2s使用的端口号


### 4369 ErlangVM使用的端口号


## Java


### im\_http\_service

1.  8081

2.  8001

3.  8011


### qfproxy

1.  8082

2.  8002

3.  8012


### push\_service

1.  8083

2.  8003

3.  8013


### qchat\_admin\_open

1.  8084

2.  8004

3.  8014


### qtalk\_background\_management

1.  8085

2.  8005

3.  8015


## Node


### startalk\_web IM网页版本的前端代码

1.  5000


### startalk\_node 客服系统的前段代码

1.  8997


### qtalk\_background\_web 管理后台的前段代码

1.  8090


### search 客户端用来搜索用的代码

1.  8884


# 项目安装


## nginx的安装部署


### openresty安装

    # 安装openresty
    wget https://openresty.org/download/openresty-1.13.6.2.tar.gz
    tar -zxvf openresty-1.13.6.2.tar.gz
    cd openresty-1.13.6.2
    ./configure --prefix=/startalk/openresty --with-http_auth_request_module
    make
    make install
    
    # 拷贝nginx相关的配置
    # 为了方便，我直接将openresty_ng的源码放在了/startalk,tomcat中启动很多是写死了地址
    cd /startalk
    git clone git@github.com:imtalkdemo/openresty_ng
    cd /openresty_ng
    # 这里拷贝的时候需要注意，只能进行拷贝，不能删除openresty中原有的文件夹，里面有nginx启动的必须文件
    cp -rf conf /startalk/openresty/nginx
    cp -rf lua_app /startalk/openresty/nginx
    
    # 启动：
    /startalk/openresty/nginx/sbin/nginx
    
    # 确认启动成功
    $ sudo netstat -antlp | grep 8080
    tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      23438/nginx: master
    # 关闭nginx的命令
    /startalk/openresty/nginx/sbin/nginx -s stop


## Erlang


### erlang的安装

    cd /startalk/download
    wget http://erlang.org/download/otp_src_19.3.tar.gz
    tar -zxvf otp_src_19.3.tar.gz
    cd otp_src_19.3
    ./configure --prefix=/startalk/erlang1903
    make
    make install
    
    # 添加PATH
    vim ~/.bash_profile
    
    ----------------------------------
    # User specific environment and startup programs
    ERLANGPATH=/startalk/erlang1903
    PATH=$PATH:$HOME/bin:$ERLANGPATH/bin
    ----------------------------------
    
    . ~/.bash_profile
    
    # 确认erlang安装成功
    erl
    Erlang/OTP 19 [erts-8.3] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
    
    Eshell V8.3  (abort with ^G)
    1> 


### ejabberd

    # 源码下载,源码我已经拷贝到一个测试的demo下面了,源码可以放置到你的工作目录中
    git clone git@github.com:imtalkdemo/ejabberd.git
    # 编译安装erlang
    cd ejabberd/
    ./configure --prefix=/startalk/ejabberd --with-erlang=/startalk/erlang1903 --enable-pgsql --enable-full-xml
    make
    make install
    cp ejabberd.yml.qunar /startalk/ejabberd/etc/ejabberd/ejabberd.yml
    cp ejabberdctl.cfg.qunar /startalk/ejabberd/etc/ejabberd/ejabberdctl.cfg
    
    # 启动ejabberd
    
    cd /startalk/ejabberd
    # 启动
    ./sbin/ejabberdctl start
    
    # 确认ejabberd安装成功
    # 查看当前ejabberd启动的状态，以及版本号
    /startalk/ejabberd/sbin/ejabberdctl status
    # 查看当前ejabberd的进程
    $ ps -ef | grep 's ejabberd'
    startalk 23515     1  4 09:58 ?        00:00:03 /startalk/erlang1903/lib/erlang/erts-8.3/bin/beam.smp -K true -P 250000 -- -root /startalk/erlang1903/lib/erlang -progname erl -- -home /home/startalk -- -name ejabberd@startalk.com -noshell -noinput -noshell -noinput -mnesia dir "/startalk/ejabberd/var/lib/ejabberd" -ejabberd log_rate_limit 20000 log_rotate_size 504857600 log_rotate_count 41 log_rotate_date "$D0" -s ejabberd -smp auto start
    
    # 通过以下命令连接到Ejabberd的VM上
    ./sbin/ejabberdctl debug


### 调试模式

    # 添加了一个简单的启动脚本，前台的形式启动ejabberd
    ./start.sh
    
    # 进入后默认什么都没有启动,最后的. 一定要加，语句的分隔符
    application:ensure_all_started(ejabberd).


## Java


### im\_http\_service

    # 下载源码编译
    git clone git@github.com:imtalkdemo/im_http_service.git
    
    # 编译相应的代码
    # 目前主干中代码，我已经修改了导航全部为qtalk这个域名
    # 此处编译必须要添加-Pprod选择具体的环境
    mvn package -Pprod
    
    # 拷贝编译好的war包
    cp target/im_http_service.war /startalk/openresty_ng/deps/tomcat/im_http_service/webapps
    
    # 启动相应的服务
    /startalk/openresty_ng/deps/tomcat/im_http_service/bin/startup.sh
    
    # 关闭服务
    /startalk/openresty_ng/deps/tomcat/im_http_service/bin/shutdown.sh
    
    # 前台启动tomcat的服务，方便查看日志
    /startalk/openresty_ng/deps/tomcat/im_http_service/bin/catalina.sh run


### qfproxy

    # 下载源码编译
    git clone git@github.com:imtalkdemo/qfproxy.git
    
    # 编译相应的代码
    # 目前主干中代码，我已经修改了导航全部为qtalk这个域名
    # 此处编译必须要添加-Pprod选择具体的环境
    mvn package -Pprod
    
    # 拷贝编译好的war包
    # 该项目部署的时候需要注意一个点，storage.properties中的配置，是其中的地址，目前代码我已经修改
    # 线上的部署环境是将该地址跟qfproxy分开进行部署的，就需要将相应的文件拷贝到指定的位置
    cp target/qfproxy.war /startalk/openresty_ng/deps/tomcat/qfproxy/webapps
    
    # 启动相应的服务
    /startalk/openresty_ng/deps/tomcat/qfproxy/bin/startup.sh
    
    # 关闭服务
    /startalk/openresty_ng/deps/tomcat/qfproxy/bin/shutdown.sh
    
    # 前台启动tomcat的服务，方便查看日志
    /startalk/openresty_ng/deps/tomcat/qfproxy/bin/catalina.sh run


### push\_service

    # 下载源码编译
    git clone git@github.com:imtalkdemo/push_service.git
    
    # 编译相应的代码
    # 目前主干中代码，我已经修改了导航全部为qtalk这个域名
    # 此处编译必须要添加-Pprod选择具体的环境
    mvn package -Pprod
    
    # 拷贝编译好的war包
    cp target/push_service.war /startalk/openresty_ng/deps/tomcat/push_service/webapps
    
    # 启动相应的服务
    /startalk/openresty_ng/deps/tomcat/push_service/bin/startup.sh
    
    # 关闭服务
    /startalk/openresty_ng/deps/tomcat/push_service/bin/shutdown.sh
    
    # 前台启动tomcat的服务，方便查看日志
    /startalk/openresty_ng/deps/tomcat/push_service/bin/catalina.sh run


### qchat\_admin\_open

    # 下载源码编译
    git clone git@github.com:imtalkdemo/qchat_admin_open.git
    
    # 编译相应的代码
    # 目前主干中代码，我已经修改了导航全部为qtalk这个域名
    # 此处编译必须要添加-Pprod选择具体的环境
    mvn package -Pprod
    
    # 拷贝编译好的war包
    cp target/qchat_admin_open.war /startalk/openresty_ng/deps/tomcat/qchat_admin_open/webapps
    
    # 启动相应的服务
    /startalk/openresty_ng/deps/tomcat/qchat_admin_open/bin/startup.sh
    
    # 关闭服务
    /startalk/openresty_ng/deps/tomcat/qchat_admin_open/bin/shutdown.sh
    
    # 前台启动tomcat的服务，方便查看日志
    /startalk/openresty_ng/deps/tomcat/qchat_admin_open/bin/catalina.sh run


### qtalk\_background\_management

    # 下载源码编译, 该部分的代码目前是私有的
    git clone git@github.com:jerry-chao/qtalk_background_management.git
    
    # 编译相应的代码
    # 目前主干中代码，我已经修改了导航全部为qtalk这个域名
    # 此处编译必须要添加-Pprod选择具体的环境
    mvn package -Pprod
    
    # 拷贝编译好的war包
    cp target/qtalk_background_management.war /startalk/openresty_ng/deps/tomcat/qtalk_background_management/webapps
    
    # 启动相应的服务
    /startalk/openresty_ng/deps/tomcat/qtalk_background_management/bin/startup.sh
    
    # 关闭服务
    /startalk/openresty_ng/deps/tomcat/qtalk_background_management/bin/shutdown.sh
    
    # 前台启动tomcat的服务，方便查看日志
    /startalk/openresty_ng/deps/tomcat/qtalk_background_management/bin/catalina.sh run


## Node


### startalk\_web


### startalk\_node


### qtalk\_background\_web


### search


## 正常的操作


### 管理后台添加账号，界面操作


### 客服添加用户

    INSERT INTO supplier (name, welcomes) VALUES ('店铺2', '您好，请问有什么可以帮您？');
    INSERT INTO busi_supplier_mapping (supplier_id, busi_id, busi_supplier_id, bsuid_and_type) VALUES (1, 1, '23', '231');
    insert into seat(qunar_name,web_name,supplier_id,host) values('chao.zhang','客服',1, 'qtalk');
    insert into busi_seat_mapping(busi_id,seat_id) values(1,2),(1,3),(1,4);
    INSERT INTO robot_supplier_mapping (robot_id, supplier_id, strategy) VALUES ('or_robot', 2, 3);

1.  1.创建店铺

2.  2.添加店铺映射（sql中得supplier\_id为supplier 表中的主键id；busi\_id=1 不变, busi\_supplier\_id 变更加一就行）

3.  3.添加店铺客服（qunar\_name用户登录用户名，例如：lffan.liu；web\_name 显示名，店铺id变更）

4.  4.添加客服映射（客服id 变更）

5.  5.添加机器人映射，目前没开源，映射需要（店铺id变更）

