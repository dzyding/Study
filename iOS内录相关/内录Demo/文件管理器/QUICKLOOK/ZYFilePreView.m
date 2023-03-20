//
//  ZYFilePreView.m
//  WisdomClass
//
//  Created by 朱岩 on 17/5/15.
//  Copyright © 2017年 TELIT. All rights reserved.
//

#import "ZYFilePreView.h"
#import <QuickLook/QuickLook.h>
#import "ZYPreviewItem.h"

@interface ZYFilePreView ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (nonatomic ,copy)NSString *filePath;
@property (nonatomic ,strong)UIViewController   *VC;
@property (nonatomic ,retain)UIDocumentInteractionController *documentVc;
@property (nonatomic ,strong)NSMutableArray *previewItemArray;

@end


/**
 本地文件预览管理类。
 */
@implementation ZYFilePreView


+(ZYFilePreView*)shareFilePreview{
    static ZYFilePreView *filePreviewManager =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filePreviewManager=[[ZYFilePreView alloc] init];
    });
    return filePreviewManager;
}



- (void)quickLookWithPathArray:(nonnull NSArray<NSString*>*)pathArray titleArray:(nullable NSArray<NSString*>*)titleArray ViewController:(UIViewController*)VC isPush:(BOOL)isPush
{
    self.previewItemArray=[NSMutableArray new];
    for (int i=0; i<pathArray.count; i++) {
        NSURL *url=[NSURL fileURLWithPath:pathArray[i]];
        if (!titleArray) {
            ZYPreviewItem *itemP=[ZYPreviewItem previewItemWithURL:url title:nil];
            [self.previewItemArray addObject:itemP];
        }else{
            ZYPreviewItem *itemP=[ZYPreviewItem previewItemWithURL:url title:titleArray[i]];
            [self.previewItemArray addObject:itemP];
        }
        
        
    }
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    QLPreviewController *QlPreViewController = [[QLPreviewController alloc]init];
    QlPreViewController.delegate =self;
    QlPreViewController.dataSource =self;
    QlPreViewController.view.frame=CGRectMake(0, 0, size.width, size.height);
    
    if (isPush)
    {
         [VC.navigationController pushViewController:QlPreViewController animated:true];
    }else
    {
        QlPreViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [VC presentViewController:QlPreViewController animated:true completion:nil];
    }
    
    [QlPreViewController setCurrentPreviewItemIndex:0];
}



#pragma mark --QLPreview delegate && dataScource ---

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController*)previewController {
    return self.previewItemArray.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return self.previewItemArray[index];
}









@end
