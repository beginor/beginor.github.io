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

```c#
// Sample code.
```

## Implicit Grant

   The implicit grant type is used to obtain access tokens (it does not
   support the issuance of refresh tokens) and is optimized for public
   clients known to operate a particular redirection URI.  These clients
   are typically implemented in a browser using a scripting language
   such as JavaScript.

   Since this is a redirection-based flow, the client must be capable of
   interacting with the resource owner's user-agent (typically a web
   browser) and capable of receiving incoming requests (via redirection)
   from the authorization server.

   Unlike the authorization code grant type, in which the client makes
   separate requests for authorization and for an access token, the
   client receives the access token as the result of the authorization
   request.

   The implicit grant type does not include client authentication, and
   relies on the presence of the resource owner and the registration of
   the redirection URI.  Because the access token is encoded into the
   redirection URI, it may be exposed to the resource owner and other
   applications residing on the same device.

![implicit-grant](http://beginor.github.io/assets/post-images/oauth2-2-implicit-grant.png)

<div class="alert alert-warning">
<b>Note:</b> The lines illustrating steps (A) and (B) are broken into two parts as they pass through the user-agent.
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
        redirection URI provided earlier.  The redirection URI includes
        the access token in the URI fragment.

   (D)  The user-agent follows the redirection instructions by making a
        request to the web-hosted client resource (which does not
        include the fragment per [RFC2616]).  The user-agent retains the
        fragment information locally.

   (E)  The web-hosted client resource returns a web page (typically an
        HTML document with an embedded script) capable of accessing the
        full redirection URI including the fragment retained by the
        user-agent, and extracting the access token (and other
        parameters) contained in the fragment.

   (F)  The user-agent executes the script provided by the web-hosted
        client resource locally, which extracts the access token.

   (G)  The user-agent passes the access token to the client.

```c#
// sample code
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
