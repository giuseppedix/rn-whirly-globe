import React from 'react';
import PropTypes from 'prop-types';

import Map from '../Map';

import { decorateMapComponent } from '../utils';

class ScreenMarker extends React.PureComponent {
    // noinspection SpellCheckingInspection
    static propTypes = {
        map: PropTypes.instanceOf(Map),
        lon: PropTypes.number.isRequired,
        lat: PropTypes.number.isRequired,
        rotation: PropTypes.number,
        size: PropTypes.shape({
            width: PropTypes.number,
            height: PropTypes.number,
        }),
        offset: PropTypes.shape({
            x: PropTypes.number,
            y: PropTypes.number,
        }),
        selectable: PropTypes.bool,
        color: PropTypes.string,
        image: PropTypes.any,
    };

    static defaultProps = {
        selectable: false,
        size: {width: 40, height: 40},
    };

    _uuid = null;

    _applyingChanges = false;

    // noinspection JSUnusedGlobalSymbols
    getUUID() {
        return this._uuid;
    }

    initMapElement() {
        if (this._applyingChanges) {
            return;
        }
        const {
            map,
            size,
            image,
            color,
            offset,
            lat,lon,
            rotation,
            selectable,
        } = this.props;
        if (!map) {
            return console.warn('[ScreenMarker] Cannot map ref in props!');
        }
        this._applyingChanges = true;
        map.addScreenLabel({
            lat, lon, selectable,
            ...(rotation ? {rotation} : {}),
            ...(offset ? {offset} : {}),
            ...(image ? {image} : {}),
            ...(color ? {color} : {}),
            ...(size ? {size} : {}),
        }).then(uuid => {
            this._uuid = uuid;
        }).catch((error) => {
            console.warn('Cannot create ScreenMarker on Map!', error);
        }).then(() => {
            this._applyingChanges = false;
        })
    }

    componentDidMount() {
        this.initMapElement();
    }

    componentWillUnmount() {
        if (!this._uuid || !this.props.map) {
            return;
        }
        this.props.map.removeMapTilesLayer(this._uuid);
    }

    render() {
        return null;
    }
}

export default decorateMapComponent(ScreenMarker);