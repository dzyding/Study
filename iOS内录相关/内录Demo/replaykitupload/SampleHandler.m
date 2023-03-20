//
//  SampleHandler.m
//  replaykitupload
//
//  Created by EkiSong on 2020/7/6.
//  Copyright © 2020 EkiSong. All rights reserved.
//

#import "SampleHandler.h"
#import "ExtensionDataManager.h"

@interface SampleHandler ()

@property (nonatomic, strong)ExtensionDataManager *dataMgr;

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *, NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [self.dataMgr startWrite];
    
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterPostNotification(notification, CFSTR("AAA_START_SCREEN_SHARE"), NULL,NULL, YES);
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.dataMgr endWrite];
    
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(notification, CFSTR("AAA_END_SCREEN_SHARE"), NULL,NULL, YES);
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.GcadShare"];
    NSNumber *source = [userDefault valueForKey:@"AAA_Source"];
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            break;
        case RPSampleBufferTypeAudioApp:
            if (source.intValue == 1) {
                [self getAudioData:sampleBuffer];
            }
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            if (source.intValue == 0) {
                [self getAudioData:sampleBuffer];
            }
            break;

        default:
            break;
    }
}

- (void)getAudioData:(CMSampleBufferRef)sampleBuffer {
    @autoreleasepool {
        // 获取参数
        AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
        
        //获取CMBlockBufferRef
        CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer);
        //获取pcm数据大小
        size_t length = CMBlockBufferGetDataLength(blockBufferRef);
        
        //分配空间
        char buffer[length];
        //直接将数据copy至我们自己分配的内存中
        CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, buffer);
        
        if ((inAudioStreamBasicDescription.mFormatFlags & kAudioFormatFlagIsBigEndian) == kAudioFormatFlagIsBigEndian)
        {
            for (int i = 0; i < length; i += 2)
            {
                char tmp = buffer[i];
                buffer[i] = buffer[i+1];
                buffer[i+1] = tmp;
            }
        }
        // 声道2 码率 44100
//        uint32_t ch = inAudioStreamBasicDescription.mChannelsPerFrame;
//        uint32_t fs = inAudioStreamBasicDescription.mSampleRate;
        
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:length freeWhenDone:false];
        [self.dataMgr writeData:data];
    }
}


- (ExtensionDataManager *)dataMgr {
    if (!_dataMgr) {
        _dataMgr = [[ExtensionDataManager alloc] init];
    }
    return _dataMgr;
}


@end
