//
//  IFLYSpeechRecognizer.m
//  RNAsr
//
//  Created by YangJiang on 2020/5/18.
//

#import "IFLYSpeechRecognizer.h"
#import "IFlyMSC/IFlyMSC.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"

/**
 * 记录当前的讯飞识别套件是否初始化，其只需要初始化一次
 */
static BOOL IS_INIT = FALSE;

@interface IFLYSpeechRecognizer()<IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) id<RecognitionListener> listener;
@property (nonatomic, strong) NSMutableString *curResult; // the results of current session

@end

@implementation IFLYSpeechRecognizer

#pragma mark - static methods
/**
 * 初始化讯飞识别套件
 */
+ (void)initUtility {
    if (IS_INIT) {
        return;
    }
    IS_INIT = TRUE;
    
    //Set log level
    [IFlySetting setLogFile:LVL_ALL];

    //Set whether to output log messages in Xcode console
    [IFlySetting showLogcat:YES];

    //Set the local storage path of SDK
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];

    //Set APPID
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", [IATConfig appId]];
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark - SpeechRecognizer
- (nonnull instancetype)init:(nonnull id<RecognitionListener>)listener {
    if (self = [super init]) {
        self.listener = listener;
        [self setupSpeech:nil];
    }
    return self;
}

- (nonnull instancetype)initWithOptions:(nonnull id<RecognitionListener>)listener options:(nullable NSDictionary<NSString *,id> *)options {
    if (self = [super init]) {
        self.listener = listener;
        [self setupSpeech:options];
    }
    return self;
}

- (void)start:(nullable NSDictionary<NSString *,id> *)options {
    [self setOptions:options];
    [self reset];
    BOOL ret = [_iFlySpeechRecognizer startListening];
    NSLog(@"IFLYSpeechRecognizer: start->%@", ret ? @"YES" : @"NO");
    if (!ret) {
        RecognitionResult *rst = [[RecognitionResult alloc]init];
        rst.errorRst = @"Start speech recognizer failed!";
        [self.listener onError:rst];
    }
}

- (void)cancel {
//    [IFlySpeechRecognizer.sharedcfg cancel];
    [_iFlySpeechRecognizer cancel];
}

- (void)stop {
//    [IFlySpeechRecognizer.sharedcfg stopListening];
    [_iFlySpeechRecognizer stopListening];
}

- (BOOL)destroy {
    if (_iFlySpeechRecognizer) {
        [_iFlySpeechRecognizer cancel];
        return [_iFlySpeechRecognizer destroy];
    }
    return TRUE;
}

#pragma mark - private methods

/**
 * 设置及初始化识别器
 *
 * @param options 需要设置的参数
 */
- (void)setupSpeech:(NSDictionary<NSString*, NSString*> *)options {
    [self createRecognizer];
    [self setOptions:options];
}

/**
 * 创建识别器并设置默认参数
 */
- (void)createRecognizer {
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    IATConfig *cfg = [IATConfig sharedInstance];
    //set timeout of recording
    [_iFlySpeechRecognizer setParameter:cfg.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //set VAD timeout of end of speech(EOS)
    [_iFlySpeechRecognizer setParameter:cfg.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //set VAD timeout of beginning of speech(BOS)
    [_iFlySpeechRecognizer setParameter:cfg.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //set network timeout
    [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    //set sample rate, 16K as a recommended option
    [_iFlySpeechRecognizer setParameter:cfg.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    //set language
    [_iFlySpeechRecognizer setParameter:cfg.language forKey:[IFlySpeechConstant LANGUAGE]];
    //set accent
    [_iFlySpeechRecognizer setParameter:cfg.accent forKey:[IFlySpeechConstant ACCENT]];
    //set whether or not to show punctuation in recognition results
    [_iFlySpeechRecognizer setParameter:cfg.dot forKey:[IFlySpeechConstant ASR_PTT]];
    
    //Set microphone as audio source
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //Set result type
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
//    //Set the audio name of saved recording file while is generated in the local storage path of SDK,by default in library/cache.
//    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    _iFlySpeechRecognizer.delegate = self;
}

/**
 * 为识别器设置参数
 *
 * @param options 需要设置的参数
 */
- (void)setOptions:(nonnull NSDictionary<NSString*, NSString*> *)options {
    [options enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            [_iFlySpeechRecognizer setParameter:obj forKey:key];
        } else {
            // 不支持的类型
            NSLog(@"The key value of an optional parameter must be a numeric value or numeric character");
        }
    }];
}

/**
 * 充值参数
 */
- (void)reset {
    [self cancel];
    self.curResult = [[NSMutableString alloc]init];
}

#pragma mark - IFlySpeechRecognizerDelegate

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    [self.curResult appendString:[ISRDataHelper stringFromJson:resultString]];
    if (isLast) {
        NSLog(@"IFLYSpeechRecognizer: onResult->%@", self.curResult);
    }
}

- (void)onCompleted:(IFlySpeechError *)error {
    NSLog(@"IFLYSpeechRecognizer: onCompleted->%@", error);
    RecognitionResult *rst = [[RecognitionResult alloc]init];
    rst.type = error.errorCode;
    // 有错误信息
    if (error.errorCode != 0) {
        rst.errorRst = error.errorDesc;
        [self.listener onError:rst];
        return;
    }
    // 无错误信息返回结果
    if (self.curResult.length==0 || [self.curResult hasPrefix:@"nomatch"]) {
        rst.finalRst = @"";
    } else {
        rst.finalRst = _curResult;
    }
    [self.listener onResult:rst];
}

- (void) onVolumeChanged:(int)volume {
//    NSLog(@"IFLYSpeechRecognizer: onVolumeChanged->%d", volume);
//    [self.listener onVolumeChange:volume];
}

- (void) onBeginOfSpeech {
    NSLog(@"IFLYSpeechRecognizer: onBeginOfSpeech");
    [self.listener onRecordingStart];
}

- (void) onEndOfSpeech {
    NSLog(@"IFLYSpeechRecognizer: onEndOfSpeech");
    [self.listener onRecordingStop];
}

- (void) onCancel {
    // do nothing
}

@end
