import { useAuthStore } from '@/store/authStore';

export interface User {
  id: string;
  first_name: string | null;
  last_name: string | null;
  full_name: string;
  email: string;
  phone: string | null;
  role: string;
  role_display_name: string;
  organization_id: string | null;
  organization_name: string | null;
  is_active: boolean;
  two_factor_enabled: boolean;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface UsersListResponse {
  current_page: number;
  data: User[];
  first_page_url: string;
  from: number;
  last_page: number;
  last_page_url: string;
  next_page_url: string | null;
  path: string;
  per_page: number;
  prev_page_url: string | null;
  to: number;
  total: number;
}

export interface Role {
  id: string;
  name: string;
  display_name: string;
  description: string | null;
  permissions: string[] | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
}

class AdminApiService {
  private baseUrl = 'http://localhost:8000/api/v1/admin';

  /**
   * Get authorization header with bearer token
   */
  private getAuthHeaders(): HeadersInit {
    const token = useAuthStore.getState().token?.access_token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': `Bearer ${token}`,
    };
  }

  /**
   * Get list of users with optional filters
   */
  async getUsers(params?: {
    search?: string;
    status?: 'all' | 'active' | 'inactive';
    role_id?: string;
    page?: number;
    per_page?: number;
    sort_by?: string;
    sort_order?: 'asc' | 'desc';
  }): Promise<ApiResponse<UsersListResponse>> {
    try {
      const queryParams = new URLSearchParams();
      
      if (params?.search) queryParams.append('search', params.search);
      if (params?.status && params.status !== 'all') queryParams.append('status', params.status);
      if (params?.role_id) queryParams.append('role_id', params.role_id);
      if (params?.page) queryParams.append('page', params.page.toString());
      if (params?.per_page) queryParams.append('per_page', params.per_page.toString());
      if (params?.sort_by) queryParams.append('sort_by', params.sort_by);
      if (params?.sort_order) queryParams.append('sort_order', params.sort_order);

      const url = `${this.baseUrl}/users?${queryParams.toString()}`;
      const response = await fetch(url, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error fetching users:', error);
      return {
        success: false,
        message: 'Erreur lors de la récupération des utilisateurs',
      };
    }
  }

  /**
   * Get a single user by ID
   */
  async getUser(id: string): Promise<ApiResponse<User>> {
    try {
      const response = await fetch(`${this.baseUrl}/users/${id}`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error fetching user:', error);
      return {
        success: false,
        message: 'Erreur lors de la récupération de l\'utilisateur',
      };
    }
  }

  /**
   * Create a new user
   */
  async createUser(userData: {
    email: string;
    phone?: string;
    password: string;
    role_id: string;
    organization_id?: string;
    is_active?: boolean;
  }): Promise<ApiResponse<User>> {
    try {
      const response = await fetch(`${this.baseUrl}/users`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(userData),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error creating user:', error);
      return {
        success: false,
        message: 'Erreur lors de la création de l\'utilisateur',
      };
    }
  }

  /**
   * Update a user
   */
  async updateUser(
    id: string,
    userData: Partial<{
      email: string;
      phone: string;
      password: string;
      role_id: string;
      organization_id: string;
      is_active: boolean;
      two_factor_enabled: boolean;
    }>
  ): Promise<ApiResponse<User>> {
    try {
      const response = await fetch(`${this.baseUrl}/users/${id}`, {
        method: 'PUT',
        headers: this.getAuthHeaders(),
        body: JSON.stringify(userData),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error updating user:', error);
      return {
        success: false,
        message: 'Erreur lors de la mise à jour de l\'utilisateur',
      };
    }
  }

  /**
   * Delete a user (soft delete)
   */
  async deleteUser(id: string): Promise<ApiResponse<void>> {
    try {
      const response = await fetch(`${this.baseUrl}/users/${id}`, {
        method: 'DELETE',
        headers: this.getAuthHeaders(),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error deleting user:', error);
      return {
        success: false,
        message: 'Erreur lors de la suppression de l\'utilisateur',
      };
    }
  }

  /**
   * Toggle user active status
   */
  async toggleUserActive(id: string): Promise<ApiResponse<{ is_active: boolean }>> {
    try {
      const response = await fetch(`${this.baseUrl}/users/${id}/toggle-active`, {
        method: 'POST',
        headers: this.getAuthHeaders(),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error toggling user status:', error);
      return {
        success: false,
        message: 'Erreur lors du changement de statut',
      };
    }
  }

  /**
   * Get list of roles
   */
  async getRoles(): Promise<ApiResponse<Role[]>> {
    try {
      const response = await fetch(`${this.baseUrl}/roles`, {
        method: 'GET',
        headers: this.getAuthHeaders(),
      });

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error fetching roles:', error);
      return {
        success: false,
        message: 'Erreur lors de la récupération des rôles',
      };
    }
  }
}

export const adminApiService = new AdminApiService();
