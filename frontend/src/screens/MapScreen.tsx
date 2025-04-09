import React from 'react';
import { StyleSheet, View } from 'react-native';
import MapView, { Region } from 'react-native-maps'; // Only import MapView and Region for now

// Define a default region
const DEFAULT_REGION: Region = {
    latitude: 37.78825,
    longitude: -122.4324,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
};

const MapScreen = () => {
    // We'll add state and logic later
    return (
        <View style={styles.container}>
            <MapView
                style={styles.map}
                initialRegion={DEFAULT_REGION} // Use default region
            // No provider specified, defaults to Apple Maps on iOS, Google Maps on Android (if available)
            >
                {/* Markers will be added later */}
            </MapView>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        ...StyleSheet.absoluteFillObject,
        justifyContent: 'flex-end',
        alignItems: 'center',
    },
    map: {
        ...StyleSheet.absoluteFillObject,
    },
});

export default MapScreen;