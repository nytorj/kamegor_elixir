import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import * as Keychain from 'react-native-keychain';
import apiClient, { loginUser as apiLogin, logoutUser as apiLogout } from '../services/api'; // Import specific functions if needed, or use apiClient directly

// Define the shape of the context value
interface AuthContextType {
    userId: string | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    login: (email: string, password: string) => Promise<any>; // Consider a more specific return type if possible
    logout: () => Promise<void>;
}

// Create the context with a default value (null or a default object structure)
const AuthContext = createContext<AuthContextType | null>(null);

interface AuthProviderProps {
    children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
    const [userId, setUserId] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState<boolean>(true);

    useEffect(() => {
        const loadCredentials = async () => {
            try {
                const credentials = await Keychain.getGenericPassword();
                if (credentials) {
                    console.log('Credentials successfully loaded for user ' + credentials.username);
                    // TODO: Validate token/session if necessary
                    setUserId(credentials.username); // Assuming username stores the user ID string
                    // TODO: Set auth header if using token auth
                    // apiClient.defaults.headers.common['Authorization'] = `Bearer ${credentials.password}`;
                } else {
                    console.log('No credentials stored.');
                }
            } catch (error) {
                console.error("Keychain couldn't be accessed!", error);
            } finally {
                setIsLoading(false);
            }
        };

        loadCredentials();
    }, []);

    const login = async (email: string, password: string): Promise<any> => {
        try {
            // Use the imported apiLogin or call apiClient directly
            const result = await apiClient.post('/sessions', { session: { email, password } });
            const loggedInUserId = result.data?.user_id;

            if (loggedInUserId) {
                const userIdStr = loggedInUserId.toString();
                setUserId(userIdStr);
                await Keychain.setGenericPassword(userIdStr, 'session'); // Store user ID as string
                console.log('Credentials saved for user ' + userIdStr);
            } else {
                setUserId('authenticated'); // Placeholder if no ID returned but login succeeded
                console.log('Login successful, session cookie likely set.');
            }
            // TODO: Handle token storage/header if using token auth
            return result.data;
        } catch (error: any) {
            console.error('AuthContext Login Error:', error);
            // Rethrow a structured error if possible
            throw error.response?.data || error;
        }
    };

    const logout = async (): Promise<void> => {
        try {
            await apiLogout(); // Use imported apiLogout or apiClient.delete
        } catch (error) {
            console.error('API Logout Error:', error);
        } finally {
            setUserId(null);
            await Keychain.resetGenericPassword();
            // TODO: Clear auth token header if using token auth
            // delete apiClient.defaults.headers.common['Authorization'];
            console.log('Credentials reset.');
        }
    };

    const value: AuthContextType = {
        userId,
        isAuthenticated: !!userId,
        isLoading,
        login,
        logout,
    };

    return (
        <AuthContext.Provider value={value}>
            {children}
        </AuthContext.Provider>
    );
};

// Custom hook to use the auth context
export const useAuth = (): AuthContextType => {
    const context = useContext(AuthContext);
    if (context === null) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};