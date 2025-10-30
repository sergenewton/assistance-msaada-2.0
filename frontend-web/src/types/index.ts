// Base types
export interface BaseEntity {
  id: string
  createdAt: string
  updatedAt: string
}

// API Response types
export interface ApiResponse<T = any> {
  data: T
  message: string
  success: boolean
  errors?: Record<string, string[]>
}

export interface PaginatedResponse<T = any> {
  data: T[]
  pagination: {
    current_page: number
    last_page: number
    per_page: number
    total: number
  }
  links: {
    first: string
    last: string
    prev: string | null
    next: string | null
  }
}

// Form types
export interface FormField {
  name: string
  label: string
  type: 'text' | 'email' | 'password' | 'select' | 'textarea' | 'file' | 'date'
  required?: boolean
  placeholder?: string
  options?: { label: string; value: string }[]
  validation?: {
    required?: string
    pattern?: {
      value: RegExp
      message: string
    }
    minLength?: {
      value: number
      message: string
    }
    maxLength?: {
      value: number
      message: string
    }
  }
}

// Location types
export interface Location {
  latitude: number
  longitude: number
  address: string
  city?: string
  region?: string
  country?: string
}

// File upload types
export interface UploadedFile {
  id: string
  name: string
  url: string
  type: string
  size: number
  uploadedAt: string
}

// Chart data types
export interface ChartData {
  labels: string[]
  datasets: {
    label: string
    data: number[]
    backgroundColor?: string | string[]
    borderColor?: string | string[]
    borderWidth?: number
  }[]
}

// Menu item type
export interface MenuItem {
  id: string
  label: string
  icon?: string
  path?: string
  children?: MenuItem[]
  permissions?: string[]
}

// Re-export dashboard types
export * from './dashboard';