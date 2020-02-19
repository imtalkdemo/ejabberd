

# 创建用户

    CREATE ROLE ejabberd;
    ALTER ROLE ejabberd WITH SUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
    CREATE ROLE postgres;
    ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION NOBYPASSRLS;


# 创建数据库

    CREATE DATABASE ejabberd WITH TEMPLATE = template0 OWNER = postgres;
    REVOKE ALL ON DATABASE ejabberd FROM postgres;
    ALTER DATABASE ejabberd SET standard_conforming_strings TO 'off';
    REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
    GRANT CONNECT ON DATABASE template1 TO PUBLIC;


# 表


## todo admin\_user

1.  username
2.  priority


## login\_data

1.  id：登陆记录ID
2.  username：用户名
3.  host: host域
4.  resource：端
5.  platform：平台
6.  ip：登陆ip地址
7.  login\_time: 登陆时间
8.  logout\_at: 退出时间
9.  record\_type:类型


## client\_config\_sync客户端漫游用户配置表

1.  id: 唯一ID
2.  username: 用户名
3.  host: 域名
4.  configkey: 漫游数据key
5.  subkey:漫游数据子key
6.  configinfo: 漫游数据
7.  version: 版本号
8.  operate\_plat: 操作平台
9.  create\_time: 创建时间
10. update\_time: 更新时间
11. isdel: 是否删除或者取消


## destroy\_muc\_info销毁群组表

1.  muc\_name: 群组名称
2.  nick\_name: 用户群组昵称
3.  reason: 销毁群组原因
4.  id: 唯一ID
5.  create\_at: 创建群组时间


## flogin\_user

1.  id: 唯一ID
2.  username: 用户名
3.  create\_time: 创建时间


## invite\_spool

1.  username: 用户名
2.  inviter: 邀请者用户名
3.  body: 邀请信息
4.  timestamp: 时间戳
5.  create\_at: 邀请创建时间
6.  host: 用户host
7.  ihost: 邀请者host


## fresh\_empl\_entering职员入职信息表

1.  id: 唯一ID
2.  user\_id: 用户ID
3.  user\_name: 用户名
4.  hire\_flag: 入职状态，0：已入职，1：未入职，2：推迟入职，3：待定入职
5.  join\_date: 入职日期
6.  send\_state: 消息发送状态，0：未发送，1：已发送
7.  sn: 员工号
8.  manager: 主管号
9.  manager\_mail: 主管邮箱
10. dep1: 一级部门
11. dep2: 二级部门
12. dep3: 三级部门
13. dep4: 四级部门
14. dep5: 五级部门
15. job: 岗位名称
16. job\_code: 岗位编码
17. probation\_date: 转正日期
18. version: 入职日期修改次数
19. create\_time: 创建时间
20. update\_time: 更改时间


## iplimit禁用IP表

1.  ip: 限制IP地址
2.  created\_at: 限制创建时间
3.  descriptions: 限制描述
4.  name: 限制名称
5.  priority: 限制优先级
6.  manager: 限制管理员


## host\_info

1.  id: 唯一ID
2.  host: host域名
3.  description: 描述
4.  create\_time: 创建时间
5.  host\_type: 类型
6.  host\_qrcode:
7.  need\_approve:
8.  host\_admin:


## irc\_custom用户存储数据

1.  jid: 用户JID
2.  host: 用户域
3.  data: 存储数据
4.  create\_at: 数据创建时间


## meeting\_info会议提醒信息表

1.  id: 唯一ID
2.  meeting\_id: 会议ID
3.  meeting\_name: 会议名称
4.  meeting\_remarks: 会议备注
5.  meeting\_intr: 会议内容
6.  meeting\_locale: 会议地点
7.  meeting\_room: 会议室名称
8.  schedule\_time: 会议预约时间
9.  meeting\_date: 会议日期
10. begin\_time: 会议开始时间
11. end\_time: 会议结束时间
12. inviter: 会议邀请者
13. member: 会议被邀请者
14. mem\_action: 参会人员反馈
15. remind\_flag: 提醒状态
16. refuse\_reason: 参会者拒绝参会的原因
17. canceled: 会议是否取消


