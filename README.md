
# @react-native-retu/asr

## Getting started

`$ npm install react-native-asr --save`

### Mostly automatic installation

`$ react-native link react-native-asr`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-asr` and add `RNAsr.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAsr.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.retu.asr.RNAsrPackage;` to the imports at the top of the file
  - Add `new RNAsrPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-asr'
  	project(':react-native-asr').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-asr/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-asr')
  	```


## Usage
```javascript
import RNAsr from 'react-native-asr';

// TODO: What to do with the module?
RNAsr;
```
  
