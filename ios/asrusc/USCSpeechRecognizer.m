//
//  USCSpeechRecognizer.m
//  RNAsr
//
//  Created by YangJiang on 2020/5/14.
//

#import "USCSpeechRecognizer.h"
#import "../unisound-lib/USCConfigure.h"
#import "../unisound-lib/USCSpeechConstant.h"
#import "../unisound/USCRecorder.h"
#import "../core/RecognitionResult.h"

@implementation USCSpeechRecognizer

- (instancetype)init:(nonnull id<RecognitionListener>)listener {
    if (self = [super init]) {
        self->listener = listener;
        [self setupSpeech:nil];
    }
    return self;
}

- (instancetype)initWithOptions:(nonnull id<RecognitionListener>)listener options:(nullable NSDictionary<NSString*, id> *)options {
    if (self = [super init]) {
        self->listener = listener;
        [self setupSpeech:options];
    }
    return self;
}

- (void)start:(nullable NSDictionary<NSString*, id> *)options {
    [self setOptions:options];
    [speechUnderstander start];
}

- (void)cancel {
    [speechUnderstander cancel];
}

- (void)stop { 
    [speechUnderstander stop];
}

#pragma mark -private methods
- (void)setupSpeech:(NSDictionary<NSString*, id> *)options {
    USCSpeechUnderstander *underStander = [[USCSpeechUnderstander alloc]initWithContext:nil appKey:APPKEY secret: SECRET];
    speechUnderstander = underStander;
    [self setOptions:[self mixOptions:[self defaultOptions] other:options]];
    speechUnderstander.delegate = self;
    [speechUnderstander setAudioSource:[USCRecorder new]];
}

// 设置可选参数，可选参数值为空时设置默认可选参数，可选参数不为空
// 时具有相同的可选参数会覆盖默认参数
- (void)setOptions:(nonnull NSDictionary<NSNumber*, id> *)options {
    [options enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSNumber class]]) {
            [speechUnderstander setOption:[key intValue] value:obj];
        } else if ([key isKindOfClass:[NSString class]]) {
            //TODO: 如果不为数值字符串，则会出现异常，暂时未处理
            [speechUnderstander setOption:[key intValue] value:obj];
        } else {
            // 不支持的类型
            NSLog(@"The key value of an optional parameter must be a numeric value or numeric character");
        }
    }];
}

// 合并默认可选参数和传入的可选参数
- (NSDictionary *)mixOptions:(nonnull NSDictionary<NSString*, id> *)def other:(nullable NSDictionary<NSString*, id> *)other {
    NSMutableDictionary *options = [def mutableCopy];
    if (other != nil) {
        [options setDictionary:other];
    }
    return options;
}

// 获取默认可选参数
- (NSDictionary<NSString *, id> *)defaultOptions {
    NSMutableDictionary *defOpt = [NSMutableDictionary dictionary];
    [defOpt setObject:[NSNumber numberWithInt:USC_ASR_SERVICE_MODE_NET] forKey:[NSString stringWithFormat:@"%d", USC_ASR_SERVICE_MODE]];
    [defOpt setObject:@"false" forKey:[NSString stringWithFormat:@"%d", USC_NLU_ENABLE]];
//    [defOpt setObject:@"false" forKey:[NSString stringWithFormat:@"%d", USC_ASR_OPT_TEMP_RESULT_ENABLE]];
    [defOpt setObject:[NSNumber numberWithInt:USC_ASR_SAMPLING_RATE_BANDWIDTH_AUTO] forKey:[NSString stringWithFormat:@"%d", USC_ASR_SAMPLING_RATE]];
    [defOpt setObject:@"general" forKey:[NSString stringWithFormat:@"%d", USC_ASR_DOMAIN]];
    [defOpt setObject:USC_LANGUAGE_MANDARIN forKey:[NSString stringWithFormat:@"%d", USC_ASR_LANGUAGE]];
    [defOpt setObject:@"300" forKey:[NSString stringWithFormat:@"%d", USC_ASR_VAD_TIMEOUT_FRONTSIL]];
    [defOpt setObject:@"200" forKey:[NSString stringWithFormat:@"%d", USC_ASR_VAD_TIMEOUT_BACKSIL]];
    return defOpt;
}

#pragma mark - RecognitionListener
- (void)onError:(int)type error:(NSError *)error {
    RecognitionResult *rst = [RecognitionResult new];
    rst.type = type;
    // 有错误信息
    if (error) {
        rst.errorRst = error.localizedDescription;
        partRst = nil;
        [listener onError:rst];
        return;
    }
    // 无错误信息，如果有临时结果返回临时结果
    if (partRst && [partRst isTemp]) {
        rst.finalRst = [partRst getCurrentRst];
        partRst = nil;
        [listener onResult:rst];
    }
    // 其它错误信息
    rst.errorRst = @"No sound heard";
    partRst = nil;
    [listener onError:rst];
}