## todo last

1.  username:
2.  seconds:
3.  state:


## motd

1.  usernmae:
2.  xml:
3.  create\_at


## msg\_history, msg\_history\_backup历史消息

1.  m\_from: 发送者
2.  m\_to: 接受者
3.  m\_body: 消息内容
4.  create\_time: 消息创建时间
5.  id: 唯一ID
6.  read\_flag: 已读标志
7.  msg\_id: 消息ID
8.  from\_host: 发送者host
9.  to\_host: 接收者host
10. realfrom: 真实发送者（realfrom字段)
11. realto: 真实接收者（realto字段）
12. msg\_type: 消息类型
13. update\_time: 消息更新时间


## muc\_last

1.  muc\_name:
2.  create\_time:
3.  last\_msg\_time:


## muc\_registered

1.  jid:
2.  host:
3.  nick:
4.  create\_at:


## muc\_room, muc\_room\_backup

1.  name: 群组名称
2.  host: 群组域
3.  opts: 群组属性参数
4.  create\_at: 群组创建时间


## muc\_room\_history, muc\_room\_history\_backup

1.  muc\_room\_name: 群组名称
2.  nick: 用户昵称
3.  packet: 消息内容
4.  have\_subject:
5.  size: 消息大小
6.  create\_time: 消息创建时间
7.  id: 唯一ID
8.  host: 域
9.  msg\_id: 消息ID


## notice\_history提醒消息

1.  id: 唯一ID
2.  msg\_id: 消息ID
3.  m\_from: 消息发送者
4.  m\_body: 消息内容
5.  create\_time:消息的创建时间
6.  host:


## muc\_room\_users群组用户表

1.  muc\_name: 群组名称
2.  username: 用户名称
3.  host: host域
4.  subscribe\_flag: 订阅标志
5.  id: 唯一ID
6.  date: 加入时间
7.  login\_date: 最近登录时间
8.  domain: domain域
9.  update\_time: 更新时间


## muc\_vcard\_info群组基础信息表

1.  muc\_name: 群组名称
2.  show\_name: 显示名称
3.  muc\_desc: 群组描述信息
4.  muc\_title: 群组主题
5.  muc\_pic: 群头像
6.  show\_name\_pinyin: 群组中文显示
7.  update\_time: 信息更新时间
8.  version: 信息版本号


## muc\_user\_mark用户群组登陆，登出记录信息

1.  muc\_name: 群组名称
2.  user\_name: 用户名称
3.  login\_date: 登出时间
4.  logout\_date: 退出时间
5.  id: 唯一ID


## privacy\_default\_list黑名单默认列表

1.  username: 用户名
2.  name: 默认列表名称


## privacy\_list黑名单列表

1.  username: 用户名
2.  name: 黑名单名字
3.  id: 唯一ID
4.  create\_at: 创建时间


## privacy\_list\_data

1.  id: 同privacy\_list表中的ID
2.  t:
3.  value:
4.  ord:
5.  match\_all: 所有都禁用
6.  match\_iq: 禁用IQ消息
7.  match\_message: 禁用message
8.  match\_presence\_in: 不接受presence In的通知
9.  match\_presence\_out: 不发送presence Out的通知


## private\_storage

1.  username:
2.  namespace:
3.  data:
4.  create\_at:


## pubsub\_node\_option

1.  nodeid:
2.  name:
3.  val:


## pubsub\_node\_owner

1.  nodeid:
2.  owner:


## pubsub\_state

1.  nodeid:
2.  jid:
3.  affiliation:
4.  subscriptions:
5.  stateid:


## pubsub\_node

1.  host:
2.  node:
3.  parent:
4.  type:
5.  nodeid:


## pubsub\_item

1.  nodeid:
2.  itemid:
3.  publisher:
4.  creation:
5.  modification:
6.  payload:


## pubsub\_subscription\_opt

1.  subid:
2.  opt\_name:
3.  opt\_value:


