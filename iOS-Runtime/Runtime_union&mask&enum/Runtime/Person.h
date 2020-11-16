//
//  Person.h
//  Runtime
//
//  Created by dzy_PC on 2020/11/16.
//

/**
  掩码最基本的用法
 */

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    OptionOne = 1<<0,
    OptionTwo = 1<<1,
    OptionThree = 1<<2,
} DzyOptions;

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

- (void)setRich:(BOOL)rich;
- (void)setTall:(BOOL)tall;
- (void)sethds:(BOOL)hds;

- (BOOL)isTall;
- (BOOL)isRich;
- (BOOL)isHds;

- (void)setOptions:(DzyOptions)options;

@end

NS_ASSUME_NONNULL_END
