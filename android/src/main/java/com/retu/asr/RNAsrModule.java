
package com.retu.asr;

import android.util.Log;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.retu.asr.asrifly.IflySpeechRecognizer;
import com.retu.asr.core.EmptyRecognitionListener;
import com.retu.asr.core.RecognitionOptions;
import com.retu.asr.core.RecognitionResult;
import com.retu.asr.core.SpeechRecognizer;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

/**
 * 自动语音识别模块
 *
 * @author YangJiang
 * @date 2020/05/07
 */
public class RNAsrModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    /**
     * 自动语音识别状态
     */
    enum AsrStatus {
        /**
         * 空闲状态
         */
        IDLE,

        /**
         * 正在录音
         */
        RECORDING,

        /**
         * 正在识别
         */
        RECOGNIZING
    }

    private static final String TAG = "RNAsrModule";
    private static final String MODULE_NAME = "RNOpAsr";

    private static final String ERROR_BUSY = "-1";
    private static final String ERROR_MANUAL = "-2";
    private static final String ERROR_OPTION = "-3";

    private SpeechRecognizer mRecognizer;
    private AsrStatus mStatus = AsrStatus.IDLE;
    private Promise mRstPromise;

    RNAsrModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addLifecycleEventListener(this);
        // 讯飞语音识别初始化
        IflySpeechRecognizer.initUtility(reactContext);
    }

    @Override
    public String getName() {
        return MODULE_NAME;
    }

    /**
     * 开始语音识别
     */
    @ReactMethod
    public void start(ReadableMap options, Promise promise) {
        // 初始化识别器，初始化识别器之前需要获取相应的权限
        if (mRecognizer == null) {
            initRecognizer();
        }

        // 开始录音
        if (mStatus == AsrStatus.RECORDING) {
            promise.reject(ERROR_BUSY, getReactApplicationContext().getString(R.string.recording));
        } else if (mStatus == AsrStatus.RECOGNIZING) {
            promise.reject(ERROR_BUSY, getReactApplicationContext().getString(R.string.recognizing));
        } else {
            mRstPromise = promise;
            try {
                mRecognizer.start(convertRnToAsrOpt(options));
            } catch (NumberFormatException e) {
                promise.reject(ERROR_OPTION, getReactApplicationContext().getString(R.string.opt_key_illegal));
                mRstPromise = null;
            } catch (IllegalArgumentException e) {
                promise.reject(ERROR_OPTION, e.getMessage());
                mRstPromise = null;
            }
        }
    }

    /**
     * 取消语音识别
     */
    @ReactMethod
    public void cancel(Promise promise) {
        cancel();
        promise.resolve(null);
    }

    /**
     * 取消语音识别
     */
    private void cancel() {
        if (mRecognizer != null) {
            mRecognizer.cancel();
        }
        mStatus = AsrStatus.IDLE;
        if (mRstPromise != null) {
            mRstPromise.reject(ERROR_MANUAL, getReactApplicationContext().getString(R.string.cancel));
            mRstPromise = null;
        }
    }

    /**
     * 停止语音识别
     */
    @ReactMethod
    public void stop(Promise promise) {
        if (mRecognizer != null)  {
            mRecognizer.stop();
        }
        promise.resolve(null);
    }

    /*------------life cycle-----------*/

    @Override
    public void onCatalystInstanceDestroy() {
        cancel();
    }

    @Override public void onHostResume() {
        // 避免机内存过小，杀死后台进程后通过历史intent进入Activity造成SpeechUtility对象为null
        // 在应用重新进入时，初始化Utility，如果已经存在则会直接返回
        IflySpeechRecognizer.initUtility(getReactApplicationContext());
    }

    @Override
    public void onHostPause() {
//        cancel();
    }

    @Override
    public void onHostDestroy() {
        mRecognizer.destroy();
        mRecognizer = null;
    }

    /*------------private methods-----------*/

    /**
     * 初始化语音识别器
     */
    private void initRecognizer() {
        mRecognizer = new IflySpeechRecognizer(getReactApplicationContext(),
            new EmptyRecognitionListener() {
                @Override
                public void onVadTimeout() {
                    // 用户停止说话，停止录音
                    mRecognizer.stop();
                }

                @Override
                public void onRecordingStart() {
                    mStatus = AsrStatus.RECORDING;
                }

                @Override
                public void onRecordingStop() {
                    mStatus = AsrStatus.RECOGNIZING;
                }

                @Override
                public void onNetEnd() {
                    mStatus = AsrStatus.IDLE;
                }

                @Override
                public void onError(RecognitionResult result) {
                    Log.d(TAG, "onError: -> " + result.getCurrentResult());
                    if (mRstPromise != null) {
                        mRstPromise.reject(String.valueOf(result.getType()), result.getCurrentResult());
                        mRstPromise = null;
                    }
                    mStatus = AsrStatus.IDLE;
                }

                @Override
                public void onResult(RecognitionResult result) {
                    Log.d(TAG, "onResult: -> " + result.getCurrentResult());
                    if (mRstPromise != null) {
                        mRstPromise.resolve(result.getCurrentResult());
                        mRstPromise = null;
                    }
                    mStatus = AsrStatus.IDLE;
                }
            }, null);
    }

    /**
     * 将RN格式的可选参数转换为识别器的可选参数对象
     *
     * @param options RN格式的可选参数对象
     * @return 识别器可选参数对象
     */
    private RecognitionOptions convertRnToAsrOpt(ReadableMap options) {
        if (options == null) {
            return null;
        }
        Iterator<Entry<String, Object>> optIterator = options.getEntryIterator();
        RecognitionOptions recognitionOptions = new RecognitionOptions();
        while (optIterator.hasNext()) {
            Map.Entry<String, Object> optEntry = optIterator.next();
            Object optValue = optEntry.getValue();
            if (optValue instanceof Integer || optValue instanceof Long) {
                recognitionOptions.setOption(optEntry.getKey(), ((Number) optValue).intValue());
                continue;
            }
            if (optValue instanceof Boolean) {
                recognitionOptions.setOption(optEntry.getKey(), (Boolean) optValue);
                continue;
            }
            if (optValue instanceof String) {
                recognitionOptions.setOption(optEntry.getKey(), (String) optValue);
                continue;
            }
            throw new IllegalArgumentException(String.format(
                getReactApplicationContext().getString(R.string.opt_value_illegal),
                optEntry.getKey()));
        }
        return recognitionOptions;
    }
}