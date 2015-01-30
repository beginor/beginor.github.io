---
layout: post
title: 从 OAuth2 服务器获取认证授权
description: 本文介绍 OAuth2 定义的四种授权方式及其对应的实现方式
tags: [OAuth2, OWIN, WebAPI]
keywords: OWIN, OAuth2, ASP.NET MVC, WebAPI, code, access_token, 
---

## 认证码授权 (Authorization Code Grant)

The authorization code grant type is used to obtain both access
tokens and refresh tokens and is optimized for confidential clients.
Since this is a redirection-based flow, the client must be capable of
interacting with the resource owner's user-agent (typically a web
browser) and capable of receiving incoming requests (via redirection)
from the authorization server.

![authorization-code-grant](http://beginor.github.io/assets/post-images/oauth2-1-authorization-code-grant.png)

<div class="alert alert-warning">
<b>Note: </b> Note: The lines illustrating steps (A), (B), and (C) are broken into two parts as they pass through the user-agent.
</div>

   (A)  The client initiates the flow by directing the resource owner's
        user-agent to the authorization endpoint.  The client includes
        its client identifier, requested scope, local state, and a
        redirection URI to which the authorization server will send the
        user-agent back once access is granted (or denied).

   (B)  The authorization server authenticates the resource owner (via
        the user-agent) and establishes whether the resource owner
        grants or denies the client's access request.

   (C)  Assuming the resource owner grants access, the authorization
        server redirects the user-agent back to the client using the
        redirection URI provided earlier (in the request or during
        client registration).  The redirection URI includes an
        authorization code and any local state provided by the client
        earlier.

   (D)  The client requests an access token from the authorization
        server's token endpoint by including the authorization code
        received in the previous step.  When making the request, the
        client authenticates with the authorization server.  The client
        includes the redirection URI used to obtain the authorization
        code for verification.

   (E)  The authorization server authenticates the client, validates the
        authorization code, and ensures that the redirection URI
        received matches the URI used to redirect the client in
        step (C).  If valid, the authorization server responds back with
        an access token and, optionally, a refresh token.

## Implicit Grant

![implicit-grant](http://beginor.github.io/assets/post-images/oauth2-2-implicit-grant.png)

## Resource Owner Password Credentials Grant

![resource-owner-password-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-3-resource-owner-password-credentials-grant.png)

## Client Credentials Grant

![client-credentials-grant](http://beginor.github.io/assets/post-images/oauth2-4-client-credentials-grant.png)