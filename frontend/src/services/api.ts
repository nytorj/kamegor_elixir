import axios, { AxiosInstance } from 'axios';

// Define interfaces for expected data structures
interface UserData {
    email: string;
    password?: string; // Optional for login response
    username?: string; // Optional for login response
    id?: number; // Optional, might be returned on registration/login
}

interface ProfileData {
    id?: number;
    username?: string;
    description?: string;
    is_seller?: boolean;
    rating_avg?: number;
    presence_status?: 'online' | 'offline' | 'streaming';
    user_id?: number;
    location?: { latitude: number; longitude: number } | null;
}

interface SellerData {
    is_seller: boolean;
    description?: string;
}

interface LocationData {
    latitude: number;
    longitude: number;
}

interface LoginCredentials {
    email: string;
    password: string;
}

interface LoginResponse {
    message: string;
    user_id?: number; // Assuming backend might return this
}

interface LogoutResponse {
    message: string;
}

interface MapSeller {
    id: number;
    user_id: number;
    username: string;
    rating_avg: number;
    presence_status: 'online' | 'offline' | 'streaming';
    location: { latitude: number; longitude: number } | null;
    // pic_url?: string; // Add later if needed
}

// TODO: Replace with your actual backend URL, potentially from environment variables
const API_BASE_URL: string = 'http://localhost:4000/api'; // Default Phoenix dev port

const apiClient: AxiosInstance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
    // withCredentials: true, // Important for session-based auth if backend/frontend are on different origins
});

// --- Authentication Endpoints ---

export const registerUser = async (userData: UserData): Promise<UserData> => {
    try {
        const response = await apiClient.post<{ user: UserData }>('/users', { user: userData });
        return response.data.user; // Assuming backend returns the created user under 'user' key
    } catch (error: any) {
        console.error('Registration Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Registration failed');
    }
};

export const loginUser = async (credentials: LoginCredentials): Promise<LoginResponse> => {
    try {
        const response = await apiClient.post<LoginResponse>('/sessions', { session: credentials });
        return response.data;
    } catch (error: any) {
        console.error('Login Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Login failed');
    }
};

export const logoutUser = async (): Promise<LogoutResponse> => {
    try {
        const response = await apiClient.delete<LogoutResponse>('/sessions');
        return response.data;
    } catch (error: any) {
        console.error('Logout Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Logout failed');
    }
};


// --- Profile Endpoints ---

// TODO: Add function to set auth token/header if using token-based auth

export const updateSellerStatus = async (sellerData: SellerData): Promise<ProfileData> => {
    try {
        const response = await apiClient.put<{ profile: ProfileData }>('/profiles/me/seller', { profile: sellerData });
        return response.data.profile; // Assuming backend returns updated profile under 'profile'
    } catch (error: any) {
        console.error('Update Seller Status Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Update seller status failed');
    }
};

export const updateLocation = async (locationData: LocationData): Promise<ProfileData> => {
    try {
        const response = await apiClient.post<{ profile: ProfileData }>('/location', locationData);
        return response.data.profile; // Assuming backend returns updated profile under 'profile'
    } catch (error: any) {
        console.error('Update Location Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Update location failed');
    }
};

// --- Map Endpoints ---

export const fetchSellersInViewport = async (lat: number, lon: number, radius: number): Promise<MapSeller[]> => {
    try {
        const response = await apiClient.get<{ data: MapSeller[] }>('/map/sellers', {
            params: { lat, lon, radius }
        });
        return response.data.data; // Backend wraps sellers in a "data" key
    } catch (error: any) {
        console.error('Fetch Sellers Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Fetching sellers failed');
    }
};


export default apiClient;