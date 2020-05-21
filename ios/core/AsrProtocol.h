//
//  AsrProtocol.h
//  RNAsr
//
//  Created by YangJiang on 2020/5/14.
//

#import <Foundation/Foundation.h>
#import "RecognitionResult.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RecognitionListener
/**
 * 语音识别器，当接入具体的第三方语音识别平台时，对该协议进行实现
 */
@protocol RecognitionListener <NSObject>

/**
 * 录音设备打开
 */
- (void)onRecordingStart;

/**
 * 用户开始说话
 */
@optional
- (void)onSpeechDetected;

/**
 * 停止录音
 */
- (void)onRecordingStop;

/**
 * 收到用户停止说话事件
 */
- (void)onVadTimeout;

/**
 * 在线识别结束
 */
- (void)onNetEnd;

/**
 * 实时返回说话音量
 *
 * @param volume 音量大小
 */
@optional
- (void)onVolumeChange:(int)volume;

/**
 * 出错
 *
 * @param result 错误结果
 */
- (void)onError:(RecognitionResult *)result;

/**
 * 获得结果，此方法可能触发多次
 *
 * @param result 识别结果
 */
- (void)onResult:(RecognitionResult *)result;

@end

#pragma mark - SpeechRecognizer
/**
 * 语音识别器，当接入具体的第三方语音识别平台时，对该协议进行实现
 */
@protocol SpeechRecognizer <NSObject>

- (instancetype)init:(id<RecognitionListener>)listener;

/**
 * 初始化识别器
 */
- (instancetype)initWithOptions:(id<RecognitionListener>)listener options:(nullable NSDictionary<NSString*, id> *)options;

/**
 * 开始识别
 */
- (void)start:(nullable NSDictionary<NSString*, id> *)options;

/**
 * 取消识别
 */
- (void)cancel;

/**
 * 停止识别
 */
- (void)stop;

/**
 * 销毁当前识别器
 */
- (BOOL)destroy;

@end

NS_ASSUME_NONNULL_END
