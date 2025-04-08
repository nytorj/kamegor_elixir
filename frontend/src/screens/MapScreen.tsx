import React, { useState, useEffect, useRef, useCallback } from 'react';
import { StyleSheet, View, Text, PermissionsAndroid, Platform, Alert } from 'react-native';
import MapView, { Marker, PROVIDER_GOOGLE, Region } from 'react-native-maps';
import Geolocation from 'react-native-geolocation-service';
import { fetchSellersInViewport } from '../services/api'; // Import API function
import { MapSeller } from '../services/api'; // Import type if defined in api.ts
import _ from 'lodash'; // Import lodash for debouncing

// TODO: Import WebSocket connection logic

// Define a default region to use before current location is fetched
const DEFAULT_REGION: Region = {
    latitude: 37.78825,
    longitude: -122.4324,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
};

// Define radius for fetching sellers (in meters)
const FETCH_RADIUS_METERS = 5000; // Example: 5km

const MapScreen = () => {
    const [currentRegion, setCurrentRegion] = useState<Region | undefined>(undefined);
    const [mapReady, setMapReady] = useState(false); // Track if map is ready
    const [locationPermissionGranted, setLocationPermissionGranted] = useState(false);
    const [sellers, setSellers] = useState<MapSeller[]>([]); // State to hold seller data
    const mapRef = useRef<MapView>(null);

    // --- Location Permission ---
    const requestLocationPermission = async () => {
        // ... (permission logic remains the same) ...
        if (Platform.OS === 'ios') {
            const auth = await Geolocation.requestAuthorization('whenInUse');
            if (auth === 'granted') {
                setLocationPermissionGranted(true);
                getCurrentLocation();
            } else {
                Alert.alert("Permission Denied", "Location permission is required to show the map.");
                setCurrentRegion(DEFAULT_REGION); // Set default region if permission denied
            }
        } else if (Platform.OS === 'android') {
            try {
                const granted = await PermissionsAndroid.request(
                    PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
                    {
                        title: 'Location Permission',
                        message: 'Kamegor needs access to your location.',
                        buttonNeutral: 'Ask Me Later',
                        buttonNegative: 'Cancel',
                        buttonPositive: 'OK',
                    },
                );
                if (granted === PermissionsAndroid.RESULTS.GRANTED) {
                    setLocationPermissionGranted(true);
                    getCurrentLocation();
                } else {
                    Alert.alert("Permission Denied", "Location permission is required to show the map.");
                    setCurrentRegion(DEFAULT_REGION); // Set default region if permission denied
                }
            } catch (err) {
                console.warn(err);
                setCurrentRegion(DEFAULT_REGION); // Set default on error too
            }
        }
    };

    // --- Get Current Location ---
    const getCurrentLocation = () => {
        if (!locationPermissionGranted) return;

        Geolocation.getCurrentPosition(
            (position) => {
                console.log('Current Position:', position);
                const { latitude, longitude } = position.coords;
                const region: Region = {
                    latitude: latitude,
                    longitude: longitude,
                    latitudeDelta: 0.015,
                    longitudeDelta: 0.0121,
                };
                setCurrentRegion(region);
                // Animate map only if mapRef is available
                if (mapRef.current) {
                    mapRef.current.animateToRegion(region, 1000);
                }
                // Fetch initial sellers
                fetchSellersForRegion(region);
            },
            (error) => {
                console.log(error.code, error.message);
                Alert.alert("Location Error", "Could not get current location.");
                setCurrentRegion(DEFAULT_REGION);
                // Fetch for default region if location fails
                fetchSellersForRegion(DEFAULT_REGION);
            },
            { enableHighAccuracy: true, timeout: 15000, maximumAge: 10000 }
        );
    };

    useEffect(() => {
        requestLocationPermission();
    }, []);

    // --- Fetch Sellers ---
    const fetchSellersForRegion = async (region: Region) => {
        if (!region) return;
        console.log(`Fetching sellers for region: ${region.latitude}, ${region.longitude}`);
        try {
            const fetchedSellers = await fetchSellersInViewport(
                region.latitude,
                region.longitude,
                FETCH_RADIUS_METERS
            );
            console.log('Fetched sellers:', fetchedSellers.length);
            setSellers(fetchedSellers);
        } catch (error) {
            console.error("Failed to fetch sellers:", error);
            // Optionally show an error message to the user
        }
    };

    // Debounced version of fetchSellersForRegion
    const debouncedFetchSellers = useCallback(_.debounce(fetchSellersForRegion, 1000), []);

    // Handler for when the map region changes (user pans/zooms)
    const handleRegionChangeComplete = (region: Region) => {
        console.log("Region changed:", region);
        setCurrentRegion(region); // Update state to reflect current view
        debouncedFetchSellers(region); // Fetch sellers for the new region (debounced)
    };


    // --- WebSocket Connection ---
    // TODO: Implement useEffect to establish WebSocket connection
    // const connectWebSocket = () => { ... }

    // --- Render ---
    return (
        <View style={styles.container}>
            <MapView
                ref={mapRef}
                provider={PROVIDER_GOOGLE}
                style={styles.map}
                initialRegion={DEFAULT_REGION} // Start with default
                // region={currentRegion} // Let map control region internally after initialRegion
                showsUserLocation={locationPermissionGranted}
                onMapReady={() => setMapReady(true)} // Set map ready flag
                // Call debounced fetch when region change *completes*
                onRegionChangeComplete={handleRegionChangeComplete}
            >
                {sellers.map(seller => (
                    // Ensure seller location exists before rendering marker
                    seller.location && (
                        <Marker
                            key={seller.user_id} // Use user_id as key
                            coordinate={{ latitude: seller.location.latitude, longitude: seller.location.longitude }}
                            title={seller.username}
                            description={`Rating: ${seller.rating_avg} | Status: ${seller.presence_status}`}
                        // TODO: Use custom marker image (profile pic)
                        // TODO: Add onPress handler to navigate to Seller Profile
                        />
                    )
                ))}
            </MapView>
            {/* Loading/Permission indicator could be added here if needed */}
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