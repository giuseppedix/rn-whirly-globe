import { NativeModules } from 'react-native';

import MapComponent from './Map';
import TilesLayerComponent from './TilesLayer';

const { RNWhirlyGlobe } = NativeModules;

export const Map = MapComponent;
export const TilesLayer = TilesLayerComponent;

export default RNWhirlyGlobe;