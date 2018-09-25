如果你需要了解 Theos、class-dump、OpenSSH、Reveal 的基本安装使用，请移驾 [iOS逆向（一）：OSX工具篇](https://juejin.im/post/5ac194d2f265da239e4e3ae4)
# LLDB 与 debugServer

## 1. 简介
`LLDB` 全称为 `Low Level Debugger`，是由苹果出品，内置于 Xcode 中的动态调试工具。  

`LLDB` 是运行在 `OSX` 中的，要想调试 `iOS`，还需要另一个工具的配合，它就是 `debugserver`。  

`debugserver` 运行在 `iOS` 上，顾名思义，它作为服务端，实际执行 `LLDB` (作为客户端) 传过来的指令，再把执行结果反馈给 `LLDB`，显示给用户，即所谓的 "远程调试"。在默认情况下，`iOS` 上并没有安装 `debugserver`，只有在设备连接过一次 `Xcode`，并在 `Window -> Devices` 菜单中添加此设备后，`debugserver` 才会被 `Xcode` 安装到 `iOS`的 `/Developer/usr/bin/` 目录下。

## 2. 配置 debugserver
1. 帮 debugserver 减肥  
    首先去网上找一下你越狱机器对应的 `ARM` 信息，我这里用的 `iPhone5` 对应的是 `armv7s`。（从 `5s` 开始，后面出的 `iPhone` 应该都是 `arm64`）。  
    
    - 将未经处理的 `debugserver` 从 `iOS` 拷贝到 `OSX` 中的任意目录下。(只是一个临时存放点)  
        ```
        localhost:~ senhongtouzi$ scp root@192.168.2.19:/Developer/usr/bin/debugserver ~/Downloads/debugserver
        ```
        **其实这一步可以直接使用iFunBox 来拷贝**
    - 然后帮它减肥，命令如下：
        ```
        localhost:~ senhongtouzi$ lipo -thin armv7s ~/Downloads/debugserver -output ~/Downloads/debugserver
        ```
2. 给 debugserver 添加 task_for_pid 权限  
    下载 `http://iosre/com/ent.xml` 到 OSX 的 `~/Downloads` (也就是和 debugserver 同一个目录)。然后运行如下命令：
    ```
    localhost:Downloads senhongtouzi$ ldid -Sent.xml debugserver
    ```
    **小黄书中，ldid 的安装是通过下载，手动拷贝到 /opt/theos/bin/ldid  的，我当初 ldid 是通过 brew 安装的，并配置了一些环境变量，运行的时候直接 ldid 就行了。所以这里前面的 ldid 运行路径需要根据具体你的安装路径来输入**
3. 将经过处理的 debugserver 拷回iOS  
    ```
    localhost:~ senhongtouzi$ scp ~/Downloads/debugserver root@192.168.2.19:/usr/bin/debugserver
    localhost:~ senhongtouzi$ ssh root@192.168.2.19
    dzy-re:~ root# chmod +x /usr/bin/debugserver
    ```
    **其实这一步可以直接使用iFunBox 来拷贝**  
    
    这里之所以把处理过的 `debugserver` 存放在 `iOS` 的 `/usr/bin` 下，而没有覆盖 `/Developer/usr/bin/` 下的原版 `debugserver`，一是因为原版 `debugserver` 是不可写的，无法覆盖；二是因为 `/usr/bin/` 下的命令无须输入全路径就可以执行，即在任意目录下运行 `debugserver` 都可启动处理过的 `debugserver`。  
    
## 3. 用 debugserver 启动或附加进程
- 启动 executable，并开启 port 端口，等待来自 IP 的 LLDB 接入。  
    ```
    debugserver -x backboard IP:port /path/to/executable
    ```
- 附加 processName，并开启 port 端口，等待来自 IP 的 LLDB 接入。  
    ```
    debugserver IP:port -a "ProcessName"
    ```  

## 4. LLDB 的使用说明

### 建立连接
1. 通过 SSH 连接越狱机，启动 `MobileSMS.app` ，并开启 `1234` 端口，等待任意 IP 地址的 LLDB 接入
    ```
    localhost:~ senhongtouzi$ ssh root@192.168.2.19
    root@192.168.2.19's password: 
    dzy-re:~ root# debugserver -x backboard *:1234 /Applications/MobileSMS.app/MobileSMS 
    debugserver-@(#)PROGRAM:debugserver  PROJECT:debugserver-320.2.89
     for armv7.
    Listening to port 1234 for a connection from *...
    ```
2. **另开一个终端**，运行指定 `Xcode` 中 `lldb`  
    ```
    localhost:~ senhongtouzi$ /Applications/Xcode.app/Contents/Developer/usr/bin/lldb
    (lldb) 
    ```
3. 用 `lldb` 连接正在等待的 `debugserver`  
    ```
    (lldb) process connect connect://192.168.2.19:1234
    Process 771 stopped
    * thread #1, stop reason = signal SIGSTOP
        frame #0: 0x1feee000 dyld`_dyld_start
    dyld`_dyld_start:
    ->  0x1feee000 <+0>:  mov    r8, sp
        0x1feee004 <+4>:  sub    sp, sp, #16
        0x1feee008 <+8>:  bic    sp, sp, #7
        0x1feee00c <+12>: ldr    r3, [pc, #0x70]           ; <+132>
    Target 0: (dyld) stopped.
    (lldb) 
    ```
4. 用 `c` 指令，让项目继续运行 (其本质应该是 `process continue` 指令)  
    ```
    (lldb) c 
    Process 808 resuming
    2018-05-08 15:30:03.142 MobileSMS[808:178059] Splitview controller <CKMessagesController: 0x15bd7800> is expected to have a view controller at index 0 before it's used!
    2018-05-08 15:30:04.908 MobileSMS[808:178059] Unbalanced calls to begin/end appearance transitions for <CKMessagesController: 0x15bd7800>.
    2018-05-08 15:30:04.955 MobileSMS[808:178059] WiFi is associated YES
    WiFi is associated YES
    (lldb)
    ```
    
### 常用功能
1. image list  
    用于列举当前进程中的所有模块（image）。  
    
    因为 `ASLR(Address Space Layout Randomization)` 的关系，每次进程启动时，同一进程的所有模块在虚拟内存中的起始地址都会产生随机的偏移。而这个 `ASLR 偏移量` 恰恰是接下来会频繁用到的一个关键数据。`image list -o -f` 命令就是获取这个数据的方式。
    ```
    (lldb) image list -o -f
    [  0] 0x00076000 /Applications/MobileSMS.app/MobileSMS(0x000000000007a000)
    [  1] 0x000ba000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/usr/lib/dyld
    [  2] 0x00199000 /Library/MobileSubstrate/MobileSubstrate.dylib(0x0000000000199000)
    [  3] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/Frameworks/Foundation.framework/Foundation
    [  4] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/Frameworks/UIKit.framework/UIKit
    [  5] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices
    [  6] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/Frameworks/AVFoundation.framework/AVFoundation
    [  7] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices
    .
    .
    .
    ```
    第一列 [X] 是模块的序号；  
    第二列是模块在虚拟内存中的起始地址因 ASLR 而产生的随机偏移；  
    第三列是模块的全路径，括号里是偏移之后的起始地址；  
    
    **这里如果模块的路径是Mac上的，将没有偏移之后的起始地址部分，详见[http://bbs.iosre.com/t/image-list-foundation/2286/3](http://bbs.iosre.com/t/image-list-foundation/2286/3)**
    
    <font color=brown>!! 具体各种地址，各种偏移的使用，文章后面单独写了一段</font>
    
2. breakpoint  
    用于设置断点。常见的有三种设置方式：
    - `b function`  
        在函数的起始位置设置断点，例如：  
        ```
        (lldb) b NSLog
        Breakpoint 2: where = Foundation`NSLog, address = 0x23c5fb94
        ```
    - `br s -a address`  
        在地址处设置断点，例如：
        ```
        (lldb) br s -a 0xCCCCC
        Breakpoint 5: where = SpringBoard`___lldb_unnamed_function303$$SpringBoard, address = 0x000ccccc
        ```
    - `br s -a 'ASLROffset + address'`  
        在地址处设置断点，例如：
        ```
        (lldb) br s -a '0x6 + 0x9'
        Breakpoint 6: address = 0x0000000f
        ```
        
    对于三种方式，在输出的 `Breakpoint X:` 中，这个 `X` 是断点的序号，后面会用到。
    
    还可以通过 `br dis`、`br en` 、`br del` 系列命令来禁用、启用和删除断点。 
    - 禁用所有断点 ( `dis` 代表 `disable` )
        ```
        (lldb) br dis
        ```
    - 禁用某个断点 ( `6` 就是设置断点时对应的序号 )
        ```
        (lldb) br dis 6
        ```
    `en` 代表 `enable`，`del` 代表 `delete`，使用方式和 `dis` 命令一样，不带断点序号就是对所有的断点操作，带断点序号就是对某一个断点操作。  
    
    另外有一个非常有用的命令 `br com add` ，是指定在某个断点得到触发的时候，执行预先设置的指令。  
    
    <font color=brown>!! 文章后面有一段单独写了一个例子，包含了上述所有 breakpoint 相关内容</font>  
    
3. print  
    `LLDB` 的主要功能之一是 `在程序停止的时候检查程序内部发生的事`，而这个功能正是 `print` 命令完成的，它可以打印某处的值。
    - p 命令  
        用来打印基础数据类型
    - po 命令  
        用来打印对象
    - x 命令  
        打印一个地址处存放的值  
        `p/x` 以十六进制方式打印指针
        `x/10` 打印这个指针指向的连续 10 个字 (word) 数据

    <font color=brown>!! 文章后面有一段单独写了一个例子，包含了 print 的部分使用</font>  
    
4. nexti 与 stepi  
    `nexti` 和 `stepi` 的作用都是执行下一条机器指令，它们最大的区别是前者不进入函数体，而后者会进入函数体。可以分别简写为 `ni` 与 `si`。

    <font color=brown>!! 文章后面有一段单独写了一个例子，包含了 ni si 的部分使用</font>

5. regitster write  
    该命令用于给指定的寄存器赋值，从而`对程序进行改动，观察程序的执行有什么变化`。
    ```
    //将 r0 寄存器的值设置为 1
    (lldb) register write r0 1
    ```
    自己做了一些尝试，结果都跟自己想象的不太一样，算是实验失败吧，我就不贴测试代码了。  
    
    我现在看的这一章还只是属于介绍工具的章节，所以并不打算死磕，我想后面应该会有更详细的介绍吧，如果我知道怎么处理了，我会写新的文章或者把这里更新一下。
    
### 关于 image list 操作中获取地址的使用 

#### 1. 模块基地址

首先公式为：  
```
偏移后模块基地址 = 偏移前模块基地址 + ASLR 偏移
```

这里拿上面 `image list -o -f` 数据中的 `Founction` 模块来做例子：  

通过信息 `[  3] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/Frameworks/Foundation.framework/Foundation` 中的路径找到 `Foundation` 的二进制文件，拖入 `IDA` 中。  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-1.png)  

结合 `lldb` 和 `IDA` 的中 `Foundation` 的数据：  
`偏移前模块地址` 为 `0x2268A000` (`IDA` 中获取)  
`ASLR 偏移` 为 `0x0339e000` (`lldb` 中获取)  

则计算 `偏移后模块地址` 为两者相加：`0x25A28000`

#### 2. 符号基地址 (symbol base address)

回到 `IDA`，在 `Functions window` 里搜索 `NSLog`，然后跳转到它的实现。  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-2.png)  