- (void)onEvent:(int)type timeMs:(int)timeMs {
    switch (type) {
//        // 初始化完成
//        case USC_ASR_EVENT_ENGINE_INIT_DONE:
//            [listener onEngineInitDone];
//            break;
//        // 录音准备就绪
//        case USC_ASR_EVENT_RECORDING_PREPARED:
//            [listener onRecordingPrepared];
//            break;
        // 录音设备打开
        case USC_ASR_EVENT_RECORDING_START:
            [listener onRecordingStart];
            break;
        // 用户开始说话
        case USC_ASR_EVENT_SPEECH_DETECTED:
            [listener onSpeechDetected];
            break;
        // 停止录音
        case USC_ASR_EVENT_RECORDING_STOP:
            [listener onRecordingStop];
            break;
        // 收到用户停止说话事件
        case USC_ASR_EVENT_VAD_TIMEOUT:
            [listener onVadTimeout];
            break;
        // 在线识别结束
        case USC_ASR_EVENT_NET_END:
            [listener onNetEnd];
            break;
//        // 识别结束
//        case USC_ASR_EVENT_RECOGNITION_END:
//            [listener onRecognitionEnd];
//            break;
        // 实时返回说话音量
        case USC_ASR_EVENT_VOLUMECHANGE:
            [listener onVolumeChange: [[speechUnderstander getOption:USC_ASR_EVENT_VOLUMECHANGE] intValue]];
        default:
            break;
    }
}

- (void)onResult:(int)type jsonString:(NSString *)jsonString {
    NSLog(@"UniSpeechRecognizer: onResult -> %@", jsonString);
    RecognitionResult *rst = [self parseJsonRst:type jsonString:jsonString];
    if ([rst isFinal]) {
        partRst = nil;
        [listener onResult:rst];
    } else if ([rst isError]) {
        partRst = nil;
        [listener onError:rst];
    } else {
        // 临时识别结果，累计保存到临时结果对象中
        // 当onError方法被触发时，如果存在临时结果则会将临时结果以最终结果一并返回
        if (!partRst) {
            partRst = [RecognitionResult new];
        }
        partRst.type = rst.type;
        [partRst addPartRst: [rst getCurrentRst]];
    }
}

/**
 * 将识别结果字符串解析为结果对象
 *
 * @param jsonString 识别的原始结果字符串
 * @return 解析后的结果对象
 */
- (RecognitionResult *)parseJsonRst:(int)type jsonString:(NSString *)jsonString {
    RecognitionResult *rst = [RecognitionResult new];
    rst.type = type;
    rst.originalRst = jsonString;
    // full result
    if ([self isMultiJson: jsonString]) {
            NSString *rstTxt = [self parseMultiJson: jsonString];
            RecognitionResult *rst = [RecognitionResult new];
            rst.type = type;
            rst.finalRst = rstTxt != nil ? rstTxt : @"";
            [listener onResult:rst];
    // part result
    } else {
        NSString *part = [self parseSingleJson:jsonString];
        if (part) {
            [rst addPartRst:part];
        }
    }
    return rst;
}

/**
 * 判断识别结果是否为多个JSON字符串，如果为多个JSON字符串也就表示为最终结果
 *
 * @param resultStr 识别结果原始文本
 * @return 如果为多个JSON字符串则返回true(也即为最终结果)，否则返回false
 */
- (BOOL)isMultiJson:(NSString *)resultStr {
    NSString *pattern =@"\\}\\{";
    NSError *error = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *match = [reg matchesInString:resultStr options:NSMatchingReportCompletion range:NSMakeRange(0, [resultStr length])];
    return match.count >= 1 ? YES : NO;
}

- (NSString *)parseSingleJson:(NSString *)singleJsonStr {
    NSData *data =  [singleJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return dict && [dict objectForKey:@"asr_recongize"] ? [dict objectForKey:@"asr_recongize"] : nil;
}

/**
 * 从具有多个JSON结果的字符串中，将其合并成一个最终的文本结果
 *
 * @param resultStr 识别结果原始文本
 * @return 解析后的全文本结果
 */
- (NSString *)parseMultiJson:(NSString *)resultStr {
    NSMutableString *fullTxt = [NSMutableString string];
    NSArray<NSString *> *jsonArr = [resultStr componentsSeparatedByString:@"}{"];
    for (int i = 0; i < jsonArr.count; i++) {
        NSMutableString *jsonComponentStr = [[jsonArr objectAtIndex:i] mutableCopy];
        // 第一个
        if (i == 0) {
            [jsonComponentStr appendString:@"}"];
        // 最后一个
        } else if (i == jsonArr.count - 1) {
            [jsonComponentStr insertString:@"{" atIndex:0];
        // 中间
        } else {
            [jsonComponentStr insertString:@"{" atIndex:0];
            [jsonComponentStr appendString:@"}"];
        }
        NSString *part = [self parseSingleJson:jsonComponentStr];
        if (part) {
            [fullTxt appendString:part];
        }
    }
    return fullTxt;
}

@end
