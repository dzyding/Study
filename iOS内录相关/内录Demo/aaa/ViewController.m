//
//  ViewController.m
//  aaa
//
//  Created by EkiSong on 2020/7/4.
//  Copyright © 2020 EkiSong. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
#import "ExtensionDataManager.h"
#import "TJFileViewController.h"

ExtensionDataManager *_dataMgr;

@interface ViewController ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backIden;

@property (nonatomic, strong) IBOutlet UIButton *startBtn;
@property (nonatomic, strong) NSFileHandle *filehandle;
@property (weak, nonatomic) IBOutlet UIButton *sourceAppBtn;
@property (weak, nonatomic) IBOutlet UIButton *sourceMicBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self ios12Action];
    [self initBtns];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackGround) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod, CFSTR("AAA_START_SCREEN_SHARE"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod, CFSTR("AAA_END_SCREEN_SHARE"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)dealloc {
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterRemoveEveryObserver(notification, (__bridge const void *)(self));
}

void observerMethod (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString *nameStr = (__bridge NSString *)name;
    if ([nameStr isEqualToString:@"AAA_START_SCREEN_SHARE"]) {
        _dataMgr = [[ExtensionDataManager alloc] init];
        [_dataMgr startLoad];
        [_dataMgr loadWhenWrite];
    }else if ([nameStr isEqualToString:@"AAA_END_SCREEN_SHARE"]) {
        [_dataMgr stopLoad];
    }
}

- (void)didEnterBackGround {
    //保证进入后台后App依然能得到时间处理
    __weak typeof(self) weakSelf = self;
    self.backIden = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[UIApplication sharedApplication] endBackgroundTask:strongSelf.backIden];
        strongSelf.backIden = UIBackgroundTaskInvalid;
    }];
}

#pragma mark Extension

- (void)ios12Action {
    RPSystemBroadcastPickerView *picker = [[RPSystemBroadcastPickerView alloc] initWithFrame:self.startBtn.frame];
    if (@available(iOS 12.2, *)) {
        picker.preferredExtension = @"dzy.GetCurrentAudioDemo.GcadShare";
    }
    [self.view addSubview:picker];
    [self.view bringSubviewToFront:self.startBtn];
}

- (void)initBtns {
    [self.sourceAppBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sourceAppBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [self.sourceMicBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sourceMicBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    [self.sourceAppBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)fileListAction:(id)sender {
    TJFileViewController *fileListVc = [[TJFileViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:fileListVc];
    [self presentViewController:navi animated:true completion:nil];
}

- (IBAction)sourceAppAction:(id)sender {
    self.sourceAppBtn.selected = true;
    self.sourceMicBtn.selected = false;
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.GcadShare"];
    [userDefault setValue:@1 forKey:@"AAA_Source"];
}

- (IBAction)sourceMicAction:(id)sender {
    self.sourceAppBtn.selected = false;
    self.sourceMicBtn.selected = true;
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.GcadShare"];
    [userDefault setValue:@0 forKey:@"AAA_Source"];
}

- (ExtensionDataManager *)dataMgr {
    if (!_dataMgr) {
        _dataMgr = [[ExtensionDataManager alloc] init];
    }
    return _dataMgr;
}



@end