因为 `Foundation` 的基地址是已知的，而 `NSlog` 函数在 `Foundation` 中的位置是固定的，所以有公式：  
```
NSLog 偏移后基地址 = NSLog 在 Foundation 中的相对位置 + Function 偏移后的基地址  
```

图中可以看到，`NSLog` 的第一条指令 `SUB SP, SP, #0xC` 的地址为 `0x2269A0D4` ，它也就是 `NSLog` 在 `Foundation` 的位置。用它减去 `Foundation` 偏移前的基地址 `0x2268A000`，也就是 `NSLog` 函数在 `Foundation` 中的相对位置，即 `0x100D4`。  

因此根据公式 `NSLog` 的基地址 = `0x100D4` + `0x25A28000` = `0x25A380D4`  

公式转换：   
```
NSLog 偏移后基地址 = NSLog 偏移前的基地址 - Foundation 偏移前的基地址 + Foundation 偏移后的基地址  

NSLog 偏移后基地址 = NSLog 偏移前的基地址 - Foundation 偏移前的基地址 + Foundation 偏移前的基地址 + Foundation ASLR偏移  

NSLog 偏移后基地址 = NSLog 偏移前的基地址 + Foundation ASLR偏移  
```

转化为通过公式：  
```
偏移后符号基地址 = 偏移前符号基地址 + 符号所在模块的 ASLR 偏移
```
验证：  
`NSLog` 的 `偏移前符号基地址` 是 `0x2269A0D4`，`Foundation` 的 `ASLR` 偏移是 `0x0339e000`，两者相加正好是 `0x25A380D4`。  

