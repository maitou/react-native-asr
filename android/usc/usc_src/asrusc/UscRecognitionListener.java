package com.retu.asr.asrusc;

import android.content.Context;
import android.util.Log;
import com.retu.asr.R;
import com.retu.asr.core.RecognitionListener;
import com.retu.asr.core.RecognitionResult;
import com.unisound.client.SpeechConstants;
import com.unisound.client.SpeechUnderstanderListener;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * 云知声识别监听器
 *
 * @author YangJiang
 * @date 2020/05/09
 */
class UscRecognitionListener implements SpeechUnderstanderListener {

    private static final String TAG = "UniRecognitionListener";

    private final Context mContext;
    private final RecognitionListener mListener;

    UscRecognitionListener(Context context, RecognitionListener recognizeListener) {
        this.mContext = context;
        this.mListener = recognizeListener;
    }

    @Override
    public void onEvent(int type, int timeMs) {
        switch (type) {
            // 初始化完成
            case SpeechConstants.ASR_EVENT_ENGINE_INIT_DONE:
                mListener.onEngineInitDone();
                break;
            // 录音准备就绪
            case SpeechConstants.ASR_EVENT_RECORDING_PREPARED:
                mListener.onRecordingPrepared();
                break;
            // 录音设备打开
            case SpeechConstants.ASR_EVENT_RECORDING_START:
                mListener.onRecordingStart();
                break;
            // 用户开始说话
            case SpeechConstants.ASR_EVENT_SPEECH_DETECTED:
                mListener.onSpeechDetected();
                break;
            // 停止录音
            case SpeechConstants.ASR_EVENT_RECORDING_STOP:
                mListener.onRecordingStop();
                break;
            // 收到用户停止说话事件
            case SpeechConstants.ASR_EVENT_VAD_TIMEOUT:
                mListener.onVadTimeout();
                break;
            // 在线识别结束
            case SpeechConstants.ASR_EVENT_NET_END:
                mListener.onNetEnd();
                break;
            // 识别结束
            case SpeechConstants.ASR_EVENT_RECOGNITION_END:
                mListener.onRecognitionEnd();
                break;
            // 实时返回说话音量
            case SpeechConstants.ASR_EVENT_VOLUMECHANGE:
                // FIXME: 2020/05/09 暂时未实现
                mListener.onVolumeChange(0);
            default:
                break;
        }
    }

    @Override
    public void onError(int type, String errorMsg) {
        RecognitionResult result = new RecognitionResult();
        result.setType(type);
        result.setErrorResult(errorMsg == null || "".equals(errorMsg) ? mContext.getString(R.string.no_hear_sound) : errorMsg);
        mListener.onError(result);
    }

    @Override
    public void onResult(int type, String jsonResult) {
        Log.d(TAG, "onResult: -> " + jsonResult);
        RecognitionResult result = new RecognitionResult();
        result.setType(type);
        result.setOriginalResult(jsonResult);
        parseJson(jsonResult, result);
        if (result.isFinal()) {
            mListener.onResult(result);
        } else if (result.isError()) {
            mListener.onError(result);
        }
        // 对于临时数据不用发送监听
    }

    /**
     * 解析返回结果到结果对象中
     *
     * @param jsonResult 需要解析的JSON格式返回结果字符串
     * @param result 解析后的结果对象
     */
    private void parseJson(String jsonResult, RecognitionResult result) {
        if (jsonResult.contains("net_asr") || jsonResult.contains("local_asr")) {
            try {
                JSONObject json = new JSONObject(jsonResult);
                JSONArray asrJsonArray = json.has("net_asr") ? json.getJSONArray("net_asr") : json.getJSONArray("local_asr");
                JSONObject asrJson = asrJsonArray.getJSONObject(0);
                String resultType = asrJson.getString("result_type");
                String resultTxt = asrJson.getString("recognition_result");
                if ("full".equals(resultType)) {
                    result.setFinalResult(removeRedundant(resultTxt));
                } else {
                    result.setTempResult(removeRedundant(resultTxt));
                }
            } catch (Exception e) {
                Log.e(TAG, mContext.getString(R.string.parse_result_exception), e);
                result.setErrorResult(mContext.getString(R.string.parse_result_exception));
            }
        }
    }

    /**
     * 移除结果文本中冗余的信息
     *
     * @param result 原始的结果信息
     * @return 取消冗余后的结果信息
     */
    private String removeRedundant(String result) {
        // 有时识别结果最前面会有一个"{}"字符，需要去除掉
        return result.startsWith("{}") ? result.substring(2) : result;
    }
}
