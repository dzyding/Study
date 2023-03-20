//
//  ZYPreviewItem.m
//  WisdomClass
//
//  Created by 朱岩 on 17/6/15.
//  Copyright © 2017年 TELIT. All rights reserved.
//

#import "ZYPreviewItem.h"

@implementation ZYPreviewItem

+ (ZYPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title
{
    ZYPreviewItem *instance = [[ZYPreviewItem alloc] init];
    instance.previewItemURL = URL;
    instance.previewItemTitle = title;
    return instance;
}


@end
