//
//  Person.m
//  Runtime
//
//  Created by dzy_PC on 2020/11/16.
//

#import "Person2.h"

@interface Person2()
{
    // 位域的基本用法
    // 这里的 1 代表只占 1 位，1 个字节 8 位，也就是这个整体一个字节
    // 从最右边往左边排列，也就是 tall 是最右边的那一位
    struct{
        char tall : 1;
        char rich : 1;
        char hds : 1;
    } _tallRichHds;
}
@end

@implementation Person2

- (void)setTall:(BOOL)tall
{
    _tallRichHds.tall = tall;
}

- (void)setRich:(BOOL)rich
{
    _tallRichHds.rich = rich;
}

- (void)sethds:(BOOL)hds
{
    _tallRichHds.hds = hds;
}

/**
 这里的 YES 会被打印成 -1，主要是因为 p.isTall 之类的，他们其实只取了一位，但是被强制转换成了一个八位的 BOOL 类型
 比如 0b0000 0001，我们这里相当于只取了最后一个 1，却被强行转换成了一个 8 位的 BOOL 类型
 由于系统机制，它会被默认补全成一个 0b1111 1111 来替代哪个只有一位的 1
 
 所以我们进行两次 BOOL 的取反操作，来把它变成对应的 BOOL 值
 */
- (BOOL)isTall
{
    return !!_tallRichHds.tall;
}

- (BOOL)isRich
{
    return !!_tallRichHds.rich;
}

- (BOOL)isHds
{
    return !!_tallRichHds.hds;
}


@end
