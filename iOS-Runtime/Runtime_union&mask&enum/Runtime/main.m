//
//  main.m
//  Runtime
//
//  Created by dzy_PC on 2020/11/14.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Person3.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person3 * p = [Person3 new];
        [p setTall:YES];
        [p setRich:NO];
        [p sethds:YES];
        
        /*
         // 打印指针内容
         (lldb) p/x p->_tallRichHds;
         ((anonymous struct)) $0 = (tall = 0x00, rich = 0x01, hds = 0x01)
         
         // 打印指针地址
         (lldb) p/x &(p->_tallRichHds);
         ((anonymous struct) *) $1 = 0x000000010042b838
         
         // 打印对应地址内容
         (lldb) x 0x000000010042b838
         0x10042b838: 06 00 00 00 00 00 00 00 2d 5b 4e 53 54 61 62 6c  ........-[NSTabl
         0x10042b848: 65 56 69 65 77 41 63 74 69 6f 6e 42 75 74 74 6f  eViewActionButto
         */
        NSLog(@"tall: %d, rich: %d, hds: %d", p.isTall, p.isRich, p.isHds);
        
        
        // 枚举的多重使用
        Person * per = [Person new];
        [per setOptions: OptionOne | OptionThree];
    }
    return 0;
}
