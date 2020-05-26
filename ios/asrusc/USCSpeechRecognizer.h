//
//  USCSpeechRecognizer.h
//  RNAsr
//
//  Created by YangJiang on 2020/5/14.
//

#import <Foundation/Foundation.h>
#import "../core/AsrProtocol.h"
#import "../unisound-lib/USCSpeechUnderstander.h"

// 此处定义usc常量库中未定义的常量
static const int USC_ASR_OPT_TEMP_RESULT_ENABLE = 1076;
static const int USC_ASR_SAMPLING_RATE_BANDWIDTH_AUTO = 100;
static const int USC_ASR_SAMPLING_RATE_8K = 8000;
static const int USC_ASR_SAMPLING_RATE_16K = 16000;

NS_ASSUME_NONNULL_BEGIN

//@interface UniSpeechRecognizer : NSObject<SpeechRecognizer>
//
//@property (nonatomic,strong) USCSpeechUnderstander *speechUnderstander;
//
//@end

@interface USCSpeechRecognizer:NSObject<SpeechRecognizer, USCSpeechUnderstanderDelegate> {
    @private
    USCSpeechUnderstander *speechUnderstander;
    id<RecognitionListener> listener;
    RecognitionResult *partRst;
}
@end

NS_ASSUME_NONNULL_END
