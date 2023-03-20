//
//  ZYPreviewItem.h
//  WisdomClass
//
//  Created by 朱岩 on 17/6/15.
//  Copyright © 2017年 TELIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface ZYPreviewItem : NSObject<QLPreviewItem>


/**
重写QLPreviewItem 进行更改显示标题，
 
 @param URL <#URL description#>
 @param title <#title description#>
 @return <#return value description#>
 */
+ (ZYPreviewItem *)previewItemWithURL:(NSURL *)URL title:(NSString *)title;

@property (nonatomic, readwrite ,strong) NSURL *previewItemURL;
@property (nonatomic, readwrite) NSString *previewItemTitle;


@end
