
# rn-whirly-globe

## Getting started

`$ npm install rn-whirly-globe --save`

### Mostly automatic installation

`$ react-native link rn-whirly-globe`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `rn-whirly-globe` and add `RNWhirlyGlobe.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNWhirlyGlobe.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import org.itrabbit.rnwg.RNWhirlyGlobePackage;` to the imports at the top of the file
  - Add `new RNWhirlyGlobePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':rn-whirly-globe'
  	project(':rn-whirly-globe').projectDir = new File(rootProject.projectDir, 	'../node_modules/rn-whirly-globe/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':rn-whirly-globe')
  	```


## Usage
```javascript
import RNWhirlyGlobe from 'rn-whirly-globe';

// TODO: What to do with the module?
RNWhirlyGlobe;
```
  