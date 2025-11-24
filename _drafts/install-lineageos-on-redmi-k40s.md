---
layout: post2
title: 在 Redmi K40S 上安装 LineageOS 记录
description: 本文记录如何解锁 Redmi K40S 以及安装 LineageOS。
keywords: redmi k40, unlock bootloader, lineageos, hypersploit
tags: [参考, Android]
typora-root-url: ../
typora-copy-images-to: ../assets/post-images
---

![红米 K40S](/assets/post-images/20251120225153.png)

手上的红米 K40S 已经服役了 3 年多， 从 MIUI 12 升级到 MIUI 13， 再到现在的 HyperOS 1.0 (Android 14)， 官方的系统支持肯定是结束了， 在更换手机或者转为备用机之前，还想继续折腾一下， 当然也有其它几个方面的原因，一并说明如下：

1. 官方系统停止更新，止步于 HyperOS 1.0 (Android 14)；
2. 官方系统臃肿， 而且广告很多， 而且有些广告还去不掉；
3. 安装第三方 apk ， 时不时跳出验证， 体验非常糟糕；
4. LineageOS 官方支持 [K40S](https://wiki.lineageos.org/devices/munch/)， 目前是 LineageOS 22.2 (Android 15) ， 很大可能也会有 LineageOS 23 (Android 16) ；
5. 时隔多年想再体验下类原生安卓系统；

鉴于以上几点原因， 准备将 K40S 解锁并安装 LineageOS 。

## 解锁 Bootloader

现在小米刷类原生安卓系统最大的障碍就是解锁 Bootloader ，随着 HyperOS 的发布， 小米旗下机型解锁的难度越来越高， 令不少人都望而却步。 不出意外， 这部 K40S 将是我的最后一部小米手机， 后续机型不能解锁 Bootloader 的话， 将不会再购买小米的任何手机。

> 引用 GitHub 上大佬 MlgmXyysd 的话，那就是： 自从小米限制解锁 BootLoader 后，小米就一直在违背"极客"精神，甚至违背了 GPL。 [原文链接](https://github.com/MlgmXyysd/Xiaomi-HyperOS-BootLoader-Bypass/blob/master/docs/README-zh.md)

幸好， 在 github 上有一些开源的项目可以绕过小米 HyperOS 对 BootLoader 解锁账户绑定限制社区等级的 PoC ， 它们是：

- [Xiaomi-HyperOS-BootLoader-Bypass](https://github.com/MlgmXyysd/Xiaomi-HyperOS-BootLoader-Bypass)
- [HyperSploit](https://github.com/TheAirBlow/HyperSploit)

只要出厂是 MIUI 的手机， 一般都可以借助这两个软件成功解锁。 比较了这两个软件， 我选择的是 HyperSploit ， 因为使用起来更加简单， 不用折腾 PHP 。

解锁的过程很顺利， 简单罗列如下：

1. 需要一台 Windows 电脑， 安装小米官方的手机驱动程序；
2. 打开 ADB 调试模式并授权电脑调试；
3. 开发者模式界面根据提示绑定账号；
4. 运行 HyperSploit ，根据提示进行操作即可；

> 虽然 HyperSploit 有 macOS 版本， 我尝试了一下，没有达到预期目标， 只好用另一台 Windows 电脑进行操作。

具体可以查看[这里](https://github.com/MlgmXyysd/Xiaomi-HyperOS-BootLoader-Bypass/blob/master/docs/README-zh.md)的 `前置要求` 和 `使用教程` ， 这两个软件的用法基本上是相同的。

幸运的是， 我的小米帐号没有被封控， 绑定到 K40S 之后， 只要等7天就可以顺利解锁。

![unlock](/assets/post-images/20251120232338.png)

![unlock success](/assets/post-images/20251120232405.png)

解锁成功之后， 就可以开始安装 LineageOS 了。

## 安装 LineageOS

### 升级固件版本

在正式安装 LineageOS 之前，需要确认手机的固件版本， 如果不是最新版的话， 需要先升级到最新版， 否则安装 LineageOS 可能会失败。 目前 LineageOS 支持的 K40S 固件版本为 [OS1.0.2.0.ULMCNXM](https://cdnorg.d.miui.com/OS1.0.2.0.ULMCNXM/miui_MUNCH_OS1.0.2.0.ULMCNXM_6438305cc0_14.0.zip) ，如果是这个版本的话， 可以根据 LineageOS 的[固件升级指南](https://wiki.lineageos.org/devices/munch/fw_update/variant2/)升级下固件。

> 所谓的固件 (Firmware) 也就是手机硬件的驱动程序， LineageOS 依赖官方镜像的固件驱动程序才能正常运行。

我记得以前的固件是直接包含在 LineageOS 固件中的， 现在不知什么原因，需要单独下载了，不过这些对于要刷机的人来说， 根本都不是事儿。

刷固件相当于装驱动， 对手机内的数据没有任何影响，因此可以放心刷， 步骤如下：

#### 下载官方镜像

- 从 MIUI 官方网站下载 K40S 的完整安装镜像 [OS1.0.2.0.ULMCNXM](https://cdnorg.d.miui.com/OS1.0.2.0.ULMCNXM/miui_MUNCH_OS1.0.2.0.ULMCNXM_6438305cc0_14.0.zip)
- 下载完成之后得到的文件为 `miui_MUNCH_OS1.0.2.0.ULMCNXM_6438305cc0_14.0.zip`

#### 提取固件

使用 [payload-dumper-go](https://github.com/ssut/payload-dumper-go/releases/latest) 提取所需的固件

```sh
payload-dumper-go -o . miui_MUNCH_OS1.0.2.0.ULMCNXM_6438305cc0_14.0.zip
```

可以提取出许多 img 文件， 下一步用到。

#### Fastboot 模式刷固件

将手机关机， 然后按住 `音量减` + `电源` 按钮开机， 进入 Fastboot 模式， 然后使用下面的命令刷入固件：

```sh
fastboot flash abl_ab abl.img
fastboot flash aop_ab aop.img
fastboot flash bluetooth_ab bluetooth.img
fastboot flash cmnlib_ab cmnlib.img
fastboot flash cmnlib64_ab cmnlib64.img
fastboot flash devcfg_ab devcfg.img
fastboot flash dsp_ab dsp.img
fastboot flash featenabler_ab featenabler.img
fastboot flash hyp_ab hyp.img
fastboot flash imagefv_ab imagefv.img
fastboot flash keymaster_ab keymaster.img
fastboot flash modem_ab modem.img
fastboot flash qupfw_ab qupfw.img
fastboot flash tz_ab tz.img
fastboot flash uefisecapp_ab uefisecapp.img
fastboot flash xbl_ab xbl.img
fastboot flash xbl_config_ab xbl_config.img
```

如果一切正常， 重启手机即可。

#### 下载 LineageOS

经过前面的解锁和固件更新，终于可以开始安装 LineageOS 了。 从 LineageOS 的网站下载最新的 K40S 的[安装镜像](https://download.lineageos.org/devices/munch/builds) ， 目前的版本是 `lineage-22.2-20251117-nightly-munch-signed.zip` ， 文件需要的文件列表为：

- [lineage-22.2-20251117-nightly-munch-signed.zip](https://mirrorbits.lineageos.org/full/munch/20251117/lineage-22.2-20251117-nightly-munch-signed.zip)
- [boot.img](https://mirrorbits.lineageos.org/full/munch/20251117/boot.img)
- [dtbo.img](https://mirrorbits.lineageos.org/full/munch/20251117/dtbo.img)
- [super_empty.img](https://mirrorbits.lineageos.org/full/munch/20251117/super_empty.img)
- [vbmeta.img](https://mirrorbits.lineageos.org/full/munch/20251117/vbmeta.img)
- [vendor_boot.img](https://mirrorbits.lineageos.org/full/munch/20251117/vendor_boot.img)

#### 刷写启动 (boot) 分区 和 恢复 (recovery) 分区

再次将手机重启到 Fastboot 模式， 用下面的命令来刷写启动分区：

```sh
fastboot flash boot boot.img
```

刷写启动分区之后， 可以保证恢复 (Recovery) 分区正常工作， 接下来刷写恢复分区：

```sh
fastboot flash vendor_boot vendor_boot.img
```

#### 在恢复模式下清空数据

刷写恢复分区完成之后， 启动到恢复模式：

```sh
fastboot reboot recovery
```

在恢复模式下， 选择 `Factory Reset` ，然后 `Format data / factory reset` 清空全部数据 。

> 重要数据一定要记得提前备份！！！

#### 刷入 LineageOS 系统镜像

在恢复模式下， 选择 `Apply Update` -> `Apply from ADB` ， 然后在电脑上执行下面的命令刷入 LineageOS 系统镜像：

```sh
adb -d sideload lineage-22.2-20251117-nightly-munch-signed.zip
```

> 通常情况下，adb 会报告 Total xfer: 1.00x ，但在某些情况下，即使进程成功，输出可能会停在 47%并显示 adb: failed to read command: Success 。在其他情况下，它可能会显示 adb: failed to read command: No error 或 adb: failed to read command: Undefined error: 0 ，这也是可以的。

刷完 LineageOS 系统镜像之后， 先不要重启手机， 接下来再刷入谷歌服务， 如果不需要谷歌服务的话， 则不需要这一步。

## 安装谷歌服务

从 [MindTheGapps](https://github.com/MindTheGapps/15.0.0-arm64/releases/latest) 下载谷歌服务安装包， 目前的版本是 `MindTheGapps-15.0.0-arm64-20250812_214357.zip` ， 用 `adb sideload` 命令刷入：

```sh
adb -d sideload MindTheGapps-15.0.0-arm64-20250812_214357.zip
```

> 手机会提示签名不正确， 这是正常的， 因为 MindTheGapps 没有使用 LineageOS 的签名。

现在可以重启手机， 启动全新的 LineageOS 系统了。

<table>
  <tr>
    <td>
      <img alt="" src="/assets/post-images/20251124225810.png" />
    </td>
    <td>
      <img alt="" src="/assets/post-images/20251124225936.png" />
    </td>
  </tr>
</table>

## 与原版 HyperOS 的对比

### 感觉比较舒服的几点

- LineageOS 非常简洁， 完全无广告， 这一点足可以把 HyperOS 以及国内一众魔改安卓系统钉死在耻辱柱上；
- LineageOS 体积很小， 大概只有 HyperOS 的 1/3 到一半， 运行起来也非常的轻快， 感觉很流畅；
  > 不排除是 LineageOS 动画时间短的原因；
- 可以 **随意** 安装 apk 文件， 不用担心弹出密码认证甚至短信/刷脸认证；
- 肯定不用担心计划性报废， 因为 LineageOS 是开源的， 越升级越流畅， 至少 LineageOS 系统本身是这样的；
- 没有 HyperOS 那些令人厌恶的后台服务， 包括但不限于 `快应用` 、`手机管家` 等无法关闭的后台服务；
- 显示刷新率有 3 档， 分别是 60Hz、90Hz、120Hz ， 比 HyperOS 多了 90Hz 一档， 而且还可以选择 `流畅画面` (自动将某些内容的刷新频率提高到 120Hz ， 主要是动画和过渡)；
- 谷歌输入法 Gboard 终于适配底部的导航栏了， 比在原生系统上舒服很多， 原生 HyperOS 简直就是故意恶心谷歌输入法；
- 从 Play 市场下载的软件 (包括微信、QQ、 淘宝、 京东、 高德地图等) 在存储卡上乱拉屎的情况都已经没有了， 在应用属性页的电量管理中禁止后台之后也基本不会作妖了， 反观从 HyperOS 市场下载的软件， 简直都是垃圾；
- 可以在 `设置` -> `电池` 页面为安装的每个应用设置温控策略， 而不必安装什么游戏助手之类的额外软件；

### 感觉比较遗憾的几点

- 工作日闹钟： LineageOS 是类原生系统， 没有国内系统定制的工作日闹钟是最遗憾的一个功能， 而且好像还找不到替代品；
- NFC门禁卡： HyperOS 有小米钱包， 可以复制小区的门禁卡， 这个在 LineageOS 上暂时没有找到替代品， 这手机的 NFC 我就不知道还有啥用了；
- 天气预报： HyperOS 的天气预报功能还是很贴心的， 不过装了谷歌的服务之后， 也有基于位置的天气预报，虽然没有那么及时， 但是凑合也能用；

### 意外惊喜

最后还有一个意外的惊喜， 那就是支持游戏手柄震动； 原来的 HyperOS 是基于 Android 14 的， 不支持手柄震动。 安装 LineageOS 之后，系统也升级到了 Android 15 ， 在使用手柄时突然发现可以震动了， 游戏手感可以说是上升了一个档次， 算是最意外的惊喜吧。
