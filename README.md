# `@react-native-op/asr`

![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-brightgreen.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)

对第三方语音识别平台进行封装后的React Native组件。当前默认第三方语音识别平台为讯飞，在Android和IOS各自还有其它可用的识别平台这需要对代码进行一些设置

## 安装

```
$ npm install maitou/react-native-asr --save
```

#### 编译环境

| dev            | version |
| :---           | :---    |
| React Native   | 0.62.2  |
| Android Studio | 3.5.2   |
| Xcode          | 11.2.1  |

当前模块在以上开发环境中编译通过，如果在使用过程中遇到问题可以考虑编译升级工具版本

#### React Native >= 0.60

当大于等于此版本时，在安装组件时会自动进行链接。

- **IOS平台**

  在项目根目录执行如下命令：
  ```
  cd ios && pod install && cd ..
  ```

- **Android平台**

  查看项目配置文件**android/build.gradle**版本信息是否和如下一致，如果版本不同可能会导致编译失败
  ```
  buildscript {
    ext {
      buildToolsVersion = "28.0.3"
      minSdkVersion = 16
      compileSdkVersion = 28
      targetSdkVersion = 28
      # Only using Android Support libraries
      supportLibVersion = "28.0.0"
    }
  ```

#### React Native < 0.60

由于React Native组件的安装基本类似，对于低版本的安装可以参照其它React Native，参考[react-native-permissions安装](https://github.com/react-native-community/react-native-permissions#-manual-linking)  
*注意：编译版本为0.62，小于0.60版本很大可能不兼容，则需要使用者自己倒腾*

## 语音识别器的选择

当前并没有提供以直接传入参数的方式切换不同语音识别平台的模式，者有望在下一个版本中得到支持。如果需要使用目前可用的语音识别平台，则需要按照下面的具体说明进行操作

### IOS

| platform               | available | ios version |
| :---                   | :---      | :---        |
| ifly(讯飞)             | default   | >= 8.0      |
| ios(IOS自带语音识别器) | true      | >= 10.0     |
| usc(云知声)            | false     | >= 6.0      |

- **ifly**

  讯飞的语音识别准确率较高，支持的语言也很丰富，是作为首选的语音识别平台。按一下步骤设置对应的参数:  

  1)&ensp;在讯飞官方进行账号注册，获得对应的`APPID`  

  2)&ensp;找到项目的`Info.plist`文件，设置`APPID`，以下设置方式任选其一  
  ```xml
  <!-- 在Info.plist文件中设置，添加下面的配置 -->
  <key>AsrConfig</key>
  <dict>
    <key>IflyAppId</key>
    <string>2f34w23n</string>
  </dict>

  <!-- 在Xcode中设置，参照上面的配置在界面中进行添加 -->
  ```

  3)&ensp;设置权限，在`Info.plist`文件中添加相应的权限描述  
  ```xml
  <key>NSMicrophoneUsageDescription</key>
  <string></string>
  <key>NSLocationUsageDescription</key>
  <string></string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string></string>
  <key>NSContactsUsageDescription</key>
  <string></string>
  ```

- **ios**

  IOS自带语音识别最大的优点就是免费，但是识别准确率并不理想，可用作一些简单的应用场景。参数修改：

  1)&ensp;找到`@react-native-op/asr`ios目录下的`RNAsr.podspec`文件, 修改平台最小支持版本  
  ```ruby
  s.platform = :ios, "10.0"
  ```

  2)&ensp;查看当前项目的目标版本号`General`->`Deployment Info`->`Target`，是否低于`10.0`  

  3)&ensp;减少包的体积，可以注释掉`RNAsr.podspec`文件中关于讯飞库的引用  

  4)&ensp;找到`RNAsr.m`文件，修改代码选用IOS平台的语音识别器  
  ```objective-c
  // 引用头文件
  #import "asrios/IOSSpeechRecognizer.h"

  // 初始化
  - (void)initRecognizer:(NSDictionary *)options {
      // IOS自带语音识别器
      self.speechRecognizer = [[IOSSpeechRecognizer alloc] initWithOptions:self options:options];
  }
  ```

- **usc**

  云知声在进行编译时采用`Build System->Legacy Build System`会编译成功，`0.62`版本的RN采用`New Build System`，编译上有点冲突，暂时不可用。

### Android

| platform    | available | ios version |
| :---        | :---      | :---        |
| ifly(讯飞)  | default   | >= 4.4      |
| usc(云知声) | true      | >= 2.1      |

