---
layout: post
title: 从 OAuth2 服务器获取认证授权
description: 本文介绍 OAuth2 定义的四种授权方式及其对应的实现方式
tags: [OAuth2, OWIN, WebAPI]
keywords: OWIN, OAuth2, ASP.NET MVC, WebAPI, code, access_token, 
---

搭建好了[基于 OWIN 的 OAuth2 服务器][1]之后， 接下来就是如何从服务器取得授权了， 下面就介绍如何实现 OAuth2 定义的四种授权方式。

## 认证码授权 (Authorization Code Grant)

[认证码授权][2]针对机密的客户端优化， 可以同时获取访问凭据 (access token) 和刷新凭据 (refresh token) ， 因为是基于 HTTP 重定向的方式， 所以客户端必须能够操纵资源所有者的用户代理（通常是浏览器）并且能够接收从认证服务器重定向过来的请求。

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

因为是基于 HTTP 重定向的方式， 所以客户端必须能够操纵资源所有者的用户代理（通常是浏览器）并且能够接收从认证服务器重定向过来的请求。

与认证码授权方式不同的是， 客户端不需要为认证和访问凭据分别发送单独的请求， 可以直接从认证请求获取访问凭据。

隐式授权不包括客户端认证， 依赖资源所有者（用户）的现场判断以及客户端重定向地址， 由于访问凭据是在 URL 中编码的， 所以有可能会暴漏给用户或客户端上的其它应用。

![implicit-grant](http://beginor.github.io/assets/post-images/oauth2-2-implicit-grant.png)

由于这种认证方式一般是通过浏览器实现的， 所以就不用依赖 DotNetOpenAuth 了， 只需要 Javascript 就行了， 示例代码如下：

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

## Resource Owner Password Credentials Grant

   The resource owner password credentials grant type is suitable in
   cases where the resource owner has a trust relationship with the
   client, such as the device operating system or a highly privileged
   application.  The authorization server should take special care when
   enabling this grant type and only allow it when other flows are not
   viable.

   This grant type is suitable for clients capable of obtaining the
   resource owner's credentials (username and password, typically using
   an interactive form).  It is also used to migrate existing clients
   using direct authentication schemes such as HTTP Basic or Digest
   authentication to OAuth by converting the stored credentials to an
   access token.

![resource-owner-password-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-3-resource-owner-password-credentials-grant.png)

   (A)  The resource owner provides the client with its username and
        password.

   (B)  The client requests an access token from the authorization
        server's token endpoint by including the credentials received
        from the resource owner.  When making the request, the client
        authenticates with the authorization server.

   (C)  The authorization server authenticates the client and validates
        the resource owner credentials, and if valid, issues an access
        token.

## Client Credentials Grant

   The client can request an access token using only its client
   credentials (or other supported means of authentication) when the
   client is requesting access to the protected resources under its
   control, or those of another resource owner that have been previously
   arranged with the authorization server (the method of which is beyond
   the scope of this specification).

   The client credentials grant type MUST only be used by confidential
   clients.

![client-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-4-client-credentials-grant.png)

   (A)  The client authenticates with the authorization server and
        requests an access token from the token endpoint.

   (B)  The authorization server authenticates the client, and if valid,
        issues an access token.

[1]: http://beginor.github.io/2015/01/24/oauth2-server-with-owin.html
[2]: http://tools.ietf.org/html/rfc6749#section-4.1
[3]: http://dotnetopenauth.net/
[4]: https://www.nuget.org/packages/dotnetopenauth
[5]: http://tools.ietf.org/html/rfc6749#section-4.2