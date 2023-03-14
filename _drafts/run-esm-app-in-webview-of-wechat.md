---
layout: post2
title: 在微信的 Webview 中运行 ES 模块化的 Web 应用
description: 介绍在微信的 Webview 中运行 esm 应用时遇到的坑，以及填坑的过程。
keywords: wexin, wechat, webview, esm, es mudule, polyfill, top-level await, es-module-shims, structuredClone
tags: [前端, 参考]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

最近打算在微信上写点儿 Web 应用， 想法很简单， 就是通过微信直接发送地址， 在微信的 Webview 中直接运行，不安装。

想法是好的， 然而没想到的是现在 (2023 年 3 月) 微信的 Webview 的版本居然还是 Chrome/86 ， 而当前主流的版本已经是 Chrome/110 了， 差了 20 多个版本， 于是忍不住在 V2EX 发了一片吐槽的帖子： [2023 年又发现了一个 "IE6" ，那就是安卓版微信内置的 Webview](https://www.v2ex.com/t/918931) ， 得到了好多网友的回复。

> 更加没想到的是， 支付宝/钉钉等阿里系软件内嵌的 Webview 居然更低的 Chrome/69 ， 这么一比较， 微信的 Chrome/86 还算比较新的了。

吐槽完了， 活儿还是要做的， 只能自己去适配微信内置的 Chrome/86 版本的 Webview 。

由于一直是桌面端的 Web 开发， 所以就使用了一些比较新的 ES 标准， 在主流的浏览器 (Chrome/108+) 上没有任何问题， 突然要针对微信的 Chrome/86 做开发， 遇到主要问题是：

- 不支持 [Import maps](https://caniuse.com/import-maps) ， 这个需要 Chrome/89 以上；
- 不支持 [Top level await](https://caniuse.com/mdn-javascript_operators_await_top_level) , 这也也需要 Chrome/89 以上；
- 不支持 [import.meta.resolve](https://caniuse.com/mdn-javascript_operators_import_meta_resolve) , 这个需要 Chrome/105 以上；
- 不支持 [structuredClone](https://caniuse.com/mdn-api_structuredclone) 等一些现代化的 JavaScript API ；

> 更多差异请参考这里的比较 <https://caniuse.com/?compare=chrome+87,chrome+110&compareCats=all>

最主要的问题是不支持 `Import maps` ， 就不能很好的使用 ES 模块化的代码， 但是也不能降级， 因为项目中大量用到了 `import.meta.url` ， 比如自带样式的组件， 降级的话又得想办法实现这个， 相当于自己又给自己挖了个不知深浅的坑， 看起来似乎无解了。

不过， 不得不感谢伟大的 Google 和 GitHub ， 在一筹莫展之际， 我发现了 [ES Module Shims](https://github.com/guybedford/es-module-shims) 这个库， 可在所有支持基本ES模块的浏览器中使用， 通过它可以为 `Chrome/61` 以上的浏览器提供几乎完整的 ES 模块化支持， 这简直就是我的大救星啊， 虽然性能肯定会比原生差一些， 但是至少能用啊 ！！！

剩下的问题都容易解决：

- `Top level await` 不支持， 需要浏览器内核支持， 这个可以改；
- `structuredClone` 不支持， 这个可以用 JSON 序列化再反序列化顶着用；
- 至于其它的样式问题都是小问题， 项目中使用了基于 bootstrap 的 tabler ，至少看起来没什么太大的问题。

最终， 借助于 `es-module-shims` ， 终于在微信的 Chrome/86 的 Webview 中运行起来了。 后续肯定还有很多坑要填， 至少现在可以起步了。

前面提到的吐槽贴也在几天之后得到了一个算是半官方的回复：

> LeRuin： 安卓微信 107 很快就会全覆盖的，如果你是小程序开发者，可以优先体验最新版本内核，下个版本也已经在准备了。
> <https://www.v2ex.com/t/918931#r_12781080>

不过， 遗憾的是， 就算是微信更新到了 Chrome/107 ， 也不支持 [Small, Large, and Dynamic viewport units](https://caniuse.com/viewport-unit-variants) 。
