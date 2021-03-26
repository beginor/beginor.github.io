---
layout: post2
title: 在 Java Spring 应用中使用 ASP.NET Core Identity 的数据库进行用户认证
description: 本文介绍如何让 Spring Web 应用使用 ASP.NET Core Identity 的数据库进行用户认证
keywords: nhibernate, asp.net core identity, spring-web/mvc, spring security, apache shiro
tags: [.NET, Spring]
---

## 使用 NHibernate 创建 Asp.Net Core 应用

ASP.NET Core Identity 拥有完整的的用户认证、角色以及授权、开放认证的接口规范， 并且默认使用自家的 EntityFramework 进行了实现。

[NHibernate](https://nhibernate.info/) 是 .NET 平台上老牌的对象关系映射 (ORM) 类库， 成熟度很高， 也实现了 [ASP.NET Core Identity](https://github.com/nhibernate/NHibernate.AspNetCore.Identity) 的认证支持。

![ASPNET CORE IDENTITY DB SCHEMA](/assets/post-images/aspnet_core_identity_db_schema.png)

Identity 定义了一套完善的、可扩展的数据表结构， 存储用户、角色、权限等信息， 以及一套完善的用户/角色/权限管理 API 。

根据 NHibernate.AspNetCore.Identity 中的[说明](https://github.com/nhibernate/NHibernate.AspNetCore.Identity/blob/master/README.md)， 创建一个示例项目， 需要注意的问题主要有：

- 使用 NHibernate.AspNetCore.Identity 提供的 sql 语句创建数据表， 而不是使用 NHibernate 的 Schema Export 来建表， 这样可以更加准确的控制数据库；
- 为了和 Java 的 Spring 项目能够使用同样的用户（即： 使用 .Net Identity 创建用户/管理， Spring 应用使用用户名/密码进行登录）， 创建了一个自定义的 [PasswordHasher](https://github.com/beginor/spring-identity-demo/blob/main/identity-web-demo/Authorization/PasswordHasher.cs) 作为示例， 将密码用 SHA-256 进行散列存储， 仅作为参考， 在实际项目中需要进一步选择更加安全的加密存储；

### 创建测试用户

使用 Identity 创建用户 admin 的示例代码如下：

```c#
var user = await userManager.FindByNameAsync("admin");
if (user == null) {
    user = new AppUser {
        UserName = "admin",
        Email = "admin@local.com",
        EmailConfirmed = true,
        PhoneNumber = "13400000000",
        PhoneNumberConfirmed = true,
        LockoutEnabled = true
    };
    await userManager.CreateAsync(user);
    await userManager.AddPasswordAsync(user, "1a2b3c$D");
}
else {
    var token = await userManager.GeneratePasswordResetTokenAsync(user);
    await userManager.ResetPasswordAsync(user, token, "1a2b3c$D");
}
```

### 用户登录

用户登录的示例代码为：

```c#
[HttpPost("login")]
public async Task<ActionResult<string>> Login(LoginModel model) {
    var user = await userManager.FindByNameAsync(model.Username);
    if (user == null) {
        return NotFound("Not found!");
    }
    var isValid = await userManager.CheckPasswordAsync(user, model.Password);
    if (isValid) {
        await signInManager.SignInAsync(user, model.RememberMe);
        return Ok(model.Username);
    }
    return "Invalid User!";
}
```

### 获取用户信息

获取用户信息的示例代码为：

```c#
[HttpGet("info")]
public string GetInfo() {
    return User.Identity.IsAuthenticated
        ? User.Identity.Name
        : "anonymous";
}
```

对于熟悉 .NET 的开发者来说， 这些都是常规操作， 具体的示例项目代码可以参考这里 <https://github.com/beginor/spring-identity-demo/tree/main/identity-web-demo> 。

接下来就是本文的重点， 在 Spring 应用中使用 ASP.NET Identity 的数据库用户。

## 使用 Spring Security 作认证

Spring Security 是 Spring 全家桶中负责认证的组件， 自然是 Spring 项目进行安全认证的首选。

### 创建 Spring Security 应用

访问 <https://start.spring.io/> ， 创建一个 Spring Web 应用， 本文的选择为：

- 项目模型 (Project) 选择 Gradle ;
- 开发语言 (Language) 选择 Java ;
- Spring Boot 的版本选择默认的 2.4.4 ；
- Java 版本选择 11 ；

添加的依赖项为：

- Spring Web
- Spring Security
- Spring Boot DevTools
- Spring Data JDBC
- PostgreSQL Driver

下载并解压生成的项目， 输入命令 `./gradlew bootJar` ， 等待编译完成。

### 自定义安全配置使用 Identity 数据库

在 application.yml 中添加数据源信息， 和上文的 .NET 应用的数据库信息保持一致：

```yml
spring:
  datasource:
    url: jdbc:postgresql://127.0.0.1:5432/spring_demo
    username: postgres
    password: postgis_11
    driver-class-name: org.postgresql.Driver
```

创建一个自定义的 `Sha256PasswordEncoder` 进行密码存储， 代码如下：

```java
public class Sha256PasswordEncoder implements PasswordEncoder {

    @Override
    public String encode(CharSequence rawPassword) {
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            var hash = digest.digest(rawPassword.toString().getBytes(StandardCharsets.UTF_8));
            var result = Base64.getEncoder().encodeToString(hash);
            return result;
        }
        catch (Exception ex) {
            return null;
        }
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        var encoded = encode(rawPassword);
        if (encoded == null) {
            return false;
        }
        return encoded.equals(encodedPassword);
    }
}
```

创建自定义的安全配置， 设置 `JdbcDaoImpl` 来查询 Identity 数据库中的信息， 代码如下：

```java
@Configuration
@EnableWebSecurity()
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    
    private DataSource dataSource;

    /// 注入配置的数据源
    @Autowired
    public WebSecurityConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 基本的安全配置
        http.authorizeRequests()
            .antMatchers("/", "/home").permitAll()
            .anyRequest().authenticated()
            .and()
            .formLogin()
            .loginPage("/login")
            .permitAll()
            .and()
            .logout()
            .permitAll();
    }
    
    @Bean
    @Override
    protected UserDetailsService userDetailsService() {
        // 使用内置的 JdbcDaoImpl 作为 UserDetailsService 。
        var jdbcDao = new JdbcDaoImpl();
        jdbcDao.setDataSource(dataSource);
        // 禁用对单个用户的直接权限
        jdbcDao.setEnableAuthorities(false);
        // 启用用户组（角色）权限
        jdbcDao.setEnableGroups(true);
        jdbcDao.setUsernameBasedPrimaryKey(false);
        // 从 aspnet_users 表中查询用户信息
        jdbcDao.setUsersByUsernameQuery(
            "select user_name as username, password_hash as password, email_confirmed as enabled\n" + 
            "from public.aspnet_users\n" +
            "where normalized_user_name = upper(?);"
        );
        // 从 aspnet_role_claims 中查询用户所在角色的权限列表
        jdbcDao.setGroupAuthoritiesByUsernameQuery(
            "select r.id, r.name as group_name, rc.claim_value as authority\n" +
            "from public.aspnet_roles r\n" +
            "inner join public.aspnet_role_claims rc\n" +
            "    on rc.role_id = r.id and rc.claim_type = 'AppPrivilege'\n" +
            "inner join public.aspnet_user_roles ur on ur.role_id = r.id\n" +
            "inner join public.aspnet_users u on ur.user_id = u.id\n" +
            "    and u.normalized_user_name = upper(?);"
        );
        return jdbcDao;
    }
    // 使用自定义的 Sha256PasswordEncoder 
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new Sha256PasswordEncoder();
    }
}
```

### 获取用户认证信息

要获取用户信息， 可以直接使用 `Authentication` 以获取用户信息， 代码如下

```java
@GetMapping("/info")
public String getInfo(Authentication authentication) {
    SecurityExpressionRoot root;
    UserDetails user = (UserDetails) authentication.getPrincipal();
    return "Hello, " + authentication.getName();
}
```

要了解更详细的实现信息， 请查看 [security-web-demo](https://github.com/beginor/spring-identity-demo/tree/main/security-web-demo) 源代码。

## 使用 Apache Shiro 为 Spring Web 应用做安全认证

Apache Shiro是一个功能强大且易于使用的Java安全框架， 很多 Spring 项目会选择 Shiro 作为安全认证。

### 创建 Spring Web 应用

访问 <https://start.spring.io/> ， 创建一个 Spring Web 应用， 本文的选择为：

- 项目模型 (Project) 选择 Gradle ;
- 开发语言 (Language) 选择 Java ;
- Spring Boot 的版本选择默认的 2.4.4 ；
- Java 版本选择 11 ；

添加的依赖项为：

- Spring Web
- Spring Boot DevTools
- Spring Data JDBC
- PostgreSQL Driver

下载并解压生成的项目， 输入命令 `./gradlew bootJar` ， 等待编译完成。

### 添加 Apache Shiro

根据 Shiro 的文档， 在 build.gradle 中添加依赖项：

```gradle
implementation 'org.apache.shiro:shiro-spring-boot-web-starter:1.7.1'
```

在 application.yml 中添加数据源信息， 和上文的 .NET 应用的数据库信息保持一致：

```yml
spring:
  datasource:
    url: jdbc:postgresql://127.0.0.1:5432/spring_demo
    username: postgres
    password: postgis_11
    driver-class-name: org.postgresql.Driver
```

根据 Shiro 的文档， 需要配置 `Realm` 和 `ShiroFilterChainDefinition` ， Shiro 提供了内置的 `JdbcRealm` , 在这里调整为查询上面 .NET 应用创建的数据表， 并且使用相同的 SHA-256 对密码进行散列存储。

- 设置 `JdbcRealm` 的 `authenticationQuery` 查询 `aspnet_users` 表中的用户信息；
- 设置 `JdbcRealm` 的 `userRolesQuery` 查询 `aspnet_roles` 表中的角色信息；
- 设置 `JdbcRealm` 的 `permissionsQuery` 查询 `aspnet_role_claims` 表中的角色权限信息；

代码如下：

```java
 @Bean
public Realm realm(DataSource dataSource) {
    var realm = new JdbcRealm();
    realm.setDataSource(dataSource);
    // 查询 aspnet_users 中的 password_hash 作为 password 返回
    realm.setAuthenticationQuery(
        "select password_hash as password " +
        "from public.aspnet_users where user_name = ?"
    );
    // 查询 aspnet_roles 表中的角色名称；
    realm.setUserRolesQuery(
        "select r.name as role_name from public.aspnet_roles r " +
        "inner join public.aspnet_user_roles ur on ur.role_id = r.id " +
        "inner join public.aspnet_users u on u.id = ur.user_id " +
        "where u.normalized_user_name = upper(?)"
    );
    // 启用权限查询
    realm.setPermissionsLookupEnabled(true);
    // 从 aspnet_role_claims 查询角色的权限
    realm.setPermissionsQuery(
        "select claim_value as permission from public.aspnet_role_claims rc " +
        "inner join public.aspnet_roles r on r.id = rc.role_id " +
        "and rc.claim_type = 'AppPrivilege' and r.name = ?"
    );
    // 使用 SHA-256 散列算法来加密存储密码
    var matcher = new HashedCredentialsMatcher();
    matcher.setHashAlgorithmName("SHA-256");
    matcher.setStoredCredentialsHexEncoded(false);
    realm.setCredentialsMatcher(matcher);
    return realm;
}

@Bean
public ShiroFilterChainDefinition shiroFilterChainDefinition() {
    var chainDef = new DefaultShiroFilterChainDefinition();
    // chainDef.addPathDefinition("/**", "authc");
    return chainDef;
}
```

### 登录用户

使用 Shiro 进行登录的代码为：

```java
@PostMapping("/login")
public String login(
    @RequestBody LoginInfo info
) {
    try {
        var user = SecurityUtils.getSubject();
        var token = new UsernamePasswordToken(
            info.getUsername(),
            info.getPassword(),
            info.isRememberMe()
        );
        user.login(token);
        return user.getPrincipal().toString();
    }
    catch (AuthenticationException ex) {
        return ex.getMessage();
    }
}
```

### 查询用户信息

```java
@GetMapping("/info")
public String getInfo() {
    var user = SecurityUtils.getSubject();
    return user.isAuthenticated()
        ? user.getPrincipal().toString()
        : "anonymous";
}
```

要了解更详细的实现信息， 请查看 [shiro-web-demo](https://github.com/beginor/spring-identity-demo/tree/main/shiro-web-demo) 源代码。

## 总结

经过上面的折腾， 在数据库层面基本上统一了 .NET 和 Spring 应用的认证， 使用相同的数据库， 保护企业现有的资产， 比如使用原来的 .NET 后台管理用户、 角色、 权限、 菜单以及相互绑定， 而在新开发的 Spring 应用中直接使用这些信息。
