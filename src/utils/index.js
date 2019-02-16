import React from 'react';

const { Provider, Consumer } = React.createContext(null);

export const MapProvider = Provider;

export function decorateMapComponent(Component) {
    return function HocMapComponent(props) {
        return (
            <Consumer>
                { (map) => <Component {...props} map={map} /> }
            </Consumer>
        );
    };
}