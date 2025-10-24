import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export interface Report {
  id: string
  title: string
  description: string
  status: 'pending' | 'in_progress' | 'resolved' | 'closed'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  category: string
  location: {
    latitude: number
    longitude: number
    address: string
  }
  attachments: string[]
  createdAt: string
  updatedAt: string
  assignedTo?: string
}

interface ReportsState {
  reports: Report[]
  selectedReport: Report | null
  filters: {
    status: string[]
    priority: string[]
    category: string[]
    dateRange: {
      start: string | null
      end: string | null
    }
  }
  pagination: {
    currentPage: number
    totalPages: number
    totalItems: number
    itemsPerPage: number
  }
  isLoading: boolean
  error: string | null
}

const initialState: ReportsState = {
  reports: [],
  selectedReport: null,
  filters: {
    status: [],
    priority: [],
    category: [],
    dateRange: {
      start: null,
      end: null,
    },
  },
  pagination: {
    currentPage: 1,
    totalPages: 0,
    totalItems: 0,
    itemsPerPage: 10,
  },
  isLoading: false,
  error: null,
}

const reportsSlice = createSlice({
  name: 'reports',
  initialState,
  reducers: {
    setReports: (state, action: PayloadAction<Report[]>) => {
      state.reports = action.payload
    },
    addReport: (state, action: PayloadAction<Report>) => {
      state.reports.unshift(action.payload)
    },
    updateReport: (state, action: PayloadAction<Report>) => {
      const index = state.reports.findIndex(report => report.id === action.payload.id)
      if (index !== -1) {
        state.reports[index] = action.payload
      }
    },
    deleteReport: (state, action: PayloadAction<string>) => {
      state.reports = state.reports.filter(report => report.id !== action.payload)
    },
    setSelectedReport: (state, action: PayloadAction<Report | null>) => {
      state.selectedReport = action.payload
    },
    setFilters: (state, action: PayloadAction<Partial<ReportsState['filters']>>) => {
      state.filters = { ...state.filters, ...action.payload }
    },
    setPagination: (state, action: PayloadAction<Partial<ReportsState['pagination']>>) => {
      state.pagination = { ...state.pagination, ...action.payload }
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
  },
})

export const {
  setReports,
  addReport,
  updateReport,
  deleteReport,
  setSelectedReport,
  setFilters,
  setPagination,
  setLoading,
  setError,
} = reportsSlice.actions

export default reportsSlice.reducer