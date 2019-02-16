import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Map, TilesLayer } from 'rn-whirly-globe';

export default class App extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Map>
          <TilesLayer mb='geography­-class_medres' />
        </Map>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});
