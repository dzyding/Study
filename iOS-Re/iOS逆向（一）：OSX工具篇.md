这篇文章主要是笔者读逆向小黄书的笔记，由于书有点老了所以很多工具的安装和使用都有不少改动，笔者踩完坑也就顺便记录一下。

# class-dump
## 安装
书中所写是在`/usr/bin`安装，由于现在一般在该目录没有权限，无法把`class-dump`文件移动到该目录。以下方法安装在了另一个目录：

1. 打开Terminal，输入`mkdir ~/bin`，在当前用户根目录下创建一个bin目录；  
2. 把class-dump给拷贝到这个目录里，并赋予其可执行权限：`mv /path/to/class-dump ~/bin; chmod +x ~/bin/class-dump`；  
3. 打开`~/.bash_profile`文件：`vi ~/.bash_profile`  

    在文件最上方加一行：`export PATH=$HOME/bin/:$PATH`  
    *大致的意思是把`$HOME/bin/`路径添加到`PATH`环境变量，可以使用`export`命令查看是否添加成功*

    然后保存并退出（在英文输入法中依次按下esc和:（shift + ;，即冒号），然后输入wq，回车即可）；  
4. 在Terminal中执行`source ~/.bash_profile`；  
5. 上面的操作把`~/bin`路径给加入了环境变量，我们测试一下好不好用：  
    ```
    localhost:~ senhongtouzi$ pwd class-dump
    /Users/senhongtouzi
    localhost:~ senhongtouzi$ class-dump
    class-dump 3.5 (64 bit)
    Usage: class-dump [options] <mach-o-file>
    
     where options are:
           -a             show instance variable offsets
          -A             show implementation addresses
          --arch <arch>  choose a specific architecture from a universal binary (ppc, ppc64, i386, x86_64, armv6, armv7, armv7s, arm64)
         -C <regex>     only display classes matching regular expression
         -f <str>       find string in method name
         -H             generate header files in current directory, or directory specified with -o
         -I             sort classes, categories, and protocols by inheritance (overrides -s)
         -o <dir>       output directory used for -H
         -r             recursively expand frameworks and fixed VM shared libraries
         -s             sort classes and categories by name
         -S             sort methods by name
         -t             suppress header in output, for testing
         --list-arches  list the arches in the file, then exit
          --sdk-ios      specify iOS SDK version (will look in /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS<version>.sdk
          --sdk-mac      specify Mac OS X version (will look in /Developer/SDKs/MacOSX<version>.sdk
          --sdk-root     specify the full SDK root path (or use --sdk-ios/--sdk-mac for a shortcut)
    localhost:~ senhongtouzi$ 
    ```

详见: [http://bbs.iosre.com/t/10-11-usr-bin-class-dump/1936]( http://bbs.iosre.com/t/10-11-usr-bin-class-dump/1936)  

## 使用
由于从`AppStore` 下载的`App`都是经过加密的，被套上了一层壳，`class-dump`处理不了这种文件，这里我们的目的是学习使用`class-dump`，所以暂时只能对自己的`App`进行下手。  
通常打包的文件是`.ipa`格式，获取`.App`格式文件的方法如下图。

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-1.png)  

1. 定位App的可执行文件  
    进入app所在目录，并用xCode自带的`plutil`工具查看`Info.plist`中的`CFBundleExecutable`字段  
    查询结果表明`ReTest`就是App的可执行文件
    ```
    localhost:Documents senhongtouzi$ cd Retest.app
    localhost:Retest.app senhongtouzi$ plutil -p Info.plist | grep CFBundleExecutable
      "CFBundleExecutable" => "ReTest"
    ```
