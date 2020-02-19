---
layout: post2
title: 手工将项目升级至 Angular 9 记录
description: 记录如何将项目升级至 Angular 9 
keywords: angular, upgrade, angular9
tags: [Angular]
---

Angular 最近发布了 9.0 版本， 需要先将一个模板项目升级至新版本。 虽然它提供了 `ng update` 命令来升级， 但是这个命令会自动调整 package.json 文件依赖项的顺序， 导致向其它项目合并时产生不必要的冲突。 为了不打乱现有的依赖项的顺序， 容易向其它派生项目进行合并， 同时也能明确知道究竟那些文件需要修改， 因此采用手工升级的办法。

项目结构采用 angular-cli 创建的的多项目架构， `web` 是一个应用， `app-shared` 是类库。

```
- angular.json
- package.json
- tsconfig.json
- tslint.json
- projects/
--+ app-shared/
--+ web/
```

## package.json

依赖项 (dependencies) 升级， 将 Angular 的 npm 包 `@angular/*` 包版本升级为 `~9.0.0` ， 以及其相关 npm 包的升级：

```diff
{
  "dependencies": {
-    "@angular/animations": "~8.2.14",
+    "@angular/animations": "~9.0.0",
-    "@angular/common": "~8.2.14",
+    "@angular/common": "~9.0.0",
-    "@angular/compiler": "~8.2.14",
+    "@angular/compiler": "~9.0.0",
-    "@angular/core": "~8.2.14",
+    "@angular/core": "~9.0.0",
-    "@angular/forms": "~8.2.14",
+    "@angular/forms": "~9.0.0",
-    "@angular/platform-browser": "~8.2.14",
+    "@angular/platform-browser": "~9.0.0",
-    "@angular/platform-browser-dynamic": "~8.2.14",
+    "@angular/platform-browser-dynamic": "~9.0.0",
-    "@angular/router": "~8.2.14",
+    "@angular/router": "~9.0.0",
-    "rxjs": "~6.4.0",
+    "rxjs": "~6.4.0",
-    "tslib": "^1.10.0",
+    "tslib": "^1.10.0",
-    "zone.js": "~0.9.1",
+    "zone.js": "~0.9.1"
  }
}
```

开发依赖项 (devDependencies) ，可以看到， 几乎所有的开发依赖项都是大版本更新。

```diff
{
  "devDependencies": {
-    "@angular-devkit/build-angular": "~0.803.21",
+    "@angular-devkit/build-angular": "~0.900.1",
-    "@angular-devkit/build-ng-packagr": "~0.803.21",
+    "@angular-devkit/build-ng-packagr": "~0.900.1",
-    "@angular/cli": "~8.3.21",
+    "@angular/cli": "~9.0.1",
-    "@angular/compiler-cli": "~8.2.14",
+    "@angular/compiler-cli": "~9.0.0",
-    "@angular/language-service": "~8.2.14",
+    "@angular/language-service": "~9.0.0",
-    "@types/node": "~8.9.4",
+    "@types/node": "^12.11.1",
-    "@types/jasmine": "~3.3.8",
+    "@types/jasmine": "~3.5.0",
    "@types/jasminewd2": "~2.0.3",
-    "codelyzer": "^5.0.0",
+    "codelyzer": "^5.1.2",
-    "jasmine-core": "~3.4.0",
+    "jasmine-core": "~3.5.0",
    "jasmine-spec-reporter": "~4.2.1",
-    "karma": "~4.1.0",
+    "karma": "~4.3.0",
-    "karma-chrome-launcher": "~2.2.0",
+    "karma-chrome-launcher": "~3.1.0",
-    "karma-coverage-istanbul-reporter": "~2.0.1",
+    "karma-coverage-istanbul-reporter": "~2.1.0",
    "karma-jasmine": "~2.0.1",
-    "karma-jasmine-html-reporter": "^1.4.0",
+    "karma-jasmine-html-reporter": "^1.4.2",
-    "ng-packagr": "^5.4.0",
+    "ng-packagr": "^9.0.0",
-    "protractor": "~5.4.0",
+    "protractor": "~5.4.3",
-    "ts-node": "~7.0.0",
+    "ts-node": "~8.3.0",
-    "tsickle": "^0.37.0",
-    "tslint": "~5.15.0",
+    "tslint": "~5.18.0",
-    "typescript": "~3.5.3"
+    "typescript": "~3.7.5"
  }
}
```

