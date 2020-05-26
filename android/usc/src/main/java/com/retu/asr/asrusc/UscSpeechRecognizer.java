package com.retu.asr.asrusc;

import android.content.Context;
import androidx.annotation.Nullable;
import com.retu.asr.core.RecognitionListener;
import com.retu.asr.core.RecognitionOptions;
import com.retu.asr.core.SpeechRecognizer
import com.unisound.client.SpeechConstants;
import com.unisound.client.SpeechUnderstander;
import com.unisound.client.SpeechUnderstanderListener;
import java.util.Map;

/**
 * 云知声语音识别对象
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public class UscSpeechRecognizer implements SpeechRecognizer {
    private final SpeechUnderstander mUnderstander;
    private final SpeechUnderstanderListener mListener;

    public UscSpeechRecognizer(Context context, RecognitionListener listener, @Nullable RecognitionOptions options) {
        this.mUnderstander = new SpeechUnderstander(context, Config.APP_KEY, Config.APP_SECRET);
        this.mListener = new UscRecognitionListener(context, listener);
		init(options);
    }

    private void init(@Nullable RecognitionOptions options) {
        setOptions(mixOptions(defaultOptions(), options));
        mUnderstander.setListener(mListener);
        mUnderstander.init(null);
    }

    @Override
    @SuppressWarnings("unchecked")
    public void start(@Nullable RecognitionOptions options) {
        requireInit();
        setOptions(options);
        mUnderstander.start();
    }

    @Override
    public void cancel() {
        requireInit();
        mUnderstander.cancel();
    }

    @Override
    public void stop() {
        requireInit();
        mUnderstander.stop();
    }

    /**
     * 获取默认参数选项
     */
    private RecognitionOptions<Integer> defaultOptions() {
        return new RecognitionOptions<Integer>()
            .setOption(SpeechConstants.ASR_SERVICE_MODE, SpeechConstants.ASR_SERVICE_MODE_NET)
            .setOption(SpeechConstants.NLU_ENABLE, false)
            .setOption(SpeechConstants.ASR_OPT_TEMP_RESULT_ENABLE, false)
            .setOption(SpeechConstants.ASR_SAMPLING_RATE, SpeechConstants.ASR_SAMPLING_RATE_BANDWIDTH_AUTO)
            .setOption(SpeechConstants.ASR_DOMAIN, "general")
            .setOption(SpeechConstants.ASR_LANGUAGE, SpeechConstants.LANGUAGE_MANDARIN);
    }

    /**
     * 将两个可选参数混合为一个可选参数
     *
     * @param def 默认可选参数
     * @param other 其它可选参数
     * @return 混合后的可选参数，如果没有则返回null
     */
    private RecognitionOptions<Integer> mixOptions(@Nullable RecognitionOptions<Integer> def, @Nullable RecognitionOptions<Integer> other) {
        return def != null
            ? (other == null ? def : new RecognitionOptions<>(def).setOptions(other))
            : null;
    }

    /**
     * 为识别器设置可选参数
     */
    private void setOptions(@Nullable RecognitionOptions<Integer> options) {
        if (options != null) {
            for (Map.Entry<Integer, Object> option : options.listOptions()) {
                mUnderstander.setOption(option.getKey(), option.getValue());
            }
        }
    }

}