2. class-dump  
    将`ReTest`的头文件`class-dump`到`上级菜单的Test_RE`文件夹中  
    `-H` : 表示生成头文件到`-o`指定的文件夹  
    `-S` : `methods`通过名字排序  
    `-s` : `classes`、`categories`通过名字在排序
    ```
    localhost:Retest.app senhongtouzi$ class-dump -S -s -H ReTest -o ../Test_RE/
    ```
    
    对于砸壳的包，最好使用下面这段代码，指定 arm 类型
    ```
    class-dump -s -S -H --arch armv7 dailylife.decrypted -o ./dailylife
    ```
## 注意
**class-dump 不支持Swift，所以只要你的app包中有Swift文件就会失败**  

失败的警告大概是这样:  
```
class-dump[5542:213244] Error: Cannot find offset for address 0x280000000100007e in stringAtAddress:
```

## 结果
![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-2.png)  

# Theos
## 安装
使用`xcode-select`命令指定一个活动的`xCode`，即`Theos`默认使用的`xCode`。(如果只安装了一个xCode，请跳过这一步)  

```
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

安装Theos我先是使用小黄书上的标准步骤，不过到最后全部都安装好了以后，`nic.pl`无法正常运行，老是提示`-bash: nic.pl: command not found`。找了半天不知道为什么，猜测应该是一些依赖的框架没有安装好。  

于是我换了一个安装的方式。  

1. 安装brew (全名Homebrew是一款Mac OS平台下的软件包管理工具，拥有安装、卸载、更新、查看、搜索等很多实用的功能。)  

    ```
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ```
    安装好了以后可以使用`brew help`指令查看是否安装成功
    ```
    localhost:/ senhongtouzi$ brew help
    Example usage:
    brew search [TEXT|/REGEX/]
    brew info [FORMULA...]
    brew install FORMULA...
    brew update
    brew upgrade [FORMULA...]
    brew uninstall FORMULA...
    brew list [FORMULA...]
    ...
    ```  

2. 安装dpkg和ldid  

    ```
    brew install dpkg ldid
    ```
    从安装过程中可以看到，dpkg 和ldid 都有很多依赖，估计这就是我之前按小黄书来安装无法正常运行的因为。或许大神的电脑里面这些东西都是肯定有的？
    ```
    ==> Installing dependencies for dpkg: gnu-tar, gpatch, perl, xz
    ```
    ```
    ==> Installing dependencies for ldid: openssl
    ```  

3. 安装Thoes  

    ```
    sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
    ```
    `/opt/theos` 为安装路径，这里我和小黄书里面保持一样了，各位可自行选择。  
    
    然后修改`/opt/theos` 的权限  
    
    *(其中`id`为系统保留的用户，`id -u`为当前用户，`id -g`为当前组，`$()`是执行命令的意思。) 这里的解释只是为了方便理解，并不是官方解释。*
    ```
    sudo chown $(id -u):$(id -g) /opt/theos
    ```  

4. 配置环境变量(方便后期使用)  

    ```
    localhost:/ senhongtouzi$ cd ~
    localhost:~ senhongtouzi$ vi .bash_profile 
    ```
    在最前面添加代码
    ```
    export THEOS=/opt/theos
    export PATH=/opt/theos/bin/:$PATH
    ````  
    
    其中有第三句代码是`class-dump`的  

    ![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-3.png)  
    
    执行代码`source ~/.bash_profile`，让环境变量生效。
    
    最终执行`nic.pl`，如下图所示表示成功。
    ```
    localhost:~ senhongtouzi$ nic.pl
    NIC 2.0 - New Instance Creator
    ------------------------------
     [1.] iphone/activator_event
     [2.] iphone/application_modern
     [3.] iphone/cydget
     [4.] iphone/flipswitch_switch
     [5.] iphone/framework
     [6.] iphone/ios7_notification_center_widget
     [7.] iphone/library
     [8.] iphone/notification_center_widget
     [9.] iphone/preference_bundle_modern
     [10.] iphone/tool
     [11.] iphone/tweak
     [12.] iphone/xpc_service
    ```
    这里我们主要是使用 `tweak` 所以我们选择 11。  

