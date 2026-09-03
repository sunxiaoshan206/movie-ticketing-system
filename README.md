# 电影票务系统（Movie Ticketing System）

基于 Java Servlet 的在线电影票务系统，覆盖用户端选座购票、影评发布与后台排期/座位管理全流程。

> Java Web 课程设计 / 独立开发 / 2025.12

## 技术栈

- **后端**：Java、Servlet
- **数据库**：MySQL
- **Web 容器**：Apache Tomcat
- **开发工具**：Eclipse

## 核心功能

### 用户端
- 用户注册、登录
- 影片排期查询
- 在线选座购票
- 订单查询
- 影评发布

### 管理端
- 影片信息管理
- 影片排期设置
- 订单统计
- 影院座位管理

## 运行方式

```bash
# 1. 克隆仓库
git clone https://github.com/sunxiaoshan206/movie-ticketing-system.git
cd movie-ticketing-system

# 2. 准备 MySQL，导入项目中的 SQL 文件
#    数据库名：movie_ticket

# 3. 修改数据库连接配置（jdbc.properties 或同目录文件）
#    jdbc.url=jdbc:mysql://localhost:3306/movie_ticket
#    jdbc.username=root
#    jdbc.password=123456

# 4. 部署到 Tomcat
#    - Eclipse 中：右键项目 → Run As → Run on Server
#    - 或：将项目导出为 WAR 包放入 Tomcat 的 webapps 目录后启动 Tomcat

# 5. 浏览器访问
http://localhost:8081/MovieTicketingSystem
```
## 数据库初始化

将项目中 `sql/` 目录下的 SQL 文件导入 MySQL 后，再按"运行方式"启动项目。  
**首次部署后通过注册功能创建测试账号**（管理员账号如需初始化，请按你项目实际设计执行）。

## 项目截图



## 目录结构

MovieTicketSystem/
├──src/main/java/
│├──com/
││├──dao/#数据访问层
││├──entity/#实体类
││├──filter/#过滤器
││├──servlet/#Servlet控制器
││└──util/#工具类
|├──src/main/resources/#资源文件
│└──webapp/
│├──WEB-INF/
││├──lib/#依赖库
│││├──mysql-connector-j-8.0.33.jar
│││└──servlet-api.jar
││├──web.xml#部署描述符
││└──*.jsp#JSP页面（部分）
│├──css/#样式文件
│├──js/#JavaScript文件
│├──pages/#页面目录
│└──*.jsp#根目录JSP页面
│
├──build/#编译输出
└──引用的库/#外部库

## 后续可优化方向

- [ ] 引入 Spring 改造为 MVC 架构
- [ ] 接入第三方支付
- [ ] 影评点赞、回复
- [ ] 影片推荐（基于用户历史购票）
