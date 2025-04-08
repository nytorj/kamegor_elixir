import React from 'react';
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';

const App = function () {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>
          Kamegor
        </Text>
        <Text style={styles.subtitle}>
          conecting people...
        </Text>
      </View>
    </SafeAreaView>
  );
};
const styles = StyleSheet.create({
  safeArea: {
    flex: 1, // Ensure SafeAreaView takes full screen height
  },
  container: {
    flex: 1, // Ensure the inner view takes full available space
    justifyContent: 'center', // Center content vertically
    alignItems: 'center', // Center content horizontally
    backgroundColor: '#F5FCFF', // A light background color
  },
  title: {
    color: '#671425', // Dark text color
    fontSize: 48, // Make the title larger
    fontWeight: 'bold', // Make the title bold
    margin: 20, // Add some margin around the text
  },
  subtitle: {
    color: '#671425', // Dark text color
    fontSize: 10, // Make the subtitle smaller than the title
  },
});

export default App;

