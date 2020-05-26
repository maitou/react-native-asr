/*
 * Description: 语音识别模块声明文件
 * Author: YangJiang
 * Create date: 2020/05/11
 */

export as namespace Asr;

/**
 * 开始语音识别
 *
 * @param options 语音识别可选参数。对于具体的参数，需要参考对应的语音识别平台
 * @return 语音识别结果
 */
export function start(options?: {[key: string]: boolean | number | string}): Promise<string>;

/**
 * 取消语音识别
 */
export function cancel(): Promise<void>;

/**
 * 暂停语音识别
 */
export function stop(): Promise<void>;
