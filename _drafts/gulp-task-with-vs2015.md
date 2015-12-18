---
layout: post
title: 在 VS 2015 中使用 Gulp 编译 TypeScript
description: 介绍在 VS 2015 中使用 Gulp 即时编译 TypeScript
keywords: gulp, vs2015, gulp.watch
tags: [Gulp]
---

升级到 VS2015 之后， TypeScript 文件不能自动编译成 js 文件， 要编译项目才能讲所有的 ts 文件 编译成 js 文件， 不过 VS2015 支持 Gulp ， 而 Gulp 有 TypeScript 插件， 这样使用 Gulp 自动编译 ts 文件的方法就可以实现了。

假设项目结构如下：

![项目结构](/assets/post-images/type-script-project-structure.png)

我们要把 `app` 目录下的 ts 文件编译到 `wwwroot/app` 目录下， 使用 Gulp 的做法是这样的：

1、 添加 `gulp` 和 `gulp-typescript` NPM 包

打开 `package.json` ， 在 `devDependencies` 节点下添加：

```json
{
    "devDependencies": {
        "gulp": "^3.9.0",
        "gulp-typescript": "^2.10.0",
        "typescript": "^1.7.5"
    }
}
```

保存文件， VS 会自动下载相应的 NPM 包;

2、 定义编译 ts 任务

打开 `gulpfile.js` ， 定义一个 `tsc` 任务来编译 ts 文件， 代码如下：

```javascript
var gulp = require('gulp');
var ts = require('gulp-typescript');

gulp.task('tsc', function () {
    gulp.src('app/**/*.ts')
        .pipe(ts())
        .pipe(gulp.dest('wwwroot/app'));
});
```

现在在 `Task Runner Explorer` 就能看到这个名称为 `tsc` 的任务了， 运行一下， 果然在 `wwwroot/app` 目录下生成了对应的 js 文件， 前进了一大步；

3、 实现自动编译

但是每次都运行这个任务还是太麻烦了， 我们的目标是能够自动编译 ts 文件， 这就需要使用 `gulp.watch` 了， 当 app 目录发生变化时， 就调用上面的 `tsc` 编译一下， 我们的目的就达到了， 接下来再定义一个 `tsc:w` 任务， 来实现这个目标：

```javascript
gulp.task('tsc:w', ['tsc'], function () {
    gulp.watch('app/**/*.ts', ['tsc']);
});
```

这代码也太简单了， 监控 `app` 目录下面的所有 ts 文件， 有变化就调用 `tsc` 任务， 不用怎么解释了。

4、 调用 TypeScript 配置文件

项目中一般都会有一个 `tsconfig.json` 的配置文件， 我们还需要读取这个文件， 需要稍微修改一下上面的 `tsc` 任务， 先读取 `tsconfig.json` 文件：

```javascript
var gulp = require('gulp');
var ts = require('gulp-typescript');
var tsProj = ts.createProject('tsconfig.json');

gulp.task('tsc', function () {
    var tsResult = gulp.src('app/**/*.ts')
        .pipe(ts(tsProj))
        .pipe(gulp.dest('wwwroot/app'));
});
```

现在运行 `tsc:w` 任务， 可以看到下面的输出：

![](/assets/post-images/run-tsc-w-in-vs-2015.png)

修改 app 目录下的 ts 文件并保存， 可以看到输出如下：

![](/assets/post-images/run-tsc-w-in-vs-2015-2.png)

自动编译 ts 文件的目的算是达到了！

最终的 gulpfile.js 内容如下：

```javascript
var gulp = require('gulp');
var ts = require('gulp-typescript');
var tsProj = ts.createProject('tsconfig.json');

gulp.task('tsc', function () {
    var tsResult = gulp.src('app/**/*.ts')
        .pipe(ts(tsProj))
        .pipe(gulp.dest('wwwroot/app'));
});

gulp.task('tsc:w', ['tsc'], function () {
    gulp.watch('app/**/*.ts', ['tsc']);
});
```


