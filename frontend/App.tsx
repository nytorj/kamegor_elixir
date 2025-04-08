import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { ActivityIndicator, View, StyleSheet, Text } from 'react-native'; // Added Text import

import LoginScreen from './src/screens/LoginScreen'; // Adjust path if needed
import SignupScreen from './src/screens/SignupScreen'; // Adjust path if needed
// TODO: Import your main app screen(s) later
// import MainMapScreen from './src/screens/MainMapScreen';

import { AuthProvider, useAuth } from './src/context/AuthContext'; // Adjust path if needed

const Stack = createStackNavigator();

// Placeholder for the main part of your application after login
const MainAppScreen = () => {
  // This would likely be another navigator (e.g., TabNavigator)
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      {/* Replace with your actual main screen component, e.g., Map */}
      <Text>Main App Screen (Map, Profile, etc.)</Text>
      {/* TODO: Add Logout button */}
    </View>
  );
};


// Navigator component that decides which stack to show
const AppNavigator = () => {
  const auth = useAuth(); // Get the whole context value

  // Handle loading state
  if (auth?.isLoading) { // Check isLoading safely
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {auth?.isAuthenticated ? ( // Check isAuthenticated safely
          // User is signed in, show main app
          <Stack.Screen name="MainApp" component={MainAppScreen} />
        ) : (
          // User is not signed in, show auth flow
          <>
            <Stack.Screen name="Login" component={LoginScreen} />
            <Stack.Screen name="Signup" component={SignupScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};


// Main App component
const App = () => {
  return (
    <AuthProvider>
      <AppNavigator />
    </AuthProvider>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
