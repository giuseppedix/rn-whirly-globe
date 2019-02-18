import React from 'react';
import PropTypes from 'prop-types';

import Map from '../Map';

import { decorateMapComponent } from '../utils';

class ScreenLabel extends React.PureComponent {
    // noinspection SpellCheckingInspection
    static propTypes = {
        map: PropTypes.instanceOf(Map),
        text: PropTypes.string.isRequired,
        lon: PropTypes.number.isRequired,
        lat: PropTypes.number.isRequired,
        rotation: PropTypes.number,
        offset: PropTypes.shape({
            x: PropTypes.number,
            y: PropTypes.number,
        }),
        outlineColor: PropTypes.string,
        outlineSize: PropTypes.number,
        fontFamily: PropTypes.string,
        fontSize: PropTypes.number,
        selectable: PropTypes.bool,
        color: PropTypes.string,
    };

    static defaultProps = {
        selectable: false,
        color: '#000000',
        fontSize: 14
    };

    _uuid = null;

    // noinspection JSUnusedGlobalSymbols
    getUUID() {
        return this._uuid;
    }

    componentDidMount() {
        const {
            map,
            text,
            color,
            offset,
            lat,lon,
            fontSize,
            rotation,
            fontFamily,
            selectable,
            outlineSize,
            outlineColor,
        } = this.props;
        if (!map) {
            return console.warn('[ScreenLabel] Cannot map ref in props!');
        }
        map.addScreenLabel({
            text, lat, lon, selectable, fontSize, color,
            ...(outlineColor ? {outlineColor} : {}),
            ...(outlineSize ? {outlineSize} : {}),
            ...(fontFamily ? {fontFamily} : {}),
            ...(rotation ? {rotation} : {}),
            ...(offset ? {offset} : {}),
        }).then(uuid => {
            this._uuid = uuid;
        }).catch((error) => {
            console.warn('Cannot create ScreenLabel on Map!', error);
        });
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

export default decorateMapComponent(ScreenLabel);