## push\_info存储用户推送信息

1.  id: 唯一ID
2.  user\_name: 用户名
3.  host: 用户域
4.  mac\_key:用户上传唯一key,给指定key发送push
5.  platname:adr端平台名称，如mipush
6.  pkgname: adr端应用包名
7.  os: 平台系统， ios或者android
8.  version: 版本号
9.  create\_time: 创建时间
10. update\_at: 更新时间
11. show\_content: 是否显示推送详细内容，默认值1， 显示；0 不显示
12. push\_flag: 是否push标志位


## qtalk\_user\_comment用户点评表

1.  id: 唯一ID
2.  from\_user: 点评人
3.  to\_user: 被点评人
4.  create\_time: 点评时间
5.  comment: 点评内容
6.  grade: true 赞， false 扁


## recv\_msg\_option

1.  username:
2.  rec\_msg\_opt:
3.  version:


## revoke\_msg\_history, revoke\_msg\_history\_backup撤回消息表

1.  m\_from: 发送者
2.  m\_to: 接收者
3.  m\_body: 消息内容
4.  id: 唯一ID
5.  m\_timestamp: 消息时间戳
6.  msg\_id: 消息ID
7.  create\_time: 创建时间


## s2s\_mapped\_host

1.  domain: 域名称
2.  host: host地址
3.  port: 端口
4.  priority: 优先级
5.  weight: 权重


## user\_friends

1.  username:
2.  friend:
3.  relationship:
4.  version:
5.  host:
6.  userhost:


## qcloud\_main Evernote主列表存储表

1.  id: 唯一ID
2.  q\_user: 信息所属用户
3.  q\_type: 信息类型
4.  q\_title: 标题
5.  q\_instroduce: 介绍
6.  q\_content: 内容
7.  q\_time: 最后修改时间
8.  q\_state: 信息状态标记(正常、收藏、废纸篓、删除)


## user\_register\_mucs, user\_register\_mucs\_backup

1.  username: 用户名
2.  muc\_name: 群组名
3.  domain: 群组domain
4.  created\_at: 创建时间
5.  registed\_flag: 注册标记
6.  host: 用户host


## qcloud\_main\_history Evernote主列表操作历史

1.  id: 唯一ID
2.  q\_id: 主列表ID
3.  qh\_content: 操作内容
4.  qh\_time: 操作时间
5.  qh\_state: 状态


## user\_relation\_opts

1.  username:
2.  rec\_msg\_opt:
3.  vld\_friend\_opt:
4.  validate\_quetion:
5.  validate\_answer:
6.  version:
7.  userhost:


## vcard\_version

1.  username:
2.  version:
3.  url:
4.  uin:
5.  id:
6.  profile\_version:
7.  mood:
8.  gender:
9.  host:


## white\_list

1.  username:
2.  created\_at:
3.  single\_flag:


## host\_users

1.  id:
2.  host\_id:
3.  user\_id:
4.  user\_name:
5.  department:
6.  tel:
7.  email:
8.  dep1:
9.  dep2:
10. dep3:
11. dep4:
12. dep5:
13. pinyin:
14. frozen\_flag:
15. version:
16. user\_type:
17. hire\_flag:
18. gender:
19. password:
20. initialpwd:
21. pwd\_salt:
22. leader:
23. hrbp:
24. user\_role:
25. approve\_flag:
26. user\_desc:
27. user\_origin:
28. hire\_type:
29. admin\_flag:
30. create\_time:
31. ps\_deptid:


## qcloud\_sub Evernote子列表操作

1.  id: 唯一ID
2.  q\_id: 主列表ID
3.  qs\_user:信息所属用户
4.  qs\_type: 信息类型
5.  qs\_title: 标题
6.  qs\_introduce: 介绍
7.  qs\_content: 内容
8.  qs\_time: 最后修改时间
9.  qs\_state: 信息状态标记（正常、收藏、废纸篓、删除）


## qcloud\_sub\_history Evernote子列表操作历史

