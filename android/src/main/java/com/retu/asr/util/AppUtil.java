package com.retu.asr.util;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;

/**
 * 应用工具类
 *
 * @author YangJiang
 * @date 2020/05/21
 */
public class AppUtil {
    private static final String TAG = "RNAsr.AppUtil";

    /**
     * 获取应用配置文件AndroidManifest.xml中的mata-data参数
     *
     * @param context 上下文
     * @param metadata 元数据键值
     * @return 元数据值
     */
    public static String getMetaDataValue(Context context, String metadata) {
        String value = null;
        PackageManager packageManager = context.getPackageManager();
        ApplicationInfo applicationInfo;
        try {
            applicationInfo = packageManager.getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            if (applicationInfo != null && applicationInfo.metaData != null) {
                Object object = applicationInfo.metaData.get(metadata);
                if (object != null) {
                    value = object.toString();
                }
            }
        } catch (PackageManager.NameNotFoundException e) {
            Log.d(TAG, "未获取到对应的元数据", e);
        }
        return value;
    }
}
