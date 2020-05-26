//
//  IFLYSpeechRecognizer.h
//  RNAsr
//
//  Created by YangJiang on 2020/5/18.
//

#import <Foundation/Foundation.h>
#import "AsrProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface IFLYSpeechRecognizer : NSObject<SpeechRecognizer>

/**
 * 初始化讯飞识别套件
 */
+ (void)initUtility;

@end

NS_ASSUME_NONNULL_END
