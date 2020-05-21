package com.retu.asr.asrifly;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.Nullable;
import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechUtility;
import com.retu.asr.core.RecognitionListener;
import com.retu.asr.core.RecognitionOptions;
import com.retu.asr.core.RecognitionResult;
import com.retu.asr.util.AppUtil;
import java.util.Map;

/**
 * 讯飞语音识别器
 *
 * @author YangJiang
 * @date 2020/05/19
 */
public class IflySpeechRecognizer implements com.retu.asr.core.SpeechRecognizer,
    RecognizerListener {

    private final String TAG = "IflySpeechRecognizer";

    private final SpeechRecognizer mRecognizer;
    // Common recognizer listener adaptor
    private RecognitionListener mListener;
    private StringBuffer mCurResult = new StringBuffer();

    /**
     * 初始化讯飞识别模块
     *
     * @param context 运行上下文
     */
    public static void initUtility(Context context) {
        SpeechUtility.createUtility(context, "appid=" + AppUtil.getMetaDataValue(context, "asr.ifly.appid"));
    }

    /**
     * 语音识别器构造函数
     *
     * @param context 运行上下文
     * @param listener 语音识别监听器
     * @param options 可选参数
     */
    public IflySpeechRecognizer(Context context, RecognitionListener listener,
        @Nullable RecognitionOptions options) {
        mListener = listener;
        mRecognizer = SpeechRecognizer.createRecognizer(context, new InitListener() {
            @Override
            public void onInit(int code) {
                Log.d(TAG, "SpeechRecognizer init() code = " + code);
                if (code != ErrorCode.SUCCESS) {
                    RecognitionResult rst = new RecognitionResult();
                    rst.setType(code);
                    rst.setErrorResult("Init speech recognizer is failed!");
                    mListener.onError(rst);
                }
            }
        });
        setDefaultOptions();
        setOptions(options);
    }

    @Override
    public void start(@Nullable RecognitionOptions options) {
        setOptions(options);
        reset();
        int res = mRecognizer.startListening(this);
        if (res != ErrorCode.SUCCESS) {
            RecognitionResult rst = new RecognitionResult();
            rst.setType(res);
            rst.setErrorResult("Start recognizer is failed!");
            mListener.onError(rst);
        }
    }

    @Override
    public void cancel() {
        mRecognizer.cancel();
    }

    @Override
    public void stop() {
        mRecognizer.stopListening();
    }

    @Override
    public boolean destroy() {
        if (mRecognizer != null) {
            mRecognizer.cancel();
            return mRecognizer.destroy();
        }
        return true;
    }

    /**
     * 重置参数
     */
    private void reset() {
        cancel();
        // 清空临时识别结果文本缓存对象
        if (mCurResult.length() > 0) {
            mCurResult.delete(0, mCurResult.length());
        }
    }

    /**
     * 设置默认参数选项
     */
    private void setDefaultOptions() {
        // 清空参数
        mRecognizer.setParameter(SpeechConstant.PARAMS, null);
        // 设置听写引擎
        mRecognizer.setParameter(SpeechConstant.ENGINE_TYPE, SpeechConstant.TYPE_CLOUD);
        // 设置返回结果格式
        mRecognizer.setParameter(SpeechConstant.RESULT_TYPE, "plain");
        // 设置语言输入语言
        mRecognizer.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
        // 设置语言区域，即简体中文下的方言
        mRecognizer.setParameter(SpeechConstant.ACCENT, "mandarin");

        // 设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
        mRecognizer.setParameter(SpeechConstant.VAD_BOS, "4000");
        // 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
        mRecognizer.setParameter(SpeechConstant.VAD_EOS, "1000");
        // 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
        mRecognizer.setParameter(SpeechConstant.ASR_PTT, "1");
//        // 设置音频保存路径，保存音频格式支持pcm、wav，设置路径为sd卡请注意WRITE_EXTERNAL_STORAGE权限
//        mRecognizer.setParameter(SpeechConstant.AUDIO_FORMAT,"wav");
//        mRecognizer.setParameter(SpeechConstant.ASR_AUDIO_PATH, Environment.getExternalStorageDirectory()+"/msc/iat.wav");
    }

    /**
     * 设置可选参数
     *
     * @param options 需要设置的参数
     */
    private void setOptions(@Nullable RecognitionOptions options) {
        if (options == null) {
            return;
        }
        for (Map.Entry<String, Object> option : options.listOptions()) {
            Object optionValue = option.getValue();
            if (optionValue instanceof String) {
                mRecognizer.setParameter(option.getKey(), (String) optionValue);
            } else {
                Log.i(TAG, "Illegal parameter value for " + option.getKey());
            }
        }
    }

    /*--------------------RecognizerListener------------------------*/

    @Override
    public void onVolumeChanged(int volume, byte[] bytes) {
        mListener.onVolumeChange(volume);
    }

    @Override
    public void onBeginOfSpeech() {
        mListener.onRecordingStart();
    }

    @Override
    public void onEndOfSpeech() {
        mListener.onRecordingStop();
    }

    @Override
    public void onResult(RecognizerResult results, boolean isLast) {
        // json格式
//        String text = JsonParser.parseIatResult(results.getResultString());
        // plain格式
        String text = results.getResultString();
        Log.d(TAG, "onResult->" + text);
        mCurResult.append(text);
        if (isLast) {
            RecognitionResult rst = new RecognitionResult();
            rst.setFinalResult(mCurResult.toString());
            mListener.onResult(rst);
        }
    }

    @Override
    public void onError(SpeechError speechError) {
        RecognitionResult rst = new RecognitionResult();
        rst.setType(speechError.getErrorCode());
        // 返回部分内容
        if (mCurResult.length() > 0) {
            rst.setFinalResult(mCurResult.toString());
            mListener.onResult(rst);
            // 返回错误信息
        } else {
            rst.setErrorResult(speechError.getPlainDescription(true));
            mListener.onError(rst);
        }
    }

    @Override
    public void onEvent(int i, int i1, int i2, Bundle bundle) {
        // do nothing
    }
}