举一反三，指令基地址的计算也可以套用上面的公式：  
```
偏移后指令基地址 = 偏移前指令基地址 + 指令所在模块的 ASLR 偏移
```
自然，`符号基地址 = 符号对应函数第一条指令的基地址`。

最后需要记住：偏移前基地址从 `IDA` 里看，`ASLR` 偏移从 `LLDB` 看，两者相加就是偏移后的基地址。

### breakpoint、print、ni、si 使用案例

1. 在 `IDA` 中打开 `SpringBoard` 二进制文件，等待分析结束以后在 `Functions window` 中搜索 `menuButtonDown`，找到对应的 `-[SpringBoard _menuButtonDown:]`，如下图所示：  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-3.png)  

可以看到，第一条指令 `PUSH {R4-R7,LR}` 的偏移前基地址是 `0x00014A10`。  
```
提示 ：
如果不知道知道二进制文件在那，可以先运行第二步的 lldb  
在 lldb 的 image list 指令中可以找到 SpringBoard 的路径
比如： [  0] 0x00094000 /System/Library/CoreServices/SpringBoard.app/SpringBoard(0x0000000000098000)
```
2. 使用 `LLDB` 查看 `ASLR` 偏移  
    先 `ssh` 到 iOS 中配置 debugserver.  
    ```
    localhost:~ senhongtouzi$ ssh root@192.168.2.19
    root@192.168.2.19's password: 
    dzy-re:~ root# debugserver *:1234 -a "SpringBoard"
    debugserver-@(#)PROGRAM:debugserver  PROJECT:debugserver-320.2.89
     for armv7.
    Attaching to process SpringBoard...
    Listening to port 1234 for a connection from *...
    ```
    
    另开一个终端，用 `LLDB` 链接，并查看 `ASLR` 偏移  
    ```
    localhost:~ senhongtouzi$ /Applications/Xcode.app/Contents/Developer/usr/bin/lldb
    (lldb) process connect connect://192.168.2.19:1234
    Process 84 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = signal SIGSTOP
        frame #0: 0x33aca474 libsystem_kernel.dylib`mach_msg_trap + 20
    libsystem_kernel.dylib`mach_msg_trap:
    ->  0x33aca474 <+20>: pop    {r4, r5, r6, r8}
        0x33aca478 <+24>: bx     lr
    
    libsystem_kernel.dylib`mach_msg_overwrite_trap:
        0x33aca47c <+0>:  mov    r12, sp
        0x33aca480 <+4>:  push   {r4, r5, r6, r8}
    Target 0: (SpringBoard) stopped.
    (lldb) image list -o -f
    [  0] 0x00094000 /System/Library/CoreServices/SpringBoard.app/SpringBoard(0x0000000000098000)
    [  1] 0x00057000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/usr/lib/dyld
    [  2] 0x006de000 /Library/MobileSubstrate/MobileSubstrate.dylib(0x00000000006de000)
    [  3] 0x0339e000 /Users/senhongtouzi/Library/Developer/Xcode/iOS DeviceSupport/8.4.1 (12H321)/Symbols/System/Library/PrivateFrameworks/StoreServices.framework/StoreServices
    .
    .
    .
    ```
    `SpringBoard` 模块的 `ASLR` 偏移是 `0x00094000`
3. 设置断点并触发  
    第一条指令的偏移后基地址是 `0x00014A10` + `0x00094000` = `0x000A8A10`。  
    在 `lldb` 中输入 `br s -a 0x000A8A10` 即可在第一条指令处设下断点。  
    ```
    (lldb) br s -a 0x000A8A10
    Breakpoint 1: where = SpringBoard`_mh_execute_header + 50656, address = 0x000a8a10
    ```
    按下设备上的 `home` 键触发断点。  
    ```
    Process 84 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
        frame #0: 0x000a8a10 SpringBoard`_mh_execute_header + 68112
    SpringBoard`_mh_execute_header:
    ->  0xa8a10 <+68112>: svcge  #0x3b5f0
        0xa8a14 <+68116>: stceq  p9, c14, [r0, #-180]
        0xa8a18 <+68120>: pkhbtmi r11, r3, r4, lsl #1
        0xa8a1c <+68124>: rscspl pc, r6, r3, asr #4
    Target 0: (SpringBoard) stopped.
    ```  
    当进程停下来之后，可以用 `c` 命令让进程继续运行。   
    
    `不知道为什么，我这里按 home 触发断点以后的打印信息，并不是像书上那样，基本和 IDA 中的指令可以对应上。以后如果我知道了为什么，我会回来把这个改掉。`

