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


#import "Person.h"

@interface Person()
{
    // char 类型就是一个字节
    char _tallRichHds;
}
@end

@implementation Person

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
        _tallRichHds = 0b00000100;
    }
    return self;
}

- (void)setTall:(BOOL)tall
{
    if (tall) { // 或(|)操作
        _tallRichHds |= DzyTallMask;
    }else { // 对掩码取反(~)并进行与(&)操作
        _tallRichHds &= ~DzyTallMask;
    }
}

- (void)setRich:(BOOL)rich
{
    if (rich) {
        _tallRichHds |= DzyRichMask;
    }else {
        _tallRichHds &= ~DzyRichMask;
    }
}

- (void)sethds:(BOOL)hds
{
    if (hds) {
        _tallRichHds |= DzyHdsMask;
    }else {
        _tallRichHds &= ~DzyHdsMask;
    }
}

// 这里 & Mask 以后是一个类似 0b00000010 的二进制数字，或者说是一个普通十进制数字，所以需要取两次非(!!)转成对应的BOOL值
- (BOOL)isTall
{
    return !!(_tallRichHds & DzyTallMask);
}

- (BOOL)isRich
{
    return !!(_tallRichHds & DzyRichMask);
}

- (BOOL)isHds
{
    return !!(_tallRichHds & DzyHdsMask);
}

- (void)setOptions:(DzyOptions)options {
    if (options & OptionOne) {
        NSLog(@"包含OptionOne");
    }
    if (options & OptionTwo) {
        NSLog(@"包含OptionTwo");
    }
    if (options & OptionThree) {
        NSLog(@"包含OptionThree");
    }
}

@end
