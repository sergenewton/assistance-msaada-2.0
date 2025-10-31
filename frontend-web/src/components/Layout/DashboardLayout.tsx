import React, { useState } from 'react';
import { Header } from './Header';
import { Sidebar } from './Sidebar';
import { NavigationItem, UserRole } from '@/types/dashboard';

interface DashboardLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
  navigationItems: NavigationItem[];
  userRole: UserRole;
  className?: string;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  title,
  subtitle,
  navigationItems,
  userRole,
  className = ''
}) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  const toggleSidebar = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const closeSidebar = () => {
    setSidebarOpen(false);
  };

  const toggleSidebarCollapse = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  return (
    <div className={`h-screen bg-gray-50 dark:bg-gray-900 flex overflow-hidden ${className}`}>
      {/* Sidebar - Fixed */}
      <Sidebar
        isOpen={sidebarOpen}
        onClose={closeSidebar}
        navigationItems={navigationItems}
        userRole={userRole}
        isCollapsed={sidebarCollapsed}
        onToggleCollapse={toggleSidebarCollapse}
      />

      {/* Main content area */}
      <div className="flex-1 flex flex-col min-w-0 h-full">
        {/* Header - Fixed */}
        <Header
          onToggleSidebar={toggleSidebar}
          title={title}
          subtitle={subtitle}
        />

        {/* Main content - Scrollable */}
        <main className="flex-1 p-4 sm:p-6 lg:p-8 overflow-y-auto overflow-x-hidden">
          {children}
        </main>
      </div>
    </div>
  );
};