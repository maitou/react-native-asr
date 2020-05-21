package com.retu.asr.core;

import androidx.annotation.Nullable;

/**
 * 语音识别器
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public interface SpeechRecognizer {

    /**
     * 开始语音识别
     *
     * @param options 识别可选参数
     */
    void start(@Nullable RecognitionOptions options);

    /**
     * 取消语音识别
     */
    void cancel();

    /**
     * 停止语音识别
     */
    void stop();

    /**
     * 销毁当前识别对象
     *
     * @return 成功返回true，否则返回false
     */
    boolean destroy();
}
