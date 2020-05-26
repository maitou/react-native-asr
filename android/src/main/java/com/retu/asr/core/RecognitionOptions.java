package com.retu.asr.core;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * 语音识别可选参数
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public class RecognitionOptions {
    private Map<String, Object> options;

    public RecognitionOptions() {
        this.options = new HashMap<>();
    }

    public RecognitionOptions(RecognitionOptions options) {
        this.options = new HashMap<>();
        setOptions(options);
    }

    public RecognitionOptions setOption(String key, int value) {
        options.put(key, value);
        return this;
    }

    public RecognitionOptions setOption(String key, boolean value) {
        options.put(key, value);
        return this;
    }

    public RecognitionOptions setOption(String key, String value) {
        options.put(key, value);
        return this;
    }

    /**
     * 同时设置多个可选参数
     *
     * @param options 需要设置的可选参数对象
     */
    public RecognitionOptions setOptions(RecognitionOptions options) {
        for (Map.Entry<String, Object> opt: options.listOptions()) {
            this.options.put(opt.getKey(), opt.getValue());
        }
        return this;
    }

    /**
     * 获取当前所有可选参数
     *
     * @return 当前已设置的所有可选参数集合
     */
    public Set<Entry<String, Object>> listOptions() {
        return Collections.unmodifiableSet(options.entrySet());
    }
}
