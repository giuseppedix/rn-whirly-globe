import { NativeModules } from 'react-native';

import MapComponent from './Map';
import TilesLayerComponent from './TilesLayer';
import ScreenLabelComponent from './ScreenLabel';
import ScreenMarkerComponent from './ScreenMarker';

const { RNWhirlyGlobe } = NativeModules;
// noinspection JSUnusedGlobalSymbols
export const Map = MapComponent;
// noinspection JSUnusedGlobalSymbols
export const TilesLayer = TilesLayerComponent;
// noinspection JSUnusedGlobalSymbols
export const ScreenLabel = ScreenLabelComponent;
// noinspection JSUnusedGlobalSymbols
export const ScreenMarker = ScreenMarkerComponent;
// noinspection JSUnusedGlobalSymbols
export default RNWhirlyGlobe;