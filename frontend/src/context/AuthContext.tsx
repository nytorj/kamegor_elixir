import React, { createContext, useState, useContext, useEffect, ReactNode } from 'react';
import * as Keychain from 'react-native-keychain';
import apiClient, { loginUser as apiLogin, logoutUser as apiLogout } from '../services/api'; // Import from api.ts

// Define the shape of the context value
interface AuthContextType {
    userId: string | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    login: (email: string, password: string) => Promise<any>;
    logout: () => Promise<void>;
}

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
                    setUserId(credentials.username);
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
            const result = await apiClient.post('/sessions', { session: { email, password } });
            const loggedInUserId = result.data?.user_id;

            if (loggedInUserId) {
                const userIdStr = loggedInUserId.toString();
                setUserId(userIdStr);
                await Keychain.setGenericPassword(userIdStr, 'session');
                console.log('Credentials saved for user ' + userIdStr);
            } else {
                setUserId('authenticated'); // Placeholder
                console.log('Login successful, session cookie likely set.');
            }
            return result.data;
        } catch (error: any) {
            console.error('AuthContext Login Error:', error);
            throw error.response?.data || error;
        }
    };

    const logout = async (): Promise<void> => {
        try {
            await apiLogout();
        } catch (error) {
            console.error('API Logout Error:', error);
        } finally {
            setUserId(null);
            await Keychain.resetGenericPassword();
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

export const useAuth = (): AuthContextType => {
    const context = useContext(AuthContext);
    if (context === null) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};