1.  id: 唯一ID
2.  qs\_id: 主列表ID
3.  qh\_content: 操作内容
4.  qh\_time: 操作时间
5.  qh\_state: 状态


## scheduling\_info行程信息表

1.  id: 唯一ID
2.  scheduling\_id:行程ID
3.  scheduling\_name:行程名称
4.  scheduling\_type:行程类型，1是会议，2是约会
5.  scheduling\_remarks:行程备注
6.  scheduling\_intr: 行程简介
7.  scheduling\_appointment: 行程介绍
8.  scheduling\_locale: 行程地点
9.  scheduling\_locale\_id: 行程地点编号
10. scheduling\_room: 行程房间
11. scheduling\_room\_id: 行程房间编号
12. schedule\_time: 行程约定的时间
13. scheduling\_date: 行程日期
14. begin\_time: 行程开始时间
15. end\_time: 行程结束时间
16. inviter: 行程邀请者
17. member:行程参与者
18. mem\_action: 行程参与者接受状态
19. remind\_flag:行程参与者提醒标志，0未提醒，1开始前15分钟已提醒，2结束前15分钟已提醒
20. action\_remark: 行程参与者接受时的备注
21. canceled: 行程是否被取消
22. update\_time: 行程更新时间


## warn\_msg\_history, warn\_msg\_history\_backup警告消息历史

1.  id: 唯一ID
2.  m\_from: 发送者
3.  m\_to: 接收者
4.  read\_flag: 已读状态
5.  msg\_id: 消息ID
6.  from\_host: 发送者host
7.  to\_host: 接受者host
8.  m\_body: 消息内容
9.  create\_time: 消息创建时间


## sys\_role

1.  id: 唯一ID
2.  describe: 角色描述
3.  create\_time: 角色创建时间
4.  update\_time: 角色更新时间
5.  role\_name: 角色名称


## sys\_permission

1.  id: 唯一ID
2.  url: 权限地址
3.  describe:权限描述
4.  create\_time:创建时间
5.  update\_time:更新时间
6.  status: 0:导航栏不显示,1:导航栏显示
7.  sub\_permission\_ids:子权限id列表
8.  navigation\_flag: 是否映射导航栏


## sys\_role\_permission

1.  id: 唯一ID
2.  role\_id: 角色ID
3.  permission\_id: 权限ID


## sys\_user\_role

1.  id: 唯一ID
2.  role\_id: 角色ID
3.  user\_id: 用户ID


## persistent\_logins

1.  username:
2.  series:
3.  token:
4.  last\_used:


## find\_application\_table

1.  id: 唯一ID
2.  application\_type: 应用类型，2RN应用，3 H5应用
3.  visible\_range: 可见性范围，空标识全员可见
4.  application\_name: 应用名称
5.  application\_class: 应用分类
6.  application\_icon: 应用图标
7.  application\_version: 应用版本号
8.  ios\_version: ios版本号
9.  android\_version: android版本号
10. ios\_bundle: iosbundle包，h5应用的话对应的是h5的地址
11. android\_bundle: android的bundle包，h5应用对应的是地址
12. application\_desc: 应用描述
13. create\_time: 创建时间
14. update\_time: 更新时间
15. disable\_flag: 禁用标志位
16. member\_id: 在群组的ID
17. h5\_action: h5页面地址
18. entrance: RN应用的入口地址
19. properties: 额外初始属性map的json
20. module: RN应用的程序入口
21. show\_native\_nav: 是否显示导航
22. nav\_title: 导航title h5应用不生效
23. valid\_platform: 可适配的客户端类型，IOS Angroid PC
24. visible\_platform: ios|Android|pc(101):5
25. bundle\_name: bundle 包的文件名 不同于applicaName
26. h5\_action\_ios: ios h5的页面地址
27. h5\_action\_android: android h5页面地址
28. delete\_flag: 删除标记位，1删除 0未删除
29. native\_flag: 原生应用标记0是自定义，1是原生应用禁止修改
30. app\_uuid: 应用的UUID


## find\_class\_table 应用分类表