## 使用  

### 1. 创建工程  

    ```
    //tweak 工程名
    Project Name (required): ReTest_180502
    
    //deb包的名字(类似Bundle identifier)
    Package Name [com.yourcompany.retest_180502]: com.dzyre.180502
    
    //作者名字
    Author/Maintainer Name [森泓投资]: dzy
    
    //作用对象的bundle identifier
    [iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: [bundle identifier]
    
    //安装完成后需要重新启动的应用
    [iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]: -
    
    Instantiating iphone/tweak in retest_180502/...
    Done.
    ```  

### 2. 定制工程文件  

    首先介绍一下创建出来的 tweak 工程包含的文件  
    ```
    localhost:retest_180502 senhongtouzi$ ls -l
    total 32
    -rw-r--r--  1 senhongtouzi  staff   135  5  2 10:06 Makefile
    -rw-r--r--  1 senhongtouzi  staff    54  5  2 10:06 ReTest_180502.plist
    -rw-r--r--  1 senhongtouzi  staff  1045  5  2 10:06 Tweak.xm
    -rw-r--r--  1 senhongtouzi  staff   204  5  2 10:06 control
    ```
    
#### Makefile  

指定工程用到的文件，框架，库等信息，将这个工程自动化。  

```
//指定处理器架构
ARCHS = armv7 arm64

//指定sdk版本
//eg: iphone:8.1:8.0 采用8.1版本，发布对象为iOS 8.0及以上  
//lateset 为Xcode附带的最新版本
TARGET = iphone:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReTest_180502
ReTest_180502_FILES = Tweak.xm

//导入 framework 
//ReTest_180502_FRAMEWORKS = UIKit CoreAudio

//导入 private framework
ReTest_180502_PRIVATE_FRAMEWORKS = BaseBoard

/*
链接Mach-O 对象
ReTest_180502_LDFLAGS = -lx

lx 代表链接 libx.a 或者 libx.dylib，即给 x 加上 lib前缀，以及 .a 或 .dylib 的后缀；如果 x 是 y.o 的形式，则直接链接 y.o，不加任何前缀或后缀。

eg: 链接 libsqlite3.0.dylib、libz.dylib、dylib1.o  
ReTest_180502_LDFLAGS = -lz -lsqlite3.0 -dylib1.o  
*/  

include $(THEOS_MAKE_PATH)/tweak.mk  
```  
    
#### Tweak.xm  
用 Theos 创建 tweak 工程，默认生成的源文件是 Tweak.xm。 xm 中 x 代表这个文件支持 Logos 语法，如果后缀是单独的一个 x ，说明源文件支持 Logos 和 C 语法；如果后缀名是 xm，说明源文件支持 Logos 和 C/C++ 语法，与Xcode项目中 m 和 mm 的区别类似。  

默认的 Tweak.xm 里面是一个简单的使用说明，包括几个常用的 Logos 预处理指令。%hook、%log、%orig，除了 Tweak.xm 中介绍的这三个指令以外，Logos 常用的预处理指令还有 %group、%init、%ctor、%new、%c。
    
1. %hook  
    指定需要 hook 的 class，必须以 %end 结尾，如下：
    ```
    %hool SpringBoard
    - (void)_menuButtonDown:(id)down
    {
        NSLog(@"You're pressed home buttom.");
        %orig;  //使用原本的 _menuButtonDown 方法;
    }
    %end
    这个钩子也就是在 SpringBoard 的 _menuButtonDown 方法中添加了一句话，然后再执行原本方法。
    ```
    
2. %log  
    适用于 %hook 的内部，将函数的类名、参数等信息写入 syslog，可以以 `%log([(<type>)<expr>,...])` 的格式追加其他打印信息。  
    ```
    %hool SpringBoard
    - (void)_menuButtonDown:(id)down
    {
        %log( (NSString *)@"DzyRe", (NSString *)@"Debug" );
        %orig;  //使用原本的 _menuButtonDown 方法;
    }
    %end
    ```
