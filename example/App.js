import React from 'react';
import { Map, TilesLayer } from 'rn-whirly-globe';
import { StyleSheet, View, Switch } from 'react-native';

export default class App extends React.Component {
  state = {
    globeMap: false
  };

  render() {
    return (
      <View style={styles.container}>
        <Map globeMap={this.state.globeMap} style={{flex: 1}}>
          <TilesLayer mb='global' waitLoad={true} requireElev={true} />
        </Map>
        <Switch style={styles.switch}
                value={this.state.globeMap}
                onValueChange={value => this.setState({globeMap: value})} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5FCFF',
  },
  switch: {
    position: 'absolute',
    top: 64, right: 18
  }
});