`@types/node` 升级为 `^12.11.1` ， 所以建议将本机的 nodejs 也升级为 v12 版本。

## angular.json

Angular 9 默认采用 ivy 引擎， 所以应用项目 (web) 的 build 选项需要打开 aot 编译。

类库项目 (app-shared) 也增加了 production 配置

```diff
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "projects": {
    "web": {
      "architect": {
        "build": {
          "options": {
            "polyfills": "projects/web/src/polyfills.ts",
            "tsConfig": "projects/web/tsconfig.app.json",
-            "aot": false,
+            "aot": true,
             "assets": [
              "projects/web/src/favicon.ico",
              "projects/web/src/assets"
            ],
          },
          "configurations": {
            "production": {
-              "aot": true,
            }
          }
        }
      }
    },
    "app-shared": {
      "architect": {
        "build": {
          "options": {
              "tsConfig": "projects/app-shared/tsconfig.lib.json",
              "project": "projects/app-shared/ng-package.json"
-          }
+          },
+          "configurations": {
+            "production": {
+              "tsConfig": "projects/app-shared/tsconfig.lib.prod.json"
+            }
+          }
        }
      }
    }
  }
}
```
## tsconfig.json

精简了 compilerOptions:paths 的设置。

```diff
{
  "compilerOptions": {
    "paths": {
      "app-shared": [
+        "dist/app-shared/app-shared",
        "dist/app-shared"
-      ],
+      ]
-      "app-shared/*": [
-        "dist/app-shared/*"
-      ]
    }
  }
}
```

## projects/web/tsconfig.app.json

简化了 include 以及 exclude 配置。

```diff
{
  "include": [
-    "src/**/*.ts"
+    "src/**/*.d.ts"
-  ],
-  "exclude": [
-    "src/test.ts",
-    "src/**/*.spec.ts"
  ]
}
```

## projects/web/src/test.ts

对 require 进行了精确的定义。

```diff
- declare const require: any;
+ declare const require: {
+     context(path: string, deep?: boolean, filter?: RegExp): {
+         keys(): string[];
+         <T>(id: string): T;
+     };
+ };
```

## projects/web/src/polyfills.ts

Angular 9 的 localize 引入了一些变化， 需要导入 `@angular/localize/init` 文件， 如果没有使用 `@angular/localize` ， 则不需要修改。

```diff
import 'zone.js/dist/zone';  // Included with Angular CLI.

+ import '@angular/localize/init';

```

## projects/web/src/main.ts

如果使用了 @angular/localize 才需要做修改， 否则不用修改。

```diff
if (environment.production) {
    enableProdMode();
}

- registerLocaleData(zhHans, zhHansEx);
+ registerLocaleData(zhHans, 'zh-Hans', zhHansEx);
```

## projects/app-shared/package.json

对等依赖项 peerDependencies 升级至 `^9.0.0` ， 增加了对 `tslib:^1.10.0` 的对等依赖.

```diff
{
  "name": "app-shared",
  "version": "0.0.1",
  "peerDependencies": {
-    "@angular/common": "^8.2.14",
+    "@angular/common": "^9.0.0",
-    "@angular/core": "^8.2.14"
+    "@angular/core": "^9.0.0",
+    "tslib": "^1.10.0"
  }
}
```

## projects/app-shared/tsconfig.lib.json

精简了一些 Angular 编译器选项。

```diff
{
  "angularCompilerOptions": {
-    "annotateForClosureCompiler": true,
    "skipTemplateCodegen": true,
    "strictMetadataEmit": true,
-    "fullTemplateTypeCheck": true,
-    "strictInjectionParameters": true,
    "enableResourceInlining": true
  }
}
```

## projects/app-shared/tsconfig.lib.prod.json

这个文件是新增加的， 也就是意味着可以使用 `--prod` 选项来编译 Angular 类库项目。

```diff
+ {
+   "extends": "./tsconfig.lib.json",
+   "angularCompilerOptions": {
+     "enableIvy": false
+   }
+ }
```
