import React from 'react';
import PropTypes from 'prop-types';
import { MapProvider } from '../utils';
import { requireNativeComponent, findNodeHandle, Platform, NativeModules } from 'react-native';

const RNWhirlyGlobeMapView = requireNativeComponent('RNWhirlyGlobeMapView', Map);

export default class Map extends React.PureComponent {

    static propTypes = {
        globeMap: PropTypes.bool,
    };

    static defaultProps = {
        globeMap: false,
    };

    _map = null;

    // noinspection JSMethodCanBeStatic
    _uiManagerCommand(name) {
        return NativeModules.UIManager['RNWhirlyGlobeMapView'].Commands[name];
    }

    // noinspection JSMethodCanBeStatic
    _mapManagerCommand(name) {
        return NativeModules['RNWhirlyGlobeMapViewManager'][name];
    }

    _runCommand(name, args) {
        switch (Platform.OS) {
            case 'android':
                return NativeModules.UIManager.dispatchViewManagerCommand(
                    findNodeHandle(this),
                    this._uiManagerCommand(name),
                    args
                );

            case 'ios':
                return this._mapManagerCommand(name)(findNodeHandle(this), ...args);

            default:
                return Promise.reject(`Invalid platform was passed: ${Platform.OS}`);
        }
    }

    addTilesLayer(config) {
        return this._runCommand('addTilesLayer', [config]);
    }

    addScreenMarker(config) {
        return this._runCommand('addScreenMarker', [config]);
    }

    addScreenLabel(config) {
        return this._runCommand('addScreenMarker', [config]);
    }

    addVectorObject(config) {
        return this._runCommand('addVectorObject', [config]);
    }

    removeMapObject(uuid) {
        return this._runCommand('removeMapObject', [uuid]);
    }

    removeMapTilesLayer(uuid) {
        return this._runCommand('removeMapTilesLayer', [uuid]);
    }

    animateToPosition(config) {
        return this._runCommand('animateToPosition', [config]);
    }

    startLocationTracking(config) {
        return this._runCommand('startLocationTracking', [config]);
    }

    stopLocationTracking() {
        return this._runCommand('stopLocationTracking', []);
    }

    render() {
        const {
            children,
            ...more
        } = this.props;
        return (
            <RNWhirlyGlobeMapView {...more}
                                  ref={ref => this._map = ref}>
                <MapProvider value={this}>
                { typeof children === 'function' ? children(this) : children }
                </MapProvider>
            </RNWhirlyGlobeMapView>
        );
    }
}