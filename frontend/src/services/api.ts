import axios, { AxiosInstance } from 'axios';

// Define interfaces for expected data structures
export interface UserData {
    email: string;
    password?: string;
    username?: string;
    id?: number;
}

export interface ProfileData {
    id?: number;
    username?: string;
    description?: string;
    is_seller?: boolean;
    rating_avg?: number;
    presence_status?: 'online' | 'offline' | 'streaming';
    user_id?: number;
    location?: { latitude: number; longitude: number } | null;
}

export interface SellerData {
    is_seller: boolean;
    description?: string;
}

export interface LocationData {
    latitude: number;
    longitude: number;
}

export interface LoginCredentials {
    email: string;
    password: string;
}

export interface LoginResponse {
    message: string;
    user_id?: number;
}

export interface LogoutResponse {
    message: string;
}

export interface MapSeller {
    id: number;
    user_id: number;
    username: string;
    rating_avg: number;
    presence_status: 'online' | 'offline' | 'streaming';
    location: { latitude: number; longitude: number } | null;
}

const API_BASE_URL: string = 'http://localhost:4000/api';

const apiClient: AxiosInstance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
});

// --- Authentication Endpoints ---

export const registerUser = async (userData: UserData): Promise<UserData> => {
    try {
        const response = await apiClient.post<UserData>('/users', { user: userData });
        return response.data;
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

export const updateSellerStatus = async (sellerData: SellerData): Promise<ProfileData> => {
    try {
        const response = await apiClient.put<ProfileData>('/profiles/me/seller', { profile: sellerData });
        return response.data;
    } catch (error: any) {
        console.error('Update Seller Status Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Update seller status failed');
    }
};

export const updateLocation = async (locationData: LocationData): Promise<ProfileData> => {
    try {
        const response = await apiClient.post<ProfileData>('/location', locationData);
        return response.data;
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
        return response.data.data;
    } catch (error: any) {
        console.error('Fetch Sellers Error:', error.response?.data || error.message);
        throw error.response?.data || new Error('Fetching sellers failed');
    }
};

export default apiClient;