- **ifly**

  讯飞设置参数：  

  1)&ensp;在讯飞官方进行账号注册，获得对应的`APPID`  

  2)&ensp;找到项目的`AndroidManifest.xml`文件，设置`APPID`  
  ```xml
  <application>
      <meta-data android:name="asr.ifly.appid" android:value="2f34w23n" />
  </application>
  ```

- **usc**

  使用步骤：  

  1)&ensp;删除讯飞相关文件  
  ```dir
  - android/libs/
  - src/main/java/com/retu/asr/asrifly/
  ```

  2)&ensp;使用`@react-native-op/asr/andoid/usc`目录下面的文件覆盖对应的文件  
  ```dir
  - libs/
  - src/
  - build.gradle
  ```

  3)&ensp;找到`RNAsrModule.java`文件，修改代码选用usc平台的语音识别器  
  ```java
  /**
   * 初始化语音识别器
   */
  private void initRecognizer() {
      mRecognizer = new UscSpeechRecognizer(getReactApplicationContext(), listener);
  }
  ```
  *注意：由于云知声和讯飞支持的架构不同，如果想在一个项目中同时使用两个平台，只能保持__armeabi-v7a__框架*

## API

- **Types:**
  - [`OptionsType`](#optionstype)
- **[Methods](#methods):**

### Types

#### `OptionsType`

| Property | Type                                                           | Description                                |
| :---     | :---                                                           | :---                                       |
| options  | `{[key: string]: boolean `&brvbar;` number `&brvbar;` string}` | 具体参数内容需要参考对应使用的语音识别平台 |

### Methods

| API      | Parameters                    | Retun                     | Description                    |
| :--      | :---                          | :---                      | :---                           |
| `start`  | [`OptionsType`](#optionstype) | `Promise`&lt;`string`&gt; | 开始语音识别，返回语音识别结果 |
| `cancel` | `void`                        | `Promise`&lt;`void`&gt;   | 取消语音识别                   |
| `stop`   | `void`                        | `Promise`&lt;`void`&gt;   | 暂停语音识别                   |

## 使用示例
```typescript
import React from 'react';
import {Text, TouchableOpacity, View, StyleSheet} from 'react-native';
import Asr from '@react-native-op/asr';

type Props = {};

type State = {
    /**
     * 语音识别结果
     */
    asrRst: string,
};

/**
 * 自动语音识别测试
 *
 * @author YangJiang
 * @date 2020/05/07
 */
export default class AsrTest extends React.Component<Props, State> {
    private isInRecognition: boolean = false;

    private constructor(props) {
        super(props);
        this.state = {asrRst: '伊甸园'};
    }

    /*---------test method start------------*/

    private testStart() {
        if (this.isInRecognition) {
            return;
        }
        this.isInRecognition = true;
        this.setState({asrRst: '识别中......'});
        Asr.start().then(asrRst => {
            this.isInRecognition = false;
            this.setState({asrRst});
        }).catch(error => {
            this.setState({asrRst: AsrTest.txtInfo(error)});
            this.isInRecognition = false;
        });
    }

    private testCancel() {
        Asr.cancel().then(() => {
            this.setState({asrRst: '取消成功'});
        }).catch(error => {
            this.setState({asrRst: '取消失败'});
        });
    }

    private testStop() {
        Asr.stop().then(() => {
            // this.setState({asrRst: '暂停成功'});
        }).catch(error => {
            this.setState({asrRst: '暂停失败'});
        });
    }

    /*---------test method end------------*/

    private static txtInfo(info: any) {
        return Object.prototype.toString.call(info) === '[object String]' ? info : (info.message || info.description || JSON.stringify(info));
    }

    private render(): React.ReactNode {
        return (
            <View style={styles.testArea}>
                <TouchableOpacity style={styles.btnOperate} onPress={() => this.testStart()}>
                    <Text style={styles.btnTxt}>开始录音</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.btnOperate} onPress={() => this.testCancel()}>
                    <Text style={styles.btnTxt}>取消录音</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.btnOperate} onPress={() => this.testStop()}>
                    <Text style={styles.btnTxt}>停止录音</Text>
                </TouchableOpacity>
                <Text>{this.state.asrRst}</Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    testArea: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    btnOperate: {
        justifyContent: 'center',
        alignItems: 'center',
        height: 40,
        width: 100,
        marginBottom: 10,
        borderRadius: 5,
        backgroundColor: '#123456',
    },
    btnTxt: {
        // marginVertical: 5,
        // marginHorizontal: 10,
        color: '#FFF',
    }
});
```
