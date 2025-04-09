import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { ActivityIndicator, View, StyleSheet, Text } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import LoginScreen from './src/screens/LoginScreen';
import SignupScreen from './src/screens/SignupScreen';
import MapScreen from './src/screens/MapScreen'; // Import MapScreen

import { AuthProvider, useAuth } from './src/context/AuthContext';

// Define ParamList types for navigators
type AuthStackParamList = {
  Login: undefined;
  Signup: undefined;
};

type MainStackParamList = {
  Map: undefined;
  // Add other main screens like Profile later
};

const AuthStack = createStackNavigator<AuthStackParamList>();
const MainStack = createStackNavigator<MainStackParamList>();

// Auth Navigator Stack
const AuthNavigator = () => (
  <AuthStack.Navigator screenOptions={{ headerShown: false }}>
    <AuthStack.Screen name="Login" component={LoginScreen} />
    <AuthStack.Screen name="Signup" component={SignupScreen} />
  </AuthStack.Navigator>
);

// Main App Navigator Stack
const MainNavigator = () => (
  <MainStack.Navigator screenOptions={{ headerShown: false }}>
    {/* Use MapScreen here */}
    <MainStack.Screen name="Map" component={MapScreen} />
    {/* TODO: Add ProfileScreen, SettingsScreen etc. */}
  </MainStack.Navigator>
);


// Root Navigator component that decides which stack to show
const AppNavigator = () => {
  const auth = useAuth();

  if (auth?.isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      {auth?.isAuthenticated ? <MainNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  );
};


// Main App component
const App = () => {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <AppNavigator />
      </AuthProvider>
    </SafeAreaProvider>
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
