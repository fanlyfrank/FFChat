//
//  FFAudioClient.h
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class FFAudioClient;

@protocol FFAudioClientDelegate <NSObject>

@optional
//use to make a animation
- (void)audioClient:(FFAudioClient *)client didRecordingWihtMetering:(CGFloat)metering;
- (void)audioClient:(FFAudioClient *)client didPlayingWihtMetering:(CGFloat)metering;
- (void)audioClientDidFinishPlaying:(FFAudioClient *)client;

@end

@interface FFAudioClient : NSObject

@property (weak, nonatomic) id<FFAudioClientDelegate> delegate;

@property (nonatomic) CGFloat sampleRate;
@property (nonatomic) AVAudioQuality quality;

//do not use init, use this to get singelton client
+ (id)sharedAudioClient;

- (void)startRecorderAudio;
- (NSString *)endRecord;
- (void)cancleRecord;
- (void)playAudioWithURL:(NSURL *)audioSource;

@end
