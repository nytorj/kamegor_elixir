import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet, Alert } from 'react-native';
import { registerUser } from '../services/api'; // Import from api.ts
import { StackNavigationProp } from '@react-navigation/stack';

// Define navigation param types
type AuthStackParamList = {
    Login: undefined;
    Signup: undefined;
};

type SignupScreenNavigationProp = StackNavigationProp<AuthStackParamList, 'Signup'>;

interface Props {
    navigation: SignupScreenNavigationProp;
}

const SignupScreen: React.FC<Props> = ({ navigation }) => {
    const [email, setEmail] = useState<string>('');
    const [password, setPassword] = useState<string>('');
    const [username, setUsername] = useState<string>('');
    const [isLoading, setIsLoading] = useState<boolean>(false);

    const handleSignup = async () => {
        if (!email || !password || !username) {
            Alert.alert('Error', 'Please fill in all fields.');
            return;
        }
        setIsLoading(true);
        try {
            // Pass correct structure expected by api.ts
            const userData = { email, password, username };
            const result = await registerUser(userData);
            console.log('Signup successful:', result);
            Alert.alert('Success', 'Account created successfully! Please log in.');
            navigation.navigate('Login');
        } catch (error: any) {
            console.error('Signup failed:', error);
            // Improved error message extraction for validation errors
            const message = error?.errors
                ? Object.entries(error.errors)
                    .map(([field, messages]) => `${field} ${(messages as string[]).join(', ')}`)
                    .join('\n')
                : error?.message || 'Could not create account.';
            Alert.alert('Signup Failed', message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Create Account</Text>
            <TextInput
                style={styles.input}
                placeholder="Username"
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
            />
            <TextInput
                style={styles.input}
                placeholder="Email"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
            />
            <TextInput
                style={styles.input}
                placeholder="Password"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
            />
            <Button title={isLoading ? "Signing up..." : "Sign Up"} onPress={handleSignup} disabled={isLoading} />
            <Button title="Already have an account? Login" onPress={() => navigation.navigate('Login')} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        padding: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 20,
        textAlign: 'center',
    },
    input: {
        height: 40,
        borderColor: 'gray',
        borderWidth: 1,
        marginBottom: 12,
        paddingHorizontal: 10,
    },
});

export default SignupScreen;