/*
 * Description: 使用第三方平台提供的语音识别平台进行封装的RN语音识别组件
 * Author: YangJiang
 * Create date: 2020/05/11
 */

import {NativeModules, Platform, AppState} from 'react-native';
import {checkMultiple, requestMultiple, PERMISSIONS, RESULTS} from 'react-native-permissions';

const {RNAsr} = NativeModules;

//------------------android---------------------

// Android必要的权限
const NECESSARY_PERMISSIONS = [
    PERMISSIONS.ANDROID.READ_PHONE_STATE,
    PERMISSIONS.ANDROID.RECORD_AUDIO
]

// 当没有授予对应权限时，给出的提示信息
const UNGRANTED_TIPS = {};
UNGRANTED_TIPS[PERMISSIONS.ANDROID.READ_PHONE_STATE] = 'Unable to read phone state';
UNGRANTED_TIPS[PERMISSIONS.ANDROID.RECORD_AUDIO] = 'Unable to use microphone';

/**
 * 开始Android的语音识别
 */
async function startAndroid(options) {
    // 获取未授权的权限
    let statuses = await checkMultiple(NECESSARY_PERMISSIONS);
    let ungrantedPermissions = NECESSARY_PERMISSIONS.filter(permission => statuses[permission] !== RESULTS.GRANTED);

    // 请求未经授权的权限
    if (ungrantedPermissions.length > 0) {
        let requestStatuses = await requestMultiple(ungrantedPermissions);
        let ungrantedPermission = ungrantedPermissions.find(permission => requestStatuses[permission] !== RESULTS.GRANTED);
        if (ungrantedPermission) {
            throw new Error(UNGRANTED_TIPS[ungrantedPermission]);
        }
    }

    // 所有必要的权限已获得，直接开始语音识别
    return await RNAsr.start(options);
}

//------------------ios---------------------

// 监听IOS的APP状态，具体其处于前后台的状态处理识别器
if (Platform.os === 'ios') {
    let currentState = AppState.currentState;
    AppState.addEventListener('change', nextAppState => {
        // // app恢复到前台
        // if (currentState.match(/inactive|background/) && nextAppState === 'active') {
        //     // do nothing
        // }
        // app进入到后台
        if (currentState === 'active' && nextAppState === 'inactive') {
            return RNAsr.cancel();
        }
        currentState = nextAppState;
    });
}

//------------------common---------------------

const Asr = {

    /**
     * 开始语音识别
     *
     * @param {{[key: string]: boolean | number | string}} options 语音识别可选参数
     * @return {Promise<string>} 语音识别结果
     */
    start(options) {
        return Platform.OS === 'ios' ? RNAsr.start(options) :  startAndroid(options);
    },

    /**
     * 取消语音识别
     *
     * @return {Promise<void>}
     */
    cancel() {
        return RNAsr.cancel();
    },

    /**
     * 暂停语音识别
     *
     * @return {Promise<void>}
     */
    stop() {
        return RNAsr.stop();
    },
};

export default Asr