1.  id: 唯一ID
2.  group\_name: 分组名称
3.  group\_icon: 分组图标


## startalk\_dep\_table 部门信息表

1.  id: 唯一ID
2.  dep\_name: 部门名称
3.  dep\_level: 部门层级
4.  dep\_vp: 部门领导
5.  dep\_hr: 部门HR
6.  dep\_visible: 部门可见性
7.  dep\_leader: 部门领导
8.  parent\_id: 父级部门的ID
9.  delete\_flag: 部门删除标记位,0是未删除 1是已删除
10. dep\_desc: 部门信息备注
11. create\_time: 创建时间
12. update\_time: 更新时间


## startalk\_role\_class 角色分组

1.  id: 唯一ID
2.  role\_class: 角色分组
3.  available\_flag: 可用标志 1是可用 0表示不可用


## startalk\_user\_role\_table用户角色表

1.  id:唯一ID
2.  role\_name: 角色名
3.  available\_flag: 可用标志位,1可用 0 不可用
4.  class\_id: 角色所属组别的ID


## data\_board\_day数据统计表

1.  id: 唯一ID
2.  activity: 活跃数
3.  client\_online\_time: 客户端在线时间
4.  start\_count: 启动次数
5.  client\_version: 客户端版本统计
6.  day\_msg\_count: 每天消息量
7.  day\_msg\_average: 每天平均消息量
8.  department\_data: 部门数据统计
9.  hire\_type\_data: 人员类型统计
10. create\_time: 创建时间
11. platform\_activity: 平台活跃数
12. dep\_activity: 部门活跃数
13. hire\_type\_activity: 人员类型活跃数


## client\_upgrade

1.  id: 唯一ID
2.  client\_type: 客户端类型， qtalk, qchat
3.  platform: 平台Android，ios
4.  version: 版本号
5.  copywriting: 更新文案
6.  grayscale\_status: 灰度测试状态 0:否 1:是
7.  grayscale\_value: 灰度量
8.  upgrade\_status: 更新状态 0:强制更新 1:选择更新
9.  upgrade\_url: 更新地址
10. create\_time: 创建时间
11. update\_time: 更新时间
12. md5\_key: 文件MD5
13. stop\_status: 是否停止更新， 0:否，1:是
14. stop\_reason: 停止更新原因
15. updated\_count: 已更新量


## t\_client\_log

1.  id:
2.  u\_id:
3.  u\_domain:
4.  d\_os:
5.  d\_brand:
6.  d\_model:
7.  d\_plat:
8.  d\_ip:
9.  d\_lat:
10. d\_lgt:
11. l\_type:
12. l\_sub\_type:
13. l\_report\_time:
14. l\_data:
15. l\_device\_data:
16. l\_user\_data:
17. l\_version\_code:
18. l\_version\_name:
19. create\_time:
20. l\_client\_event:
21. d\_platform:
22. l\_event\_id:
23. l\_current\_page:


## t\_dict\_client\_brand品牌渠道字典表

1.  id:唯一key
2.  brand: 客户端手机品牌
3.  platform:品牌所属平台
4.  del\_flag: 删除标识 0 - 未删除 1 - 删除
5.  create\_time: 创建时间


## t\_dict\_client\_model机型字典表

1.  id: 唯一key
2.  client\_model: 机型
3.  client\_brand: 品牌
4.  platform: 所属平台
5.  del\_flag: 删除标识 0 - 未删除 1 - 删除
6.  create\_time: 创建时间


## t\_dict\_client\_version客户端版本字典表

1.  id: 唯一Key
2.  client\_version:qtalk客户端版本
3.  platform: 所属平台
4.  del\_flag: 删除标识 0 - 未删除 1 - 删除
5.  create\_time: 创建时间


## t\_dict\_client\_event点击事件字典表

1.  id: 唯一key
2.  event: 事件
3.  platform: 所属平台
4.  del\_flag: 删除标识 0 - 未删除 1 - 删除
5.  create\_time: 创建时间


## statistic\_qtalk\_click\_event点击统计数据表