4. 删除断点  
    ```
    (lldb) br del 1
    1 breakpoints deleted; 0 breakpoint locations disabled.
    ```
    
5. `br com add` 命令  
    ```
    //设置断点
    (lldb) br s -a 0x000A8A10
    Breakpoint 2: where = SpringBoard`_mh_execute_header + 50656, address = 0x000a8a10
    
    (lldb) br com add 2
    
    //设置一系列指令，这里是 打印 r1，并且执行 c 命令， 然后输入 DONE (DONE输入完按回车以后并不会显示出来)
    Enter your debugger command(s).  Type 'DONE' to end.
    > p (char *)$r1 
    > c 
    
    //触发断点
    (lldb)  p (char *)$r1
    (char *) $0 = 0x0041a24b "_menuButtonDown:"
    
    (lldb)  c
    Process 84 resuming
    
    Command #2 'c' continued the target.
    (lldb)  
    ```
6. print  

    ![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-4.png)  

    `MOVS R6, #0`的偏移后基地址为 `0x00014ACC` + `0x00094000` = `0x000A8ACC`。在这条指令上下一个断点，待断点被触发后，看看当前 `R6` 的值。
    ```
    (lldb) br s -a 0x000A8ACC
    Breakpoint 1: where = SpringBoard`_mh_execute_header + 50844, address = 0x000a8acc
    Process 84 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
        frame #0: 0x000a8acc SpringBoard`_mh_execute_header + 68300
    SpringBoard`_mh_execute_header:
    ->  0xa8acc <+68300>: vsubhn.i16 d18, q0, q0
        0xa8ad0 <+68304>: .long  0x2101004c                ; unknown opcode
        0xa8ad4 <+68308>: stchs  p4, c4, [r0, #-480]
        0xa8ad8 <+68312>: .long  0xf80b6800                ; unknown opcode
    Target 0: (SpringBoard) stopped.
    (lldb) p $r6
    (unsigned int) $0 = 419514368
    ```
    此条指令执行之后，R6 应该被置 0。输入 `ni` 执行此条指令，再次查看 R6 的值。  
    ```
    (lldb) ni
    Process 84 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = instruction step over
        frame #0: 0x000a8ace SpringBoard`_mh_execute_header + 68302
    SpringBoard`_mh_execute_header:
    ->  0xa8ace <+68302>: subeq  pc, r12, r0, asr #5
        0xa8ad2 <+68306>: ldrbtmi r2, [r8], #-257
        0xa8ad6 <+68310>: stmdavs r0, {r8, r10, r11, sp}
        0xa8ada <+68314>: andne  pc, r0, r11, lsl #16
    Target 0: (SpringBoard) stopped.
    (lldb) p $r6
    (unsigned int) $1 = 0
    ```
    可以看到，`p` 命令将 R6 的值正确打印了出来。
