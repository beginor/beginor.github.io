---
layout: post
title: Silverlight CreateObjectEx 参考
description: 详解 Silverlight.js 中的 CreateObjectEx 函数
tags: [Silverlight]
keywords: silverlight, createobject, createobjectex
---

做 Silverlight 开发难免要动态在页面中创建 Silverlight 控件， 需要用到 Silverlight.js 文件中的 CreateObject 或 CreateObjectEx 函数， 一下是 Silverlight.js 文件中的 CreateObjectEx 函数支持的所有参数及其描述， 仅供参考：

    Silverlight.createObjectEx({
       /**
        * The URI of the content or package to load into the Silverlight
        * plug-in. The default is null.
        */
       source: '',
       /**
        * The HTML element in which to insert the generated HTML, or null,
        * to return the generated HTML instead of injecting it.
        */
       parentElement: document.getElementById(''),
       /**
        * The id attribute value of the generated object element.
        */
       id: 'sl-control-id',
       properties: {
          /**
           * true  if the hosted content can use the HtmlPage.PopupWindow
           * method to display a new browser window; otherwise, false. The
           * default is true for same-domain applications and false for
           * cross-domain applications.
           */
          allowHtmlPopupWindow: 'true',
          /**
           * true  if a Silverlight plug-in version earlier than
           * minRuntimeVersion should attempt to update automatically;
           * otherwise, false. The default is true.
           */
          autoUpgrade:'true',
          /**
           * Specifies the background color value as a string. 
           * color value like: Red, #F00, #8F00, #FF0000, #80FF0000,
           * sc#1,0,0, sc#0.5,1,0,0
           */
          background:'white',
          /**
           * indicates whether to use a non-production analysis visualization
           * mode, which shows areas of a page that are not being GPU
           * accelerated with a colored overlay. Do not use in production code.
           */
          enableCacheVisualization: 'false',
          /**
           * whether to use graphics processor unit (GPU) hardware acceleration
           * for cached compositions
           */
          enableGPUAcceleration: 'true',
          /**
           *  whether the hosted content in the Silverlight plug-in and in the
           * associated run-time code has access to the browser Document
           * Object Model (DOM).
           * The default value is true for same-domain applications and false
           * for cross-domain applications.
           */
          enablehtmlaccess: 'true',
          /**
           * A string that is interpreted by the plug-in code, and is expected
           * to be one of the following values:
           * all :
           * the hosted content can use HyperlinkButton to navigate to any
           * URI. This is the default value, and is the acting value if no
           * enableNavigation parameter is specified.
           * none :
           * the hosted content cannot use HyperlinkButton for navigation to
           * an external URI. Relative URIs for internal navigation are still
           * permitted. However, no journal entry is produced.
           */
          enableNavigation: 'all',
          /**
           * An integer value that specifies the maximum number of frames to
            render per second. The default value is 60.
           */
          maxFrameRate: '60',
          /**
           * The version of Silverlight that is required by the application.
           * The default is the currently installed version, or null if
           * Silverlight is not installed.
           */
          minRuntimeVersion: '5.0.0.0',
          /**
           * Specifies the initial width of the Silverlight plug-in area in the
           * HTML page. Can be as a pixel value or as a percentage (a value that
           * ends with the % character specifies a percentage value). For example,
           * "400" specifies 400 pixels, and "50%" specifies 50% (half) of the
           * available width of the browser content area.
           */
          width: '100%',
          /**
           * Specifies the initial height of the Silverlight plug-in area in the
           * HTML page. Can be set either as a pixel value or a percentage (a
           * value that ends with the % character specifies a percentage value).
           * For example, "300" specifies 300 pixels, and "50%" specifies 50% (half)
           * of the available height of the browser content area. 
           */
          height: '100%',
          /**
           * whether the Silverlight plug-in displays as a windowless plug-in.
           * (Applies to Windows versions of Silverlight only.) The default is
           * false.
           */
          windowless: 'false',
          /**
           * The local URI of the content to load as the splash screen source.
           * The default is null.
           */
          splashScreenSource: null
       },
       events: {
          /**
           * The name of the function that is invoked when the Silverlight
           * plug-in generates a parse or run-time error at the native-code
           * level. The default value is null.
           * Arguments for an OnError Function:
           * sender The Silverlight plug-in that invoked the event.
           * errorEventArgs: The error and its source location. 
           */
          onError: errorHandler,
          /**
           * Specifies the handler for a FullScreenChanged event that occurs
           * whenever the FullScreen property of the Silverlight plug-in changes.
           * Arguments for a FullScreenChanged Event Handler Function: 
           * sender: The Silverlight plug-in that raised the event.
           * args: Always null.
           */
          onLoad: loadHandlername,
          /**
           * Specifies a handler for the Resized event that occurs when the
           * Silverlight plug-in's object tag is resized and the ActualHeight
           * or the ActualWidth of the Silverlight plug-in change.
           * Arguments for a Resized Event Handler Function:
           * sender: The Silverlight plug-in that raised the event.
           * args: Always null.
           */
          onResize: resizeHandler,
          /**
           * The name of the function that is invoked when the source download
           * has finished. The default value is null.
           * Arguments for an OnSourceDownloadCompleted Function
           * sender: The Silverlight plug-in that raised the event.
           * args: Always null.
           */
          onSourceDownloadComplete: sourceDownloadCompletedHandler,
       },
       /**
        * A string that represents a set of user-defined initialization parameters.
        * The format of the value can be user-defined. The default value is null or     * an empty string.
        * A string like: name1=value1,name2=value2,name3=value3
        */
       initParams: '',
       /**
       * A value passed to your onLoad event handler
       */
       context: null
    });
