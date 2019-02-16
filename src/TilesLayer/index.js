import React from 'react';
import PropTypes from 'prop-types';

import Map from '../Map';

import { decorateMapComponent } from '../utils';

class TilesLayer extends React.PureComponent {
    static propTypes = {
        map: PropTypes.instanceOf(Map),
        mb: PropTypes.string,
        useVectorMbTiles: PropTypes.oneOf(['none', 'mapbox', 'maply']),
        source: PropTypes.shape({
            uri: PropTypes.string.isRequired,
            cacheDir: PropTypes.string,
            ext: PropTypes.string,
            minZoom: PropTypes.number,
            maxZoom: PropTypes.number,
        }),
        drawPriority: PropTypes.number,
        singleLevelLoading: PropTypes.bool,
        requireElev: PropTypes.bool,
        waitLoad: PropTypes.bool,
    };

    static defaultProps = {
        drawPriority: 0,
        useVectorMbTiles: 'none',
        singleLevelLoading: false,
        requireElev: false,
        waitLoad: true,
    };

    _uuid = null;

    // noinspection JSUnusedGlobalSymbols
    getUUID() {
        return this._uuid;
    }

    componentDidMount() {
        const {
            mb,
            map,
            source,
            drawPriority,
            singleLevelLoading,
            useVectorMbTiles,
            requireElev,
            waitLoad,
        } = this.props;
        if (!map) {
            return console.warn('[TilesLayer] Cannot map ref in props!');
        }
        map.addTilesLayer({
            ...(source ? {source} : {mb}),
            singleLevelLoading,
            useVectorMbTiles,
            drawPriority,
            requireElev,
            waitLoad,
        }).then(uuid => {
            this._uuid = uuid;
        }).catch((error) => {
            console.warn('Cannot create TilesLayer on Map!', error);
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

export default decorateMapComponent(TilesLayer);