3. %orig  
    该指令在 %hook 内部使用，执行被勾住的函数的原始代码。例如上面的两个例子，如果去掉 %orig，第一个例子将只执行 `NSLog` 就结束，第二个例子将只执行 `%log` 就结束。  
    
    还可以利用 %orig 更改原始函数的参数。
    ```
    %hook SBLockScreenDateViewController
    - (void)setCustomSubtitleText:(id)arg1 withColor:(id)arg2
    {
        //这里更改的是 arg1
        %orig(@"iOS 8 App Reverse Engineering", arg2);
    }
    %end
    ```
    它的运行结果是锁屏界面原本显示日期的地方就变成了 `iOS 8 App Reverse Engineering`  
4. %group  
    该指令用于将 %hook 分组，便于代码管理及按条件初始化分组，必须以 %end 结尾；一个 %group 可以包含多个 %hook，所有不属于某个自定义 group 的 %hook 会被隐藏归类到 %group_ungrouped 中。

    ```
    %group iOS7Hook
    %hook iOS7Class
    - (id)iOS7Method 
    {
        id result = %orig;
        NSLog(@"This class & method only exist in iOS 7.");
        return result;
    }
    %end
    %end //iOS7Hook
    
    %group iOS8Hook
    %hook iOS8Class
    - (id)iOS8Method 
    {
        id result = %orig;
        NSLog(@"This class & method only exist in iOS 8.");
        return result;
    }
    %end
    %end //iOS8Hook
    
    %hook SpringBoard
    -(void)powerDown
    {
        %orig;
    }
    %end
    ```
    **需要记住的是，%group 必须配合下面的 %init 使用才能生效。**
    
5. %init  
    该指令用于初始化某个 %group，必须在 %hook 或 %ctor 内调用；如果带参数，则初始化指定的 group ，如果不带参数，则初始化 _ungrouped。
    ```
    #ifndef kCFCoreFoundationVersionNumber_iOS_8_0
    #define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
    #endif
    
    %hook SpringBoard
    - (void)applicationDidFinishLaunching:(id)application
    {
        %orig;
        
        %init; //%init(_ungrouped)
        
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
            %init(iOS7Hook);
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)
            %init(iOS8Hook);
    }
    %end
    ```
    **切记，%group 必须配合下面的 %init 使用才能生效。**  

6. %ctor  
    tweak 中的 constructor(构造器)，完成初始化工作；如果不显式定义，Theos 会自动生成一个 %ctor，并在其中调用 %init(_ungrouped)。如果显示定义了 %ctor，却没有在里面初始化 group，则 group 处于未初始化状态，也就无法操作成功。
    ```
    #ifndef kCFCoreFoundationVersionNumber_iOS_8_0
    #define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
    #endif
    
    %ctor
    {
        %init;
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0 && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
            %init(iOS7Hook);
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)
            %init(iOS8Hook);
            
        MSHookFunction(
            (void *) &AudioServicesPlaySystemSound,
            (void *) &replaced_AudioServicesPlaySystemSound,
            (void **) &original_AudioServicesPlaySystemSound
        );
    }
    ```
    **注意：%ctor 不需要 %end 结尾**

7. %new  
    在 hook 内部使用，给一个现有 class 添加新函数，功能与 class_addMethod 相同，都是动态给 class 添加新函数。
    ```
    %hook SpringBoard
    %new
    - (void)namespaceNewMethod
    {
        NSLog(@"We're added a new method to SpringBoard.");
    }
    ```
    
8. %c  
    该指令等同于 `objc_getClass` 或 `NSClassFromString`，即动态获取一个类的定义，在 %hook 或者 %ctor 内部使用。 

#### control
control 文件记录了 deb 包管理系统所需的基本信息，会被打开进 deb 包里。

