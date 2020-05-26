package com.retu.asr.core;

/**
 * 语音识别监听器。各个事件参考云知声<link>http://dev.hivoice.cn/doc/sdk_doc.jsp</link>。
 * 对于其它平台 如百度，可进行相应事件的适配即可。
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public interface RecognitionListener {

    /**
     * 初始化完成
     */
    void onEngineInitDone();

    /**
     * 录音准备就绪
     */
    void onRecordingPrepared();

    /**
     * 录音设备打开
     */
    void onRecordingStart();

    /**
     * 用户开始说话
     */
    void onSpeechDetected();

    /**
     * 停止录音
     */
    void onRecordingStop();

    /**
     * 收到用户停止说话事件
     */
    void onVadTimeout();

    /**
     * 在线识别结束
     */
    void onNetEnd();

    /**
     * 识别结束
     */
    void onRecognitionEnd();

    /**
     * 实时返回说话音量
     *
     * @param volume 音量大小
     */
    void onVolumeChange(int volume);

    /**
     * 获得结果，此方法可能触发多次
     *
     * @param result 识别结果
     */
    void onResult(RecognitionResult result);

    /**
     * 出错
     *
     * @param result 错误结果
     */
    void onError(RecognitionResult result);
}
