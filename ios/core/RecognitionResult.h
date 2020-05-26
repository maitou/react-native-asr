//
//  RecognitionResult.h
//  RNAsr/core
//
//  Created by YangJiang on 2020/5/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// @class - 识别结果
@interface RecognitionResult : NSObject

/**
 * 结果类型码
 */
@property (nonatomic) int type;
/**
 * 识别文本结果
 */
@property (nonatomic, copy) NSString *originalRst;

// 当前解析后的解析文本
@property (nonatomic, copy) NSString *errorRst;
@property (nonatomic, copy) NSString *finalRst;

- (BOOL)isError;
- (BOOL)isTemp;
- (BOOL)isFinal;

/**
 * 添加临时结果
 */
- (void)addPartRst:(NSString *)part;

/**
 * 获取当前解析后的识别结果，如果没有则返回原始结果
 */
- (NSString *)getCurrentRst;

@end

NS_ASSUME_NONNULL_END
