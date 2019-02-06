
# react-native-whirly-globe

## Getting started

`$ npm install react-native-whirly-globe --save`

### Mostly automatic installation

`$ react-native link react-native-whirly-globe`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-whirly-globe` and add `RNWhirlyGlobe.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNWhirlyGlobe.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import org.itrabbit.rnwg.RNWhirlyGlobePackage;` to the imports at the top of the file
  - Add `new RNWhirlyGlobePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-whirly-globe'
  	project(':react-native-whirly-globe').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-whirly-globe/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-whirly-globe')
  	```


## Usage
```javascript
import RNWhirlyGlobe from 'react-native-whirly-globe';

// TODO: What to do with the module?
RNWhirlyGlobe;
```
  