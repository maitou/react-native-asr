//
//  RNAsr.m
//  RNAsr
//
//  Created by YangJiang on 2020/5/14.
//

#import "RNAsr.h"
#import "AsrProtocol.h"
//#import "asrios/IOSSpeechRecognizer.h"
#import "asrifly/IFLYSpeechRecognizer.h"

// 错误码
NSString* const ERROR_BUSY = @"-1";
NSString* const ERROR_MANUAL = @"-2";
NSString* const ERROR_OPTION = @"-3";

@interface RNAsr ()<RecognitionListener>

// 私有属性
@property (nonatomic, strong) id<SpeechRecognizer> speechRecognizer;
@property (nonatomic) AsrStatus status;

@property (nonatomic, copy) RCTPromiseResolveBlock resolve;
@property (nonatomic, copy) RCTPromiseRejectBlock reject;

@end

@implementation RNAsr

RCT_EXPORT_MODULE(RNAsr)

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (instancetype)init {
    if (self = [super init]) {
        // 当初始化模块时，初始化讯飞识别框架
//        [IFLYSpeechRecognizer initUtility];
        dispatch_async(dispatch_queue_create("com.retu.asr.initIflyQueue", NULL), ^{
            [IFLYSpeechRecognizer initUtility];
        });
    }
    return self;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (void)initRecognizer:(NSDictionary *)options {
    // 云知声语音识别器，云知声SDK不适合当前新版本编译方式，暂时不可用
//     self.speechRecognizer = [[UniSpeechRecognizer alloc] initWithOptions:self options:options];
    // IOS自带语音识别器
//    self.speechRecognizer = [[IOSSpeechRecognizer alloc] initWithOptions:self options:options];
    // 讯飞语音识别器    
    self.speechRecognizer = [[IFLYSpeechRecognizer alloc] initWithOptions:self options:options];
}

/**
 * 开始语音识别
 */
RCT_EXPORT_METHOD(start:(NSDictionary *)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    // 初始化语音识别器，只初始化一次
    if (!self.speechRecognizer) {
        [self initRecognizer:options];
    }
    // 开始录音
    if (self.status == RECORDING) {
        reject(ERROR_BUSY, @"Recording in progress", nil);
    } else if (self.status == RECOGNIZING) {
        reject(ERROR_BUSY, @"Recognizing in progress", nil);
    } else {
        self.resolve = resolve;
        self.reject = reject;
        [self.speechRecognizer start:options];
    }
}

/**
 * 取消语音识别
 */
RCT_EXPORT_METHOD(cancel: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    if (self.speechRecognizer) {
        [self.speechRecognizer cancel];
    }
    self.status = IDLE;
    resolve(nil);
    if (self.reject) {
        self.reject(ERROR_MANUAL, @"Cancel", nil);
    }
    self.resolve = nil;
    self.reject = nil;
}

/**
 * 停止语音识别
 */
RCT_EXPORT_METHOD(stop: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    if (self.speechRecognizer) {
        [self.speechRecognizer stop];
    }
    resolve(nil);
}

/**
 * 销毁语音识别对象
 */
RCT_EXPORT_METHOD(destory: (RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    if (self.speechRecognizer) {
        BOOL ret = [self.speechRecognizer destroy];
        resolve(ret ? @"TRUE" : @"FALSE");
    }
    resolve(@"TRUE");
}

#pragma mark - RecognitionListener

- (void)onVadTimeout {
    // 用户停止说话
    [self.speechRecognizer stop];
}

- (void)onRecordingStart {
    self.status = RECORDING;
}

- (void)onRecordingStop {
    self.status = RECOGNIZING;
}

- (void)onNetEnd {
    self.status = IDLE;
}

- (void)onError:(nonnull RecognitionResult *)result {
    NSLog(@"RNAsr: onError -> %@", [result getCurrentRst]);
    if (self.reject) {
        self.reject([NSString stringWithFormat:@"%d", result.type], [result getCurrentRst], nil);
    }
    self.resolve = nil;
    self.reject = nil;
    self.status = IDLE;
}

- (void)onResult:(nonnull RecognitionResult *)result {
    NSLog(@"RNAsr: onResult -> %@", [result getCurrentRst]);
    if (self.resolve) {
        self.resolve([result getCurrentRst]);
    }
    self.resolve = nil;
    self.reject = nil;
    self.status = IDLE;
}

@end
