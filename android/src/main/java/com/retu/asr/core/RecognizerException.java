package com.retu.asr.core;

/**
 * 语音识别异常对象
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public class RecognizerException extends RuntimeException {

    public RecognizerException(String msg) {
        super(msg);
    }
}
