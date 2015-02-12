---
layout: post
title: 从 OAuth2 服务器获取授权授权
description: 本文介绍 OAuth2 定义的四种授权方式及其对应的实现方式
tags: [OAuth2, OWIN, ASP.NET, WebAPI]
keywords: OWIN, OAuth2, ASP.NET MVC, WebAPI, code, access_token, 
---

搭建好了[基于 OWIN 的 OAuth2 服务器][1]之后， 接下来就是如何从服务器取得授权了， 下面就介绍如何实现 OAuth2 定义的四种授权方式。

## 授权码授权 (Authorization Code Grant)

[授权码授权][2]针对机密的客户端优化， 可以同时获取访问凭据 (access token) 和刷新凭据 (refresh token) ， 因为是基于 HTTP 重定向的方式， 所以客户端必须能够操纵资源所有者的用户代理（通常是浏览器）并且能够接收从授权服务器重定向过来的请求。

![authorization-code-grant](http://beginor.github.io/assets/post-images/oauth2-1-authorization-code-grant.png)

在实现上使用开源的 [DotNetOpenAuth][3] 来简化实现代码， DotNetOpenAuth 可以[通过 NuGet 获取][4]， 示例代码如下：

```c#
// init a new oauth web server client;
var authServer = new AuthorizationServerDescription {
    AuthorizationEndpoint = new Uri(Paths.AuthorizePath),
    TokenEndpoint = new Uri(Paths.TokenPath)
};
var webServerClient = new WebServerClient(authServer, clientId, clientSecret);

// redirect user user-agent to authorization endpoint;
var userAuthorization = webServerClient.PrepareRequestUserAuthorization(new[] { "bio", "notes" });
userAuthorization.Send(HttpContext);
Response.End();

// get access token from request (redirect from oauth server)
var authorizationState = webServerClient.ProcessUserAuthorization(Request);
if (authorizationState != null) {
    ViewBag.AccessToken = authorizationState.AccessToken;
    ViewBag.RefreshToken = authorizationState.RefreshToken;
    ViewBag.Action = Request.Path;
}

//refresh token
var state = new AuthorizationState {
    AccessToken = Request.Form["AccessToken"],
    RefreshToken = Request.Form["RefreshToken"]
};
if (webServerClient.RefreshAuthorization(state)) {
    ViewBag.AccessToken = state.AccessToken;
    ViewBag.RefreshToken = state.RefreshToken;
}

// call protected user resource
var client = new HttpClient(webServerClient.CreateAuthorizingHandler(accessToken));
var body = await client.GetStringAsync(new Uri(Paths.ResourceUserApiPath));
ViewBag.ApiResponse = body;
```

## 隐式授权 (Implicit Grant)

[隐式授权][5]为已知的公开客户端优化， 用于客户端操作一个特定的重定向地址， 只能获取访问凭据 (access token) ， 不支持刷新凭据 (refresh token) 。 客户端通常在浏览器内用 Javascript 实现。

因为是基于 HTTP 重定向的方式， 所以客户端必须能够操纵资源所有者的用户代理（通常是浏览器）并且能够接收从授权服务器重定向过来的请求。

与授权码授权方式不同的是， 客户端不需要为授权和访问凭据分别发送单独的请求， 可以直接从授权请求获取访问凭据。

隐式授权不包括客户端授权， 依赖资源所有者（用户）的现场判断以及客户端重定向地址， 由于访问凭据是在 URL 中编码的， 所以有可能会暴漏给用户或客户端上的其它应用。

![implicit-grant](http://beginor.github.io/assets/post-images/oauth2-2-implicit-grant.png)

由于这种授权方式一般是通过浏览器实现的， 所以就不用依赖 DotNetOpenAuth 了， 只需要 Javascript 就行了， 示例代码如下：

```js
// index.html
var authorizeUri = '@(Paths.AuthorizePath)';
var tokenUri = '@(Paths.TokenPath)';
var apiUri = '@Paths.ResourceUserApiPath';

var clientId = '@clientId';
var returnUri = '@clientRedirectUrl';
var nonce = 'my-nonce';

$('#authorize').click(function () {
    // build redirect url
    var uri = addQueryString(authorizeUri, {
        'client_id': clientId,
        'redirect_uri': returnUri,
        'state': nonce,
        'scope': 'bio notes',
        'response_type': 'token'
    });
    // login callback
    window.oauth = {};
    window.oauth.signin = function (data) {
        if (data.state !== nonce) {
            return;
        }
        $('#accessToken').val(data.access_token);
    }
    // open login.html in a new window.
    window.open(uri, 'authorize', 'width=640,height=480');
});
// add query string to uri
function addQueryString(uri, parameters) {
    var delimiter = (uri.indexOf('?') == -1) ? '?' : '&';
    for (var parameterName in parameters) {
        var parameterValue = parameters[parameterName];
        uri += delimiter + encodeURIComponent(parameterName) + '=' + encodeURIComponent(parameterValue);
        delimiter = '&';
    }
    return uri;
}

// login.html
// get fragment and call opener's signin function.
var fragments = getFragment();
if (window.opener && window.opener.oauth && window.opener.oauth.signin) {
    window.opener.oauth.signin(fragments);
}
window.close();

// get fragment from window uri
function getFragment() {
    if (window.location.hash.indexOf("#") === 0) {
        return parseQueryString(window.location.hash.substr(1));
    } else {
        return {};
    }
}
// parse query string to object;
function parseQueryString(queryString) {
    var data = {}, pairs, pair, separatorIndex, escapedKey, escapedValue, key, value;

    if (queryString === null) {
        return data;
    }

    pairs = queryString.split("&");

    for (var i = 0; i < pairs.length; i++) {
        pair = pairs[i];
        separatorIndex = pair.indexOf("=");

        if (separatorIndex === -1) {
            escapedKey = pair;
            escapedValue = null;
        } else {
            escapedKey = pair.substr(0, separatorIndex);
            escapedValue = pair.substr(separatorIndex + 1);
        }

        key = decodeURIComponent(escapedKey);
        value = decodeURIComponent(escapedValue);

        data[key] = value;
    }

    return data;
}
```

## 资源所有者密码凭据授权 (Resource Owner Password Credentials Grant)

[资源所有者密码凭据授权][6]适用于那些被充分信任的应用， 比如设备操作系统或者权限很高的应用。 授权服务器启用这类授权是要格外注意， 只能在其它授权方式不能用的时候才使用这种授权方式。

这种授权方式适用于能够取得用户的凭据 （通常是通过可交互的表单） 的应用， 也可以用于迁移现有的那些需要直接授权 (HTTP Basic 或 Digest ) 的应用， 将保存的用户凭据改为保存访问凭据 (access token) 。

![resource-owner-password-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-3-resource-owner-password-credentials-grant.png)

对于 DotNetOpenAuth 来说， 这种授权也是十分容易实现的， 示例代码如下：

```c#
// create auth server description 
var authServer = new AuthorizationServerDescription {
    AuthorizationEndpoint = new Uri(Paths.AuthorizePath),
    TokenEndpoint = new Uri(Paths.TokenPath)
};
// create web server client
var webServerClient = new WebServerClient(authServer, clientId, clientSecret);
// use user name and password to exchange access token;
var state = webServerClient.ExchangeUserCredentialForToken(
    username, password,
    new[] {"scope1", "scope2", "scope3"}
);
// get access token;
var token = state.AccessToken;
```

## 客户端凭据授权 (Client Credentials Grant)

[客户端凭据授权][7]是指客户端可以只通过客户端自己的凭据 (client_id 和 client_secret) （或者其它方式的认证） 来获取访问凭据， 客户端可以根据自己的需要来访问受保护的资源， 或者资源所有者已经访问过认证服务器时， 才能使用这种授权方式。 只有对完全受信任的客户端才能使用这种授权方式， 因为对受保护的资源方来说， 认证信息的内容是客户端程序的凭据， 而不是资源所有者的凭据。

![client-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-4-client-credentials-grant.png)

DotNetOpenAuth 也支持这种授权方式， 示例代码如下：

```c#
// create auth server description 
var authServer = new AuthorizationServerDescription {
    AuthorizationEndpoint = new Uri(Paths.AuthorizePath),
    TokenEndpoint = new Uri(Paths.TokenPath)
};
// create web server client
var webServerClient = new WebServerClient(authServer, clientId, clientSecret);
// get client access token;
var state = webServerClient.GetClientAccessToken(
  new[] { "test1", "test2", "test3" }
);
// get access token;
var token = state.AccessToken;
```

## 使用访问凭据访问受保护的资源

上面介绍的都是如何取得访问凭据 (access_token) ， 拿到了访问凭据之后如何来使用呢？ 对于使用微软的 OWIN 中间件 [Microsoft.Owin.Security.OAuth][8] 搭建的服务器来说， 需要设置 HTTP 请求的 Authorization 标头为 `Bearer {access_token}` 就可以了， 这个属于 OAuth 的规范之内了， 示例代码如下：

使用 jQuery 的 Ajax 请求时， 示例代码如下：

```js
var accessToken = '@AccessToken';

$.ajax({
    url: '@ResourcePath',
    beforeSend: function(jqr) {
        jqr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
    }
})
.done(function (data) {
    // other code here.
});
```

使用其它语言的代码与上面的 js 代码大同小异，上面只是一些代码片段， 在 github 上有[完整的项目代码][8]， 不清楚的地方可以直接查看源代码。

[1]: http://beginor.github.io/2015/01/24/oauth2-server-with-owin.html
[2]: http://tools.ietf.org/html/rfc6749#section-4.1
[3]: http://dotnetopenauth.net/
[4]: https://www.nuget.org/packages/dotnetopenauth
[5]: http://tools.ietf.org/html/rfc6749#section-4.2
[6]: http://tools.ietf.org/html/rfc6749#section-4.3
[7]: http://tools.ietf.org/html/rfc6749#section-4.4
[8]: https://github.com/beginor/owin-samples