```
//反向 DNS 格式，用于描述这个 deb包的名字 (按需更改)
Package: com.dzyre.180502

//描述工程的名字 (按需更改)
Name: ReTest_180502

//deb 包的依赖。mobilesubstrate 表示必须安装 CydiaSubstrate。
//可依赖的类型为 固件版本 或 其他程序 (按需更改)
Depends: mobilesubstrate

//deb 包的版本号 (按需更改)
Version: 0.0.1

//deb 包安装的目标设备架构 (不要更改)
Architecture: iphoneos-arm

//deb 包的简单介绍 (按需更改)
Description: An awesome MobileSubstrate tweak!

//deb 包的维护人 (按需更改)
Maintainer: dzy

//deb 包的作者 (按需更改)
Author: dzy

//deb 包所属的程序类别 (不要更改)
Section: Tweaks
```
Theos 在打包 deb时会对 control 文件作进一步处理，通常会更改 Version 字段，用以表示 Theos 的打包次数，方便管理；另外会增加一个 `Installed-Size` 字段，用以描述 deb 包安装后的估算大小，可能会与实际大小有偏差，但**不要更改**。
```
Version: 0.0.1-1
Install-Size: 104
```

#### .plist  
![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-4.png)  

如图，最外层是一个字典，只有一个名为 `Filter` 的键。  
其对应的值有三种：（这个截图中只有一种）
- Bundles  
    指定若干 bundle 为 tweak 的作用对象。  
- Classes
    指定若干 class 为 tweak 的作用对象。
- Executables  
    指定若干可执行文件为 tweak 的作用对象。  

这三类数组可以混合使用。**不过在有不同类的 array 时，需要添加一个 Mode: Any 键值对。当只有一类 array时，不需要添加**
![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-5.png)  

## 编译+打包+安装

### 编译
Theos 采用 `make` 指令来编译Theos 工程。编译成功会多出一个 `obj` 文件夹
```
localhost:retest_180502 senhongtouzi$ make
> Making all for tweak ReTest_180502…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (armv7)…
==> Linking tweak ReTest_180502 (armv7)…
==> Generating debug symbols for ReTest_180502 (armv7)…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (arm64)…
==> Linking tweak ReTest_180502 (arm64)…
==> Generating debug symbols for ReTest_180502 (arm64)…
==> Merging tweak ReTest_180502…
==> Signing ReTest_180502…
```
成功编译过的文件，如果再次进行 `make` 指令，将会报错 `Nothing to be done for internal-library-compile`，这种情况可以使用 下面介绍的 `clean` 指令，或者手动的把编译成功生成的文件夹及文件删掉。

### 打包
`make package` 指令，其实就是先执行 `make` 指令，然后再执行 `dpkg-deb` 指令。
```
localhost:retest_180502 senhongtouzi$ make package
> Making all for tweak ReTest_180502…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (armv7)…
==> Linking tweak ReTest_180502 (armv7)…
==> Generating debug symbols for ReTest_180502 (armv7)…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (arm64)…
==> Linking tweak ReTest_180502 (arm64)…
==> Generating debug symbols for ReTest_180502 (arm64)…
==> Merging tweak ReTest_180502…
==> Signing ReTest_180502…
> Making stage for tweak ReTest_180502…
dm.pl: building package `com.dzyre.180502:iphoneos-arm' in `./packages/com.dzyre.180502_0.0.1-1+debug_iphoneos-arm.deb'
```

**当出现类似报错:**
```
Can't locate IO/Compress/Lzma.pm in @INC (you may need to install the IO::Compress::Lzma module) (@INC contains: /Library/Perl/5.18/darwin-thread-multi-2level /Library/Perl/5.18 /Network/Library/Perl/5.18/darwin-thread-multi-2level /Network/Library/Perl/5.18 /Library/Perl/Updates/5.18.2 /System/Library/Perl/5.18/darwin-thread-multi-2level /System/Library/Perl/5.18 /System/Library/Perl/Extras/5.18/darwin-thread-multi-2level /System/Library/Perl/Extras/5.18 .) at /opt/theos/bin/dm.pl line 12.
BEGIN failed--compilation aborted at /opt/theos/bin/dm.pl line 12.
make: *** [internal-package] Error 2
```
自己动手，改下这2个文件就可了： 
```
1、/opt/theos/vendor/dm.pl/dm.pl
注释掉第12、13行
#use IO::Compress::Lzma;
#use IO::Compress::Xz;

