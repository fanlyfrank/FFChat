//
//  FFAudioClient.m
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 FF. All rights reserved.
//

#import "FFAudioClient.h"
#import "lame.h"

typedef NS_ENUM(NSInteger, FFAudioClientStatus) {
    FFAudioClientStatusNormal,
    FFAudioClientStatusRecording,
    FFAudioClientStatusPlaying,
};

@interface FFAudioClient () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) FFAudioClientStatus status;

@property (strong, nonatomic) NSMutableArray *sendingAudios;

@property (nonatomic) BOOL isFinishConvert;
@property (nonatomic) BOOL isStopRecorde;

@property (strong, nonatomic) NSString *mp3FileName;

@end

@implementation FFAudioClient

+ (instancetype)sharedAudioClient {
    
    static id audioClient;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        audioClient = [[self alloc] init];
    });
    
    return audioClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _sampleRate = 44100;
        _quality = AVAudioQualityLow;
    }
    return self;
}

- (void)startRecorderAudio {

    self.isFinishConvert = NO;
    self.isStopRecorde = NO;
    
    //start audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    BOOL success;
    NSError *sessionError;
    
    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (!success) NSLog(@"error creating session: %@", [sessionError description]);
    
    success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError];
    
    if (!success) NSLog(@"error override output audio port: %@", [sessionError description]);
    
    [audioSession setActive:YES error:nil];
   
    if (!success) {
        NSLog(@"error creating session: %@", [sessionError description]);
        abort();
    }
    
    //init audio recorder
    NSError *recorderError;
    
    NSURL *tempFile =
    [NSURL fileURLWithPath:[NSTemporaryDirectory()
           stringByAppendingString:@"VoiceInputFile"]];
    
    NSDictionary *settings =
    @{AVSampleRateKey:@44100,
      AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
      AVNumberOfChannelsKey:@2,
      AVEncoderAudioQualityKey:[NSNumber numberWithInt:self.quality]};
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:tempFile settings:settings error:&recorderError];
    if (recorderError) {
        NSLog(@"error creating avaudiorecorder: %@", [recorderError description]);
        abort();
    }
    
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    self.status = FFAudioClientStatusRecording;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.2
                      target:self selector:@selector(recordTimerUpdate)
                      userInfo:nil repeats:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self conventToMp3];
    });
}

- (NSString *)endRecord {
    
    [self.timer invalidate];
    
    if (!self.recorder) {
        NSLog(@"what are you fucking doing? you need start first then you can stop, ok!");
        return nil;
    }
    
    self.status = FFAudioClientStatusNormal;
    
    [self.recorder stop];
    
    self.isStopRecorde = YES;
    
    while (!self.isFinishConvert) {
        NSLog(@"wait convent finish");
    }
    
    return self.mp3FileName;
}

- (void)cancleRecord {
    
    [self.timer invalidate];
    
    if (!self.recorder) {
        NSLog(@"what are you fucking doing? you need start first then you can stop, ok!");
        return;
    }
    
    self.status = FFAudioClientStatusNormal;
    
    [self.recorder stop];
    
}

- (void)playAudioWithURL:(NSURL *)audioSource {

    NSError *playerError;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioSource error:&playerError];
    
    if (playerError) {
        NSLog(@"error creating player : %@", [playerError description]);
        return;
    }
    
    self.player.delegate = self;
    self.player.meteringEnabled = YES;
    [self.player prepareToPlay];
    [self.player play];
    
    self.status = FFAudioClientStatusPlaying;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.2
                                              target:self
                                            selector:@selector(playTimerUpdate)
                                            userInfo:nil
                                             repeats:YES];
}

#pragma mark - avaudioplayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    self.status = FFAudioClientStatusNormal;
    [self.timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClientDidFinishPlaying:)]) {
        [self.delegate audioClientDidFinishPlaying:self];
    }
}

#pragma mark - private mehtods
- (void)conventToMp3 {
    
    NSLog(@"convert begin!!");
    
    NSString *cafFilePath = [NSTemporaryDirectory() stringByAppendingString:@"VoiceInputFile"];
    _mp3FileName = [[NSUUID UUID] UUIDString];
    self.mp3FileName = [self.mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:self.mp3FileName];
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, self.sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long curpos;
        BOOL isSkipPCMHeader = NO;
        
        do {
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //skip audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
                    //FFLog(@"skip pcm file header !!!!!!!!!!");
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                //FFLog(@"read %d bytes", write);
            }
            
            else {
                
                [NSThread sleepForTimeInterval:0.05];
                //FFLog(@"sleep");
                
            }
            
        } while (!self.isStopRecorde);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
        
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
        NSLog(@"read %d bytes and flush to mp3 file", write);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        self.isFinishConvert = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    @finally {
        NSLog(@"convert mp3 finish!!!");
    }
}

- (void)recordTimerUpdate {
    
    [self.recorder updateMeters];
    
    float power = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClient:didRecordingWihtMetering:)]) {
        [self.delegate audioClient:self didRecordingWihtMetering:power];
    }
}

- (void)playTimerUpdate {
    
    [self.player updateMeters];
    
    float power = pow(10, (0.05 * [self.player peakPowerForChannel:0]));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClient:didPlayingWihtMetering:)]) {
        [self.delegate audioClient:self didPlayingWihtMetering:power];
    }
}

@end
