package com.retu.asr.core;

/**
 * 对识别监听器的一个空实现
 *
 * @author YangJiang
 * @date 2020/05/11
 */
public class EmptyRecognitionListener implements RecognitionListener {

    @Override
    public void onEngineInitDone() {
        // do nothing
    }

    @Override
    public void onRecordingPrepared() {
        // do nothing
    }

    @Override
    public void onRecordingStart() {
        // do nothing
    }

    @Override
    public void onSpeechDetected() {
        // do nothing
    }

    @Override
    public void onRecordingStop() {
        // do nothing
    }

    @Override
    public void onVadTimeout() {
        // do nothing
    }

    @Override
    public void onNetEnd() {
        // do nothing
    }

    @Override
    public void onRecognitionEnd() {
        // do nothing
    }

    @Override
    public void onVolumeChange(int volume) {
        // do nothing
    }

    @Override
    public void onError(RecognitionResult result) {
        // do nothing
    }

    @Override
    public void onResult(RecognitionResult result) {
        // do nothing
    }
}
