//
//  Person.h
//  Runtime
//
//  Created by dzy_PC on 2020/11/16.
//

/**
  苹果官方的用法
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person3 : NSObject

- (void)setRich:(BOOL)rich;
- (void)setTall:(BOOL)tall;
- (void)sethds:(BOOL)hds;

- (BOOL)isTall;
- (BOOL)isRich;
- (BOOL)isHds;

@end

NS_ASSUME_NONNULL_END
