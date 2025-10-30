import React, { useState } from 'react';
import { NavigationItem, UserRole } from '@/types/dashboard';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
  navigationItems: NavigationItem[];
  userRole: UserRole;
  className?: string;
  isCollapsed: boolean;
  onToggleCollapse: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  isOpen,
  onClose,
  navigationItems,
  userRole,
  className = '',
  isCollapsed,
  onToggleCollapse
}) => {
  const [expandedGroups, setExpandedGroups] = useState<Set<string>>(new Set());
  const toggleGroup = (groupId: string) => {
    setExpandedGroups(prev => {
      const newSet = new Set(prev);
      if (newSet.has(groupId)) {
        newSet.delete(groupId);
      } else {
        newSet.add(groupId);
      }
      return newSet;
    });
  };

  const getItemIcon = (item: NavigationItem) => {
    // Si l'item a déjà une icône, on l'utilise
    if (item.icon) return item.icon;
    
    // Sinon, on assigne une icône par défaut selon le type d'item
    if (item.children && item.children.length > 0) {
      return 'fas fa-folder'; // Icône de dossier pour les groupes
    }
    return 'fas fa-circle'; // Icône par défaut pour les éléments simples
  };

  const renderNavigationItem = (item: NavigationItem, depth = 0) => {
    const hasUnreadNotifications = item.badge && item.badge > 0;
    const hasChildren = item.children && item.children.length > 0;
    const isExpanded = expandedGroups.has(item.id);
    const paddingLeft = depth === 0 ? 'pl-4' : `pl-${4 + depth * 4}`;
    const itemIcon = getItemIcon(item);

    return (
      <div key={item.id} className="mb-1">
        <div
          className={`
            sidebar-item relative
            ${paddingLeft} ${isCollapsed ? 'px-3' : 'pr-4'} py-3 flex items-center justify-between
            text-gray-300 hover:text-white hover:bg-gray-700
            transition-all duration-200 group cursor-pointer rounded-lg mx-2
            ${item.isActive ? 'nav-item-active' : ''}
            ${hasChildren ? 'group-item' : ''}
          `}
          onClick={() => {
            if (hasChildren) {
              if (!isCollapsed) {
                toggleGroup(item.id);
              }
            } else if (item.path) {
              window.location.href = item.path;
            }
          }}
        >
          <div className="flex items-center min-w-0 flex-1">
            <div className="flex items-center">
              <i className={`${itemIcon} text-lg ${isCollapsed ? '' : 'mr-3'} group-hover:text-green-400 flex-shrink-0`}></i>
              {hasChildren && !isCollapsed && (
                <i className={`fas fa-angle-right text-xs ml-1 mr-2 group-hover:text-green-400 transition-transform duration-200 ${isExpanded ? 'rotate-90' : ''}`}></i>
              )}
            </div>
            {!isCollapsed && (
              <span className="font-medium truncate">{item.label}</span>
            )}
          </div>
          
          {!isCollapsed && (
            <div className="flex items-center space-x-2">
              {hasUnreadNotifications && (
                <span className="notification-badge text-white text-xs font-bold px-2 py-1 rounded-full min-w-[20px] h-5 flex items-center justify-center">
                  {(item.badge ?? 0) > 99 ? '99+' : item.badge}
                </span>
              )}
            </div>
          )}
          
          {/* Tooltip pour sidebar collapsée */}
          {isCollapsed && (
            <div className="sidebar-tooltip">
              {item.label}
              {hasUnreadNotifications && ` (${item.badge})`}
              {hasChildren && ' (Groupe)'}
            </div>
          )}
        </div>
        
        {hasChildren && isExpanded && !isCollapsed && (
          <div className="bg-gray-800 border-l-2 border-green-500 ml-6 mt-1 rounded-r-lg">
            {item.children!.map(child => renderNavigationItem(child, depth + 1))}
          </div>
        )}
      </div>
    );
  };

  return (
    <>
      {/* Overlay mobile */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}
      
      {/* Sidebar */}
      <div className={`
        fixed left-0 top-0 h-screen bg-gray-800 z-50 transform transition-all duration-300 ease-in-out flex flex-col
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:translate-x-0 lg:relative lg:z-auto
        ${isCollapsed ? 'w-16' : 'w-64'}
        ${className}
      `}>
        {/* Header */}
        <div className={`flex items-center justify-between ${isCollapsed ? 'px-3' : 'px-6'} py-4 bg-gray-900 border-b border-gray-700 flex-shrink-0`}>
          <div className="flex items-center min-w-0">
            <div className={`${isCollapsed ? 'w-8 h-8' : 'w-8 h-8'} bg-green-600 rounded-lg flex items-center justify-center ${isCollapsed ? '' : 'mr-3'} flex-shrink-0`}>
              <i className="fas fa-shield-alt text-white text-sm"></i>
            </div>
            {!isCollapsed && (
              <div className="min-w-0">
                <h2 className="text-white font-bold text-lg truncate">Msaada</h2>
                <p className="text-gray-400 text-xs truncate">Assistance VBG</p>
              </div>
            )}
          </div>
          
          <div className="flex items-center space-x-2">
            {/* Bouton toggle collapse */}
            <button
              onClick={onToggleCollapse}
              className="flex text-gray-400 hover:text-white hover:bg-gray-700 p-2 rounded-md transition-all duration-200 toggle-button"
              title={isCollapsed ? 'Étendre la sidebar' : 'Réduire la sidebar'}
            >
              <i className={`fas fa-angle-${isCollapsed ? 'right' : 'left'} text-sm`}></i>
            </button>
            
            {/* Bouton fermer mobile */}
            <button
              onClick={onClose}
              className="lg:hidden text-gray-400 hover:text-white p-1"
            >
              <i className="fas fa-times"></i>
            </button>
          </div>
        </div>

        {/* Profil utilisateur */}
        <div className={`${isCollapsed ? 'px-3' : 'px-6'} py-4 bg-gray-750 border-b border-gray-700 flex-shrink-0`}>
          <div className="flex items-center">
            <div className={`${isCollapsed ? 'w-8 h-8' : 'w-10 h-10'} bg-green-600 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0`}>
              <i className="fas fa-user"></i>
            </div>
            {!isCollapsed && (
              <div className="ml-3 min-w-0">
                <p className="text-white text-sm font-medium truncate">Agent connecté</p>
                <p className="text-gray-400 text-xs capitalize truncate">{userRole.replace('_', ' ')}</p>
              </div>
            )}
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 py-4 overflow-y-auto sidebar-nav">
          <div className="space-y-1">
            {navigationItems.map(item => renderNavigationItem(item))}
          </div>
        </nav>

        {/* Footer */}
        <div className={`${isCollapsed ? 'px-3' : 'px-6'} py-4 bg-gray-900 border-t border-gray-700 flex-shrink-0`}>
          {!isCollapsed ? (
            <div className="flex items-center justify-between text-gray-400 text-xs">
              <span>v2.0.0</span>
              <div className="flex items-center">
                <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
                <span>En ligne</span>
              </div>
            </div>
          ) : (
            <div className="flex flex-col items-center space-y-2">
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
              <span className="text-gray-400 text-xs transform rotate-90 whitespace-nowrap origin-center">v2.0</span>
            </div>
          )}
        </div>
      </div>
    </>
  );
};