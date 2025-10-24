import { configureStore } from '@reduxjs/toolkit'
import { setupListeners } from '@reduxjs/toolkit/query'
import { api } from '@/services/api/apiSlice'
import authSlice from './slices/authSlice'
import uiSlice from './slices/uiSlice'
import reportsSlice from './slices/reportsSlice'

export const store = configureStore({
  reducer: {
    // RTK Query API
    [api.reducerPath]: api.reducer,
    // App slices
    auth: authSlice,
    ui: uiSlice,
    reports: reportsSlice,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [
          // Ignore these action types from serializability check
          'persist/PERSIST',
          'persist/REHYDRATE',
        ],
      },
    }).concat(api.middleware),
  devTools: process.env.NODE_ENV !== 'production',
})

// Infer the RootState and AppDispatch types from the store itself
export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

// Setup listeners for RTK Query
setupListeners(store.dispatch)