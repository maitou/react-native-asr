//
//  IOSSpeechRecognizer.h
//  RNAsr
//
//  Created by YangJiang on 2020/5/17.
//

#import <Foundation/Foundation.h>
#import "AsrProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RTSpeechErrorType) {
    RTSpeechErrorTypeDefault = 0,         // 未知错误
    RTSpeechErrorTypeNoNotPossible,       // 设备不支持
    RTSpeechErrorTypeAudioStartError,     // 打开录音失败
    RTSpeechErrorTypeUserRefuse,          // 用户拒绝
    RTSpeechErrorTypeNoPermission         // 没有授权
};

@interface IOSSpeechRecognizer : NSObject<SpeechRecognizer>

@end

NS_ASSUME_NONNULL_END
