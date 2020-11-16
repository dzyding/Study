//
//  Person.m
//  Runtime
//
//  Created by dzy_PC on 2020/11/16.
//

/*
#define DzyTallMask 1
#define DzyRichMask 2
#define DzyHdsMask 4

#define DzyTallMask 0b00000001
#define DzyRichMask 0b00000010
#define DzyHdsMask 0b00000100
**/

// 三种定义方式是等同的，这里推荐使用这种
// 注意这里需要用小括号括一下，使用起来更安全，不然容易导致语意错误
#define DzyTallMask (1<<0)
#define DzyRichMask (1<<1)
#define DzyHdsMask (1<<2)


#import "Person3.h"

@interface Person3()
{
    // 共用体 （它包含的所有类型共用一个内存地址，以其中最大类型的 size 作为其大小）
    union{
        char bits;
        
        // 共用体里面的这个 struct 没有实际作用，只是用来方便阅读的
        struct {
            char tall : 1;
            char rich : 1;
            char hds : 1;
        };
    } _tallRichHds;
}
@end

@implementation Person3

- (instancetype)init
{
    self = [super init];
    if (self) {
        /**
            从右到左
            tall = false
            rich = false
            hds = true
         */
        _tallRichHds.bits = 0b00000100;
    }
    return self;
}

- (void)setTall:(BOOL)tall
{
    if (tall) { // 或(|)操作
        _tallRichHds.bits |= DzyTallMask;
    }else { // 对掩码取反(~)并进行与(&)操作
        _tallRichHds.bits &= ~DzyTallMask;
    }
}

- (void)setRich:(BOOL)rich
{
    if (rich) {
        _tallRichHds.bits |= DzyRichMask;
    }else {
        _tallRichHds.bits &= ~DzyRichMask;
    }
}

- (void)sethds:(BOOL)hds
{
    if (hds) {
        _tallRichHds.bits |= DzyHdsMask;
    }else {
        _tallRichHds.bits &= ~DzyHdsMask;
    }
}

// 这里 & Mask 以后是一个类似 0b00000010 的二进制数字，或者说是一个普通十进制数字，所以需要取两次非(!!)转成对应的BOOL值
- (BOOL)isTall
{
    return !!(_tallRichHds.bits & DzyTallMask);
}

- (BOOL)isRich
{
    return !!(_tallRichHds.bits & DzyRichMask);
}

- (BOOL)isHds
{
    return !!(_tallRichHds.bits & DzyHdsMask);
}


@end
