//
//  IOSSpeechRecognizer.m
//  RNAsr
//
//  Created by YangJiang on 2020/5/17.
//

#import "IOSSpeechRecognizer.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0

//API_AVAILABLE(ios(10.0))
@interface IOSSpeechRecognizer()<SFSpeechRecognizerDelegate>

@property (strong, nonatomic)SFSpeechRecognitionTask *recognitionTask;
@property (strong, nonatomic)SFSpeechRecognizer *speechRecognizer;
@property (strong, nonatomic)SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (strong, nonatomic)AVAudioEngine *audioEngine;

@property (nonatomic, strong) id<RecognitionListener> listener;
@property (strong, nonatomic) NSString * lastPart;

@end

@implementation IOSSpeechRecognizer

#pragma mark - SpeechRecognizerProtocol

- (instancetype)init:(nonnull id<RecognitionListener>)listener {
    if (self = [super init]) {
        self.listener = listener;
    }
    return self;
}

- (instancetype)initWithOptions:(nonnull id<RecognitionListener>)listener options:(nullable NSDictionary<NSString*, id> *)options {
    if (self = [super init]) {
        self.listener = listener;
    }
    return self;
}

- (void)start:(nullable NSDictionary<NSString*, id> *)options {
    [self requestPermissions:^{
        // 取消上次的识别任务
        [self cancel];
        
        if (![self isSupportRecoding]) {
            return;
        }
        self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
        self.recognitionRequest.shouldReportPartialResults = true;
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        
        //-----开始识别任务------
        [self.listener onRecordingStart];
        self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            // onError
            if (error) {
                NSLog(@"IOSSpeechRecognizer: oneError->%@", error);
                RecognitionResult *rst = [[RecognitionResult alloc]init];
                // 返回临时结果
                if (self.lastPart) {
                    rst.finalRst = self.lastPart;
                    [self.listener onResult:rst];
                // 返回错误信息
                } else {
                    rst.type = (int) error.code;
                    rst.errorRst = error.localizedDescription;
                    [self.listener onError:rst];
                }
            }
            
            // onResult
            bool isFinal = false;
            if (result) {
                NSString * bestString = [[result bestTranscription] formattedString];
                isFinal = [result isFinal];
                if (isFinal) {
                    RecognitionResult *rst = [[RecognitionResult alloc]init];
                    rst.originalRst = [bestString copy];
                    rst.finalRst = [bestString copy];
                    [self.listener onResult:rst];
                    NSLog(@"IOSSpeechRecognizer: onFullResult->%@", bestString);
                } else {
                    self.lastPart = bestString;
                    NSLog(@"IOSSpeechRecognizer: onPartResult->%@", bestString);
                }
            }
            // reset
            if (error || isFinal) {
                [self.audioEngine stop];
                [inputNode removeTapOnBus:0];
                self.recognitionRequest = nil;
                self.recognitionTask = nil;
//                self.partRst = nil;
            }
        }];
        
        AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
        [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            [self.recognitionRequest appendAudioPCMBuffer:buffer];
        }];
        [self.audioEngine prepare];
        bool audioEngineBool = [self.audioEngine startAndReturnError:nil];
        if (!audioEngineBool) {
            // 打开录音失败
            RecognitionResult *rst = [[RecognitionResult alloc]init];
            rst.type = RTSpeechErrorTypeAudioStartError;
            rst.errorRst = @"Failed to open recording";
            [self.listener onError:rst];
        }
    }];
}

- (void)cancel {
    NSLog(@"IOSSpeechRecognizer: cancel");
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
         self.recognitionTask = nil;
    }
    self.lastPart = nil;
}

- (void)stop {
    NSLog(@"IOSSpeechRecognizer: stop");
    [self.recognitionRequest endAudio];
}

#pragma mark - private methods

- (void)requestPermissions:(void(^)(void))startRecording {
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        RecognitionResult *rst = [[RecognitionResult alloc]init];
        switch (status) {
           case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"IOSSpeechRecognizer: 可以语音识别");
                startRecording();
                break;
           case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"IOSSpeechRecognizer: 用户被拒绝访问语音识别");
                rst.type = RTSpeechErrorTypeUserRefuse;
                rst.errorRst = @"Speech recognizer authorization status denied";
                [self.listener onError:rst];
                break;
           case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"IOSSpeechRecognizer: 不能在该设备上进行语音识别");
                rst.type = RTSpeechErrorTypeNoNotPossible;
                rst.errorRst = @"Speech recognizer authorization status restricted";
                [self.listener onError:rst];
                break;
           case SFSpeechRecognizerAuthorizationStatusNotDetermined:
           default:
                NSLog(@"IOSSpeechRecognizer: 没有授权语音识别");
                rst.type = RTSpeechErrorTypeNoPermission;
                rst.errorRst = @"Speech recognizer authorization status not determined";
                [self.listener onError:rst];
                break;
        }
    }];
}

// 判断当前设备是否支持录音
- (BOOL)isSupportRecoding {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    bool audioBool = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    bool audioBool1 = [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    bool audioBool2 = [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (audioBool || audioBool1 || audioBool2) {
        return true;
    }
    // 这里说明有的功能不支持, 提示不支持语音功能
    RecognitionResult *rst = [[RecognitionResult alloc]init];
    rst.type = RTSpeechErrorTypeNoNotPossible;
    rst.errorRst = @"Recording is not supported on the current device";
    [self.listener onError:rst];
    return false;
}

#pragma mark - Delegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"IOSSpeechRecognizer: available->%d", available);
    if (!available) {
        // 识别器变得不可用，停止录音
        [self stop];
//        [self.listener onVadTimeout];
    }
}

#pragma mark - Lazy
- (SFSpeechRecognizer *)speechRecognizer {
    if (_speechRecognizer == nil){
        NSLocale *cale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-CN"];
        _speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:cale];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}

- (AVAudioEngine *)audioEngine {
    if (_audioEngine == nil) {
        _audioEngine = [[AVAudioEngine alloc]init];
    }
    return _audioEngine;
}

@end

#endif
