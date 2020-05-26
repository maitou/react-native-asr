package com.retu.asr.core;

/**
 * 语音识别结果
 *
 * @author YangJiang
 * @date 2020/05/09
 */
public class RecognitionResult {
    /**
     * 结果类型码
     */
    private int type;
    private String originalResult;

    private String errorResult;
    private String tempResult;
    private String finalResult;

    public void setOriginalResult(String originalResult) {
        this.originalResult = originalResult;
    }

    public void setErrorResult(String errorResult) {
        this.errorResult = errorResult;
    }

    public void setTempResult(String tempResult) {
        this.tempResult = tempResult;
    }

    public void setFinalResult(String finalResult) {
        this.finalResult = finalResult;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getType() {
        return type;
    }

    public boolean isError() {
        return errorResult != null;
    }

    public boolean isTemp() {
        return tempResult != null;
    }

    public boolean isFinal() {
        return finalResult != null;
    }

    /**
     * 获取起始的结果数据
     */
    public String getOriginalResult() {
        return originalResult;
    }

    /**
     * 获取当前的结果数据，当没有具体结果时，默认返回起始数据
     */
    public String getCurrentResult() {
        if (isError()) {
            return errorResult;
        }
        if (isTemp()) {
            return tempResult;
        }
        if (isFinal()) {
            return finalResult;
        }
        return originalResult;
    }
}
