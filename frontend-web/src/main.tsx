import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App.tsx'
import './assets/styles/index-fixed.css'
import './assets/styles/desktop-enhancements.css'

// Configure theme
const root = document.documentElement
const theme = localStorage.getItem('theme') || 'light'
root.setAttribute('data-theme', theme)

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)