2、/opt/theos/makefiles/package/deb.mk
第6行lzma改为gzip
_THEOS_PLATFORM_DPKG_DEB_COMPRESSION ?= gzip
```
参考：[http://bbs.iosre.com/t/tweak-make-package/10382/7](http://bbs.iosre.com/t/tweak-make-package/10382/7)

### 安装
图形化安装 可以通过软件把把包生成的 `deb` 拖到iOS中，然后通过 `iFile` 来安装，最后重启 iOS。  

这里我们推荐命令行安装法：  
首先通过越狱手机的 OpenSSH 查看该机的 IP 地址。（Reveal 章节中有 OpenSSH 的使用介绍）  

然后在 Makefile 的最上一行加上本机的 IP 地址：
```
THEOS_DEVICE_IP = 192.168.2.19
ARCHS = armv7 arm64
TARGET = iphone:latest:8.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReTest_180502
ReTest_180502_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
```

然后使用 `make package install` 来执行 编译、打包、安装一条龙服务。
```
localhost:retest_180502 senhongtouzi$ make package install
> Making all for tweak ReTest_180502…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (armv7)…
==> Linking tweak ReTest_180502 (armv7)…
==> Generating debug symbols for ReTest_180502 (armv7)…
==> Preprocessing Tweak.xm…
==> Compiling Tweak.xm (arm64)…
==> Linking tweak ReTest_180502 (arm64)…
==> Generating debug symbols for ReTest_180502 (arm64)…
==> Merging tweak ReTest_180502…
==> Signing ReTest_180502…
> Making stage for tweak ReTest_180502…
dm.pl: building package `com.dzyre.180502:iphoneos-arm' in `./packages/com.dzyre.180502_0.0.1-4+debug_iphoneos-arm.deb'
==> Installing…
root@192.168.2.19's password: 
(Reading database ... 1185 files and directories currently installed.)
Preparing to unpack /tmp/_theos_install.deb ...
Unpacking com.dzyre.180502 (0.0.1-4+debug) over (0.0.1-3+debug) ...
Setting up com.dzyre.180502 (0.0.1-4+debug) ...
```
安装成功后可以在手机的 `Cydia` 中的已安装栏目中找到，然后当你运行app的时候，就会启动这个插件，以实现钩子操作：  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-6.png)

### 简化命令行安装
按书上的说法，每次 `make package install` 会需要输入两次密码，显得略麻烦，于是有简化的方式。也就是通过设置 iOS 的 `authorized_keys` 来达到目的。  

我这边碰到的实际情况，只需要输入一次密码，并且我按照书上的这种方式进行操作，完成之后还是需要输入密码。我试了好几次，应该没有误操作。由于没有效果，这里我就不记录过程了。 如果是我的操作问题，还请大佬指出。 

### 清理
`make clean` 指令，其实就是删除 `make` 和 `make package` 指令生成的相关文件。同时可以使用 `rm packages/*.deb` 指令来删除生成的 deb 文件。

# Reveal
Reveal是一个UI分析工具，可以直观的查看App的UI布局。如下图所示为iOS8.4.1上看到的老版本微博的首页。
![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-7.png)  
使用Reveal查看别人的App布局有如下几个前提  
- 打开OpenSSH通道的越狱手机
- iOS设备必须和Mac在同一个局域网
- Mac需要安装 Reveal，iOS设备通过Cydia安装Reveal Loader  

Mac上面安装Reveal并不麻烦，你可以去下载一个破解的，也可以去支持正版，这里不做具体说明。

## OpenSSH 的使用
我是使用爱思助手越狱以及开通OpenSSH通道的。别的方法我并不太清楚，有兴趣可以自行尝试。

默认登录账号为: root  
默认登录密码为: alpine

### 1. 链接
在手机的网络设置中找到当前局域网的ip地址，也就是wifi的ip地址。
```
localhost:~ senhongtouzi$ ssh root@192.168.2.19
root@192.168.2.19's password: 
```

链接成功以后前缀会变更
```
dzy-re:~ root# ls -l
```
### 2. 退出
指令为`exit`  

eg:
```
dzy-re:~ root# exit
logout
Connection to 192.168.2.19 closed.
```

**我之前连通过的，后来因不确定原因又导致连不上去了，提示 port 22: Connection refused，我猜测是因为Mac 我更改过登录密码，然后我在手机上重新安装了一下OpenSSH就好了。**

### 3. 拷贝文件
执行该操作的时候并不需要链接上`OpenSSH`，Mac本地命令行操作。

下面的指令为从本地拷贝到iOS设备上，需从iOS设备拷贝到本地，反过来即可  

`scp /path/to/localFile user@iOSIP:/path/to/remoteFile`  

eg:   
`localhost:Downloads senhongtouzi$ scp libReveal.dylib root@192.168.2.19:/Library/RHRevealLoader`

### 4. 修改登录密码
iOS上的账户有两个，分别是`root`和`mobile`。命令如下

```
dzy-re:~ root# passwd root
Changing password for root.
New password:
Retype new password:
dzy-re:~ root# passwd mobile
Changing password for mobile.
New password:
Retype new password:
```

## Reveal Loader
### 安装
在Cydia中搜索并安装Reveal Loader，如下图所示。  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-8.png)  

安装的过程中，某些文件犹豫资源在国外，不一定能正常下载。所以在下载完成后，需要检查一下iOS上的`/Library/`目录下有没有一个名为`RHRevealLoader`的文件夹。  

**这里需要强调一下: 在/根目录 和~根目录下都有一个文件夹叫做Library，我们需要使用的是/根目录下的Library，也就是下面的第二个地址**
```
/var/root/Library
/Library
```

需要先使用OpenSSH链接到越狱手机，然后执行命令，如果已经安装将得到如下的结果。
```
dzy-re:~ root# ls -l /Library/ | grep RHRevealLoader
drwxr-xr-x 2 root admin  102 Apr 11 10:34 RHRevealLoader
```

如果没有，就手动创建一个，如下：  
```
dzy-re:~ root# mkdir /Library/RHRevealLoader 
```


**这里需要说明一下，下面关于libReveal.dylib的操作，不管安装完Reveal Loader 有没有RHRevealLoader文件夹，最好都进行一下。没有RHRevealLoader文件夹就是手动获取该文件，有RHRevealLoader文件夹就当是更新一下该文件。**  


在Mac上打开Reveal，在标题栏的`Help`选项下，选中其中的`Show Reveal Library in Finder`子选项。  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-9.png)  

在老版的Reveal中，好像有个文件叫`libReveal.dylib`，我们需要的也是它。但是新版中没有这个名字的文件，新版本中，找到如下文件，并直接复制一份出来，改名为`libReveal.dylib`  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-10.png)  

通过OpenSSH的scp命令将该文件复制到`/Library/RHRevealLoader`目录下。  

至此安装完成。

### 配置
在手机的设置中找到`Reveal`，点击`Enabled Applications`，将你需要查看UI的app之后的按钮打开。  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-11.png)  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-12.png)  

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-13.png)

### 使用Reveal查看目标App布局

![](https://github.com/dzyding/Study/blob/master/iOS-Re/images/1-14.png)