1.  id: 唯一key
2.  client\_platform: 所属平台
3.  client\_version: 客户端版本号
4.  client\_brand: 客户端品牌
5.  client\_model: 客户端型号
6.  click\_event: 点击事件
7.  click\_day:日期（天）
8.  click\_cnt: 点击次数
9.  del\_flag: 删除标识 0 - 未删除 1 - 删除
10. create\_time: 创建时间


## qtalk\_config配置key

1.  id: 唯一key
2.  config\_key: 配置key
3.  config\_value: 配置值
4.  create\_time: 创建时间


## busi\_seat\_group\_mapping业务线

1.  id: 唯一key
2.  busi\_id:
3.  group\_id:
4.  create\_time:
5.  last\_update\_time:


## busi\_seat\_mapping

1.  id:
2.  busi\_id:
3.  seat\_id:
4.  create\_time:
5.  last\_update\_time:
6.  status:


## busi\_supplier\_mapping

1.  id:
2.  supplier\_id:
3.  busi\_id:
4.  busi\_supplier\_id:
5.  create\_time:
6.  last\_update\_time:
7.  bsuid\_and\_type:
8.  supplier\_operator:
9.  operator\_webname:
10. status:


## business

1.  id:
2.  name:
3.  create\_time:
4.  last\_update\_time:
5.  english\_name:


## consult\_msg\_history

1.  id:
2.  m\_from:
3.  m\_to:
4.  m\_body:
5.  create\_time:
6.  read\_flag:
7.  msg\_id:
8.  from\_host:
9.  to\_host:
10. realfrom:
11. realto:
12. msg\_type:
13. status
14. qchat\_id:
15. chat\_id:
16. update\_time:


## consult\_tag

1.  id:
2.  title:
3.  content:
4.  supplier\_id:
5.  busi\_supplier\_id:
6.  pid:
7.  status:
8.  consult\_type:
9.  create\_time:
10. update\_time:
11. busi\_id:


## group\_product\_mapping

1.  id:
2.  group\_id:
3.  pid:
4.  create\_time:
5.  last\_update\_time:


## hotline\_supplier\_mapping

1.  id:
2.  hotline:
3.  supplier\_id:
4.  status:
5.  create\_time:
6.  update\_time:


## log\_operation

1.  id:
2.  operate\_type:
3.  item\_type:
4.  item\_id:
5.  item\_str:
6.  operator:
7.  operate\_time:
8.  content:


## page\_template

1.  id:
2.  name:
3.  page\_css:
4.  page\_html:
5.  busi\_id
6.  create\_time:
7.  last\_update\_time:


## queue\_mapping

1.  id:
2.  customer\_name:
3.  shop\_id:
4.  product\_id:
5.  seat\_id:
6.  status:
7.  request\_count:
8.  distributed\_time:
9.  inqueue\_time:
10. last\_ack\_time:
11. session\_id:
12. seat\_time:
13. group\_id:


## queue\_saved\_message

1.  id:
2.  message\_id:
3.  customer\_name:
4.  shop\_id:
5.  message:
6.  op\_time:


## quickreply\_content

1.  id:
2.  username:
3.  host:
4.  groupid:
5.  content:
6.  contentseq:
7.  version:
8.  isdel:
9.  cgid:
10. ccid:
11. create\_time:
12. update\_time:
13. ext:


## quickreply\_group

1.  id:
2.  username:
3.  host:
4.  groupname:
5.  groupseq:
6.  version:
7.  isdel:
8.  cgid:
9.  create\_time:
10. update\_time:
11. ext:


## robot\_info

1.  id:
2.  robot\_id:
3.  busi\_id:
4.  robot\_name:
5.  create\_time:
6.  update\_time:
7.  operator:
8.  status:
9.  imageurl:


## robot\_supplier\_mapping

1.  id:
2.  robot\_id:
3.  supplier\_id:
4.  strategy:
5.  welcome:
6.  create\_time:


## seat


## seat\_group


## seat\_group\_mapping


## seat\_session


## session


## session\_mapping


## supplier


## sys\_user


## test\_user