7.  `ni`、`si`  的使用  
    这里，我重新连接了一次，`SpringBoard` 的 `ASLR` 变成了 `0x00004000`  

    ```
    [  0] 0x00004000 /System/Library/CoreServices/SpringBoard.app/SpringBoard(0x0000000000008000)
    ```  

    ![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-5.png)  

    ![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-6.png)  

    `__SpringBoard__accessibilityObjectWithinProximity__0` 偏移后的基地址是 `0x00014C1C` + `0x00004000` = `0x00018C1C`。在它上面下断点，然后使用 `ni` 命令。  
    ```
    //添加断点
    (lldb) br s -a 0x18c1c
    Breakpoint 2: where = SpringBoard`_mh_execute_header + 51180, address = 0x00018c1c
    
    //触发断点
    Process 918 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1 2.1
        frame #0: 0x00018c1c SpringBoard`_mh_execute_header + 68636
    SpringBoard`_mh_execute_header:
    ->  0x18c1c <+68636>: ldc2l  p2, c15, [r0, #76]
        0x18c20 <+68640>: svceq  #0xfff010
        0x18c24 <+68644>: vhadd.u32 d13, d2, d4
        0x18c28 <+68648>: andhs  lr, r0, r4, ror #27
        
    //调用 ni 指令
    (lldb) ni
    Process 918 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = instruction step over
        frame #0: 0x0022c7c0 SpringBoard`_mh_execute_header + 2246592
    SpringBoard`_mh_execute_header:
    ->  0x22c7c0 <+2246592>: rsbvs  pc, r4, r8, asr #4
        0x22c7c4 <+2246596>: eoreq  pc, r12, r0, asr #5
        0x22c7c8 <+2246600>: .long  0xf9904478                ; unknown opcode
        0x22c7cc <+2246604>: .long  0x47700000                ; unknown opcode
        
    //恢复运行
    (lldb) c
    Process 918 resuming
    
    //触发断点
    Process 918 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1 2.1
        frame #0: 0x00018c1c SpringBoard`_mh_execute_header + 68636
    SpringBoard`_mh_execute_header:
    ->  0x18c1c <+68636>: ldc2l  p2, c15, [r0, #76]
        0x18c20 <+68640>: svceq  #0xfff010
        0x18c24 <+68644>: vhadd.u32 d13, d2, d4
        0x18c28 <+68648>: andhs  lr, r0, r4, ror #27
        
    //调用 si 指令
    (lldb) si
    Process 918 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = instruction step into
        frame #0: 0x0022c7c0 SpringBoard`_mh_execute_header + 2246592
    SpringBoard`_mh_execute_header:
    ->  0x22c7c0 <+2246592>: rsbvs  pc, r4, r8, asr #4
        0x22c7c4 <+2246596>: eoreq  pc, r12, r0, asr #5
        0x22c7c8 <+2246600>: .long  0xf9904478                ; unknown opcode
        0x22c7cc <+2246604>: .long  0x47700000                ; unknown opcode
    (lldb)  
    ```
    
    `0x22c7c0` 偏移前的基地址是 `0x2287c0`，对应IDA来看，正好是位于`__SpringBoard__accessibilityObjectWithinProximity__0` 函数的内部  

    ![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-7.png)  
    
    ```
    我这里的例子有点问题，我不知道为什么 ni si 的运行结果是一样的。 
    试了很多次，还自己随便找了几个方法打断点测试也是一样的。。略无奈。
    ```  
    
# Cycript
    
`Cycript` 是由 `saurik` 推出的一款脚本语言，可以看做是 `Objective-JavaScript`。  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-8.png)
    
### 简单使用

因为接下来的例子中主要用到它测试函数的功能，而不是用它来写 App，所以需要把代码注入一个现成的进程中，让代码运行起来。

通过进程注入方式调用 `Cycript` 测试函数的步骤很简单，以 SpringBoard 为例，首先找到进程名或 PID。

```
dzy-re:~ root# ps -e | grep SpringBoard
 1199 ??         0:25.87 /System/Library/CoreServices/SpringBoard.app/SpringBoard
 1251 ttys000    0:00.01 grep SpringBoard
```  

`SpringBoard` 进程的 PID 是 `1199`。接下来输入 `cycript -p 1199` 或 `cycript -p SpringBoard` ，把 `Cycript` 注入 `SpringBoard`。

```
dzy-re:~ root# cycript -p 1199 
cy# alertView = [[UIAlertView alloc] initWithTitle:@"dzy" message:@"Hello" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
#"<UIAlertView: 0x183072e0; frame = (0 0; 0 0); layer = <CALayer: 0x184207c0>>"
cy# [alertView show]
cy# [alertView release]
```  

`Cycript` 的语法，不需要声明对象类型，也不需要结尾的分好，还是蛮简单的。如果函数有返回值，`Cycript` 会把它在内存中的地址及一些基本信息实时打印出来，非常直观。  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-9.png)  

如果知道一个对象在内存中的地址，可以通过 `#` 操作符来获取这个对象，例如：  

