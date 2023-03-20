//
//  ZYFilePreView.h
//  WisdomClass
//
//  Created by 朱岩 on 17/5/15.
//  Copyright © 2017年 TELIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZYFilePreView : NSObject


+(ZYFilePreView*)shareFilePreview;


- (void)quickLookWithPathArray:(nonnull NSArray<NSString*>*)pathArray titleArray:(nullable NSArray<NSString*>*)titleArray ViewController:(UIViewController*)VC isPush:(BOOL)isPush;


@end