```
cy# alertView = [[UIAlertView alloc] initWithTitle:@"dzy" message:@"Hello" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
#"<UIAlertView: 0x186aa8a0; frame = (0 0; 0 0); layer = <CALayer: 0x184d0520>>"
cy# [#0x186aa8a0 show]
cy# [#0x186aa8a0 release]
```

这个的运行效果，和上面的例子一样。  

如果知道一个类对象存在于当前的进程中，却不知道它的地址，不能通过 `#` 操作符来获取它，此时，不妨试试 `choose` 命令，它的用法如下：

```
cy# choose (SBScreenShotter)
[#"<SBScreenShotter: 0x18345070>"]
cy# choose (SBUIController)
[#"<SBUIController: 0x16f4a880>"]
```

这里我自己写了个例子可以供大家参考：  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-10.png)  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-11.png)  

![](https://github.com/dzyding/Study/blob/master/iOSRe/images/2-12.png)

### 退出编辑
`control + D` 
    
# dumpdecrypted
    
从 `AppStore` 下载的 App (以下简称 StoreApp) 是被苹果加密过的，可执行文件被套上了一层保护壳，而 `class-dump` 无法作用于加密过的 App。在这种，需要解密 App 的可执行文件，俗称 `砸壳`。`dumpdecrypted` 就是由越狱社区的知名人士 `Stefan Esser` 出品的一款砸壳工具。
    
### 使用方法
    
1. 从 `Github` 下载 `dumpdecrypted` 源码：  

    ```
    localhost:dumpdecrypted senhongtouzi$ git clone git://github.com/stefanesser/dumpdecrypted/
    Cloning into 'dumpdecrypted'...
    remote: Counting objects: 31, done.
    remote: Total 31 (delta 0), reused 0 (delta 0), pack-reused 31
    Receiving objects: 100% (31/31), 7.10 KiB | 2.37 MiB/s, done.
    Resolving deltas: 100% (15/15), done.
    ```

2. 编译 `dumpdecrypted.dylib`  

    ```
    localhost:dumpdecrypted senhongtouzi$ cd dumpdecrypted/
    localhost:dumpdecrypted senhongtouzi$ make
    `xcrun --sdk iphoneos --find gcc` -Os  -Wimplicit -isysroot `xcrun --sdk iphoneos --show-sdk-path` -F`xcrun --sdk iphoneos --show-sdk-path`/System/Library/Frameworks -F`xcrun --sdk iphoneos --show-sdk-path`/System/Library/PrivateFrameworks -arch armv7 -arch armv7s -arch arm64 -c -o dumpdecrypted.o dumpdecrypted.c 
    `xcrun --sdk iphoneos --find gcc` -Os  -Wimplicit -isysroot `xcrun --sdk iphoneos --show-sdk-path` -F`xcrun --sdk iphoneos --show-sdk-path`/System/Library/Frameworks -F`xcrun --sdk iphoneos --show-sdk-path`/System/Library/PrivateFrameworks -arch armv7 -arch armv7s -arch arm64 -dynamiclib -o dumpdecrypted.dylib dumpdecrypted.o
    ```

    我操作的时候，这里中间还有一些报错，不过我看到 `dumpdecrypted.dylib` 生成出来了，并且后面的步骤也都执行成功了，想来应该没什么影响。  

3. 使用 `ps` 命令定位待砸壳的可执行文件  
    `StoreApp` 的可执行文件位于 `/var/mobile/Containers/Bundle/Application/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/**.app/` 这类路径下。我们不知道 X 是什么，肉眼定位需要手动遍历所有目录，劳民伤财，但一个简单的小技巧就可以省时省力。  
    
    首先在 iOS 中关掉所有 `StoreApp`，然后打开需定位的 app，接着 `ssh` 到 iOS 上，打印出所有进程，如下：
    
    <font color=brown>提示：使用 ps -e 指令如果报错 -sh: ps: command not found。需要在 Cydia 中安装 adv-cmds。我的越狱机iPhone5，iOS8.4.1 是需要安装的。</font>
    ```
    localhost:~ senhongtouzi$ ssh root@192.168.2.19
    root@192.168.2.19's password: 
    dzy-re:~ root# ps -e
    .
    .
    .
     1060 ??         0:56.77 /Applications/AppStore.app/AppStore
     1065 ??         0:00.49 /System/Library/PrivateFrameworks/FamilyCircle.framework/familycircled
     1074 ??         0:00.26 /usr/libexec/limitadtrackingd
     1077 ??         0:00.39 /System/Library/Frameworks/PassKit.framework/passd
     1091 ??         0:00.17 /System/Library/Frameworks/CFNetwork.framework/AssetCacheLocatorService
     1094 ??         0:01.70 /System/Library/PrivateFrameworks/StreamingZip.framework/XPCServices/com.apple.StreamingUnzipService.xpc/com.appl
     1103 ??         0:00.30 sshd: root@ttys000 
     1107 ??         0:37.56 /var/mobile/Containers/Bundle/Application/797BB685-B4AB-430F-B3EE-8E67564E24FF/dailylife.app/dailylife
     1114 ??         0:13.22 /Applications/Cydia.app/Cydia
     1105 ttys000    0:00.06 -sh
     1167 ttys000    0:00.01 ps -e
    ```

    其中唯一含有 `/var/mobile/Containers/Bundle` 的也就是我们所需要 app 可执行文件的全路径。  
    
4. 用 `Cycript` 找出目标 app 的 `Documents` 目录路径  

    `StoreApp` 的 `Documents` 目录位于 `/var/mobile/Containers/Data/Application/YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY/` 下，Y 与之前的 X 值不同，而且这次 `ps` 也帮不上忙。因此需要借助强大的 `Cycript`，让 App 告诉我们 `Documents` 的路径。  

    ```
    //需要先链接上 SSH
    dzy-re:~ root# cycript -p dailylife
    cy# [[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask][0]
    #"file:///var/mobile/Containers/Data/Application/A5018E33-36EA-4CFD-9B27-8E3CA47BA44B/Documents/"
    ```

5. 将 `dumpdecrypted.dylib` 拷贝到 `Documents` 目录下  

    ```
    localhost:dumpdecrypted senhongtouzi$ scp dumpdecrypted.dylib root@192.168.2.19:/var/mobile/Containers/Data/Application/A5018E33-36EA-4CFD-9B27-8E3CA47BA44B/Documents/
    root@192.168.2.19's password: 
    dumpdecrypted.dylib               100%  193KB   2.3MB/s   00:00    
    ```  

6. 开始砸壳  
    `dumpdecrypted.dylib` 的用法是：`DYLD_INSERT_LIBRARIES=/path/to/dumpdecrypted.dylib /path/to/executable`
    实际操作就是:  

    ```
    dzy-re:~ root# cd /var/mobile/Containers/Data/Application/A5018E33-36EA-4CFD-9B27-8E3CA47BA44B/Documents/
    dzy-re:/var/mobile/Containers/Data/Application/A5018E33-36EA-4CFD-9B27-8E3CA47BA44B/Documents root# DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /var/mobile/Containers/Bundle/Application/797BB685-B4AB-430F-B3EE-8E67564E24FF/dailylife.app/dailylife
    mach-o decryption dumper
    
    DISCLAIMER: This tool is only meant for security research purposes, not for application crackers.
    
    [+] detected 32bit ARM binary in memory.
    [+] offset to cryptid found: @0xe2a08(from 0xe2000) = a08
    [+] Found encrypted data at address 00004000 of length 5750784 bytes - type 1.
    [+] Opening /private/var/mobile/Containers/Bundle/Application/797BB685-B4AB-430F-B3EE-8E67564E24FF/dailylife.app/dailylife for reading.
    [+] Reading header
    [+] Detecting header type
    [+] Executable is a FAT image - searching for right architecture
    [+] Correct arch is at offset 16384 in the file
    [+] Opening dailylife.decrypted for writing.
    [+] Copying the not encrypted start of the file
    [+] Dumping the decrypted data into the file
    [+] Copying the not encrypted remainder of the file
    [+] Setting the LC_ENCRYPTION_INFO->cryptid to 0 at offset 4a08
    [+] Closing original file
    [+] Closing dump file
    ```  

    当前目录下会生成 .decrypted ，即砸壳后的文件  

    ```
    dzy-re:/var/mobile/Containers/Data/Application/A5018E33-36EA-4CFD-9B27-8E3CA47BA44B/Documents root# ls
    HFDatabase.db  authorization  dailylife.decrypted  dumpdecrypted.dylib	utlog.sqlite
    ```

# usbmuxd

一款可以把本地 OSX / Windows 端口转发到远程 iOS 端口的工具。相较于之前一直使用的 wifi 传输，它的速度和稳定性更好。
    
### 下载并配置
    
从 `http://cgit.sukimashita.com/usbmuxd.git/snapshot/usbmuxd-1.0.8.tar.gz` 下载usbmuxd，解压到本地。我们用到的只有 `python-client` 目录下的 `tcprelay.py` 和 `usbmux.py` 两个文件，把它们放到同一个目录下，比如，笔者的是：`/Users/senhongtouzi/Documents/usbssh/`
    
### 使用方式
    
使用命令： `/Users/senhongtouzi/Documents/usbssh/tcprelay.py -t 远程 iOS 上的端口 : 本地 OSX/Windows 上的端口` 即可把本地的 `OSX / Windows` 上的端口转发到远程 `iOS` 上的端口。
    
### 使用场景举例
在没有 `wifi` 的情况下，使用 `USB` 链接到 `iOS`，用 lldb 调试 ` SpringBoard`。  

1. 把本地 2222 端口转发到 iOS 的 22端口
    ```
    localhost:~ senhongtouzi$ /Users/senhongtouzi/Documents/usbssh/tcprelay.py -t 22:2222
    Forwarding local port 2222 to remote port 22
    ```
    
    如果出现错误:  
    `-bash: /Users/senhongtouzi/Documents/usbssh/tcprelay.py: Permission denied`  
    
    可以使用命令下面的指令解决，笔者这里比较粗暴，直接设置成了最高权限。  
    `localhost:~ senhongtouzi$ sudo chmod -R 777 /Users/senhongtouzi/Documents/usbssh/tcprelay.py` 
    
2. ssh 到 iOS 中，并用 `debugserver` 附加 `SpringBoard`  

    可能会像我下面这样被要求添加到信任列表  

    ```
    localhost:~ senhongtouzi$ ssh root@localhost -p 2222
    The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
    RSA key fingerprint is SHA256: [ ****** ].
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '[localhost]:2222' (RSA) to the list of known hosts.
    root@localhost's password: 
    dzy-re:~ root# debugserver *:1234 -a "SpringBoard"
    ```
    
3. 把本地 1234 端口转发到 iOS 的 1234 端口  

    ```
    localhost:~ senhongtouzi$ /Users/senhongtouzi/Documents/usbssh/tcprelay.py -t 1234:1234
    Forwarding local port 1234 to remote port 1234
    ```

4. 用 lldb 开始调试  

    ```
    localhost:~ senhongtouzi$ /Applications/Xcode.app/Contents/Developer/usr/bin/lldb
    (lldb) process connect connect://localhost:1234
    Process 1199 stopped
    * thread #1, queue = 'com.apple.main-thread', stop reason = signal SIGSTOP
        frame #0: 0x33aca474 libsystem_kernel.dylib`mach_msg_trap + 20
    libsystem_kernel.dylib`mach_msg_trap:
    ->  0x33aca474 <+20>: pop    {r4, r5, r6, r8}
        0x33aca478 <+24>: bx     lr
    
    libsystem_kernel.dylib`mach_msg_overwrite_trap:
        0x33aca47c <+0>:  mov    r12, sp
        0x33aca480 <+4>:  push   {r4, r5, r6, r8}
    Target 0: (SpringBoard) stopped.
    ```
    
# socat
书上介绍的 `syslogd to /var/log/syslog` 笔者前后试了好几次，依旧不存在这个目录，然后在论坛里面找到了一个新的工具，可以用来替代它。也就是 `socat` 。

### 下载安装
在 Cydia 中搜索 SOcket CAT 并安装

### 运行
连接到系统日志的 sock 文件  
`socat - UNIX-CONNECT:/var/run/lockdown/syslog.sock`

### 使用
运行以后可以使用 `help` 指令查看帮助。  

```
dzy-re:~ root# socat - UNIX-CONNECT:/var/run/lockdown/syslog.sock

========================
ASL is here to serve you
> help
Commands
    quit                 exit session
    select [val]         get [set] current database
                         val must be "file" or "mem"
    file [on/off]        enable / disable file store
    memory [on/off]      enable / disable memory store
    stats                database statistics
    flush                flush database
    dbsize [val]         get [set] database size (# of records)
    watch                print new messages as they arrive
    stop                 stop watching for new messages
    raw                  use raw format for printing messages
    std                  use standard format for printing messages
    *                    show all log messages
    * key val            equality search for messages (single key/value pair)
    * op key val         search for matching messages (single key/value pair)
    * [op key val] ...   search for matching messages (multiple key/value pairs)
                         operators:  =  <  >  ! (not equal)  T (key exists)  R (regex)
                         modifiers (must follow operator):
                                 C=casefold  N=numeric  S=substring  A=prefix  Z=suffix
```

几种常见的过滤查询，也就是 `* key val` 指令。  
- 根据 bundle id 过滤查询  

    ```
    * Facility com.apple.springboard
    May 14 14:45:30 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Disabling lock screen media controls updates for screen turning off.
    May 14 14:45:31 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Updating supported commands for now playing application.
    May 14 14:47:28 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Enabling lock screen media controls updates for screen turning on.
    May 14 14:47:28 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Updating supported commands for now playing application.
    ```

- 根据 进程 id 过滤查询  

    ```
    * PID 639
    May 14 14:49:34 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Disabling lock screen media controls updates for screen turning off.
    May 14 14:49:35 dzy-re SpringBoard[639] <Warning>: [MPUSystemMediaControls] Updating supported commands for now playing application.
    May 14 14:57:07 dzy-re SpringBoard[639] <Warning>: WiFi is associated NO
    May 14 14:57:07 dzy-re SpringBoard[639] <Warning>: WiFi is associated NO
    ```  

- 根据 日志内容 查询  

    **这里似乎必须输入完整的信息，笔者最开始就是输入的 Message iOSRE，结果为nil**  

    ```
    * Message iOSRE: saveScreenshot: is called
    May 14 14:23:53 dzy-re SpringBoard[639] <Warning>: iOSRE: saveScreenshot: is called
    May 14 14:23:55 dzy-re SpringBoard[639] <Warning>: iOSRE: saveScreenshot: is called
    ```  

- 全部的过滤条件  

    ```
    ASLMessageID, //asl消息id
    Level, //级别
    Time, //时间
    TimeNanoSec, //时间ns
    Sender, //消息的发送者
    Facility, //按照Bundle ID来过滤日志
    PID, //进程id
    Message, //消息内容
    ReadUID //读取所使用的用户id
    ```  

- 多条件查询  
    笔者表示试了半天也没试出来怎么多条件查询，，有大佬能指点一下么。