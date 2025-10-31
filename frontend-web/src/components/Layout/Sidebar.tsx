import React, { useEffect, useMemo, useState } from 'react';
import { NavigationItem, UserRole } from '@/types/dashboard';
import { useLocation, useNavigate } from 'react-router-dom';
// Import Lucide React icons and types
import {
  type LucideIcon,
  LayoutDashboard,
  Inbox,
  FolderOpen,
  Folder,
  Circle,
  Eye,
  MessageSquare,
  Calendar,
  Activity,
  BarChart2,
  Shield,
  ChevronLeft,
  ChevronRight,
  X as XIcon,
  User as UserIcon,
  Sun as SunIcon,
  Moon as MoonIcon,
  Cog as CogIcon,
  AlertTriangle,
  Loader2,
  UserCheck,
  UserPlus,
  ClipboardCheck,
  Building,
  Share2,
  Bell,
  Clock,
  CheckCircle,
  Users,
  ListChecks,
  Lock,
} from 'lucide-react';

// Map common Font Awesome class strings -> Lucide icons
const iconMap: Record<string, LucideIcon> = {
  // Dashboard & basics
  'fas fa-tachometer-alt': LayoutDashboard,
  'fas fa-inbox': Inbox,
  'fas fa-folder-open': FolderOpen,
  'fas fa-folder': Folder,
  'fas fa-circle': Circle,
  'fas fa-eye': Eye,
  'fas fa-messages': MessageSquare,
  'fas fa-message': MessageSquare,
  'fas fa-calendar': Calendar,
  'fas fa-activity': Activity,
  'fas fa-chart-line': BarChart2,
  'fas fa-chart-bar': BarChart2,
  
  // Status & alerts
  'fas fa-exclamation-triangle': AlertTriangle,
  'fas fa-bell': Bell,
  'fas fa-clock': Clock,
  'fas fa-check-circle': CheckCircle,
  'fas fa-spinner': Loader2,

  // Users & orgs
  'fas fa-user-check': UserCheck,
  'fas fa-user-plus': UserPlus,
  'fas fa-users': Users,
  'fas fa-building': Building,
  
  // Actions & tasks
  'fas fa-clipboard-check': ClipboardCheck,
  'fas fa-tasks': ListChecks,
  'fas fa-share-alt': Share2,
  
  // Security
  'fas fa-shield-alt': Shield,
  'fas fa-lock': Lock,
};

// Helper to resolve a NavigationItem icon into a Lucide component
const resolveIcon = (icon?: string, hasChildren?: boolean): LucideIcon => {
  if (icon && iconMap[icon]) return iconMap[icon];
  if (hasChildren) return Folder;
  return Circle;
};

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
  const location = useLocation();
  const navigate = useNavigate();
  const currentPath = location.pathname;

  // Determine if a nav item (or its children) matches the current path
  const doesItemMatchPath = (item: NavigationItem, path: string): boolean => {
    if (item.path && (path === item.path || path.startsWith(item.path + '/'))) return true;
    if (item.children && item.children.length > 0) {
      return item.children.some(child => doesItemMatchPath(child, path));
    }
    return false;
  };

  const groupsToExpand = useMemo(() => {
    const set = new Set<string>();
    const walk = (items: NavigationItem[]) => {
      items.forEach(it => {
        if (it.children && it.children.length > 0) {
          // If any child matches, expand this group
          if (doesItemMatchPath(it, currentPath)) {
            set.add(it.id);
          }
          walk(it.children);
        }
      });
    };
    walk(navigationItems);
    return set;
  }, [navigationItems, currentPath]);

  // Keep the matching group(s) expanded when route changes
  useEffect(() => {
    setExpandedGroups(prev => {
      const merged = new Set(prev);
      groupsToExpand.forEach(g => merged.add(g));
      return merged;
    });
  }, [groupsToExpand]);
  
  // Split items into logical sections instead of slicing by percentage
  const overviewItems = navigationItems.filter(item => !item.id.startsWith('account-'));
  const accountItems = navigationItems.filter(item => item.id.startsWith('account-'));
  
  const toggleGroup = (groupId: string) => {
    if (isCollapsed) return; // Pas d'expansion en mode collapsed
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
    const itemIcon = getItemIcon(item);
    const LucideIconComponent = resolveIcon(itemIcon, hasChildren);
    const isActive = doesItemMatchPath(item, currentPath);

    return (
      <div key={item.id} className={`${depth === 0 ? 'mb-1' : 'mb-0.5'}`}>
        <div
          className={`
            relative group cursor-pointer
            ${isCollapsed ? 'mx-2 px-3' : 'mx-3 px-4'} py-3 
            flex items-center justify-between
            text-gray-300 hover:text-white hover:bg-gray-800
            transition-all duration-200 rounded-xl
            ${isActive ? 'bg-emerald-600/20 text-emerald-300 border-l-4 border-emerald-400' : ''}
            ${depth > 0 ? 'ml-6 py-2' : ''}
          `}
          onClick={() => {
            if (hasChildren) {
              if (!isCollapsed) {
                toggleGroup(item.id);
              }
            } else if (item.path) {
              navigate(item.path);
            }
          }}
        >
          <div className="flex items-center min-w-0 flex-1">
            <div className="flex items-center">
              <LucideIconComponent
                className={`${isCollapsed ? '' : 'mr-4'} w-5 h-5 ${isActive ? 'text-emerald-300' : 'text-gray-300 group-hover:text-white'} transition-colors duration-200`}
              />

              {hasChildren && !isCollapsed && (
                <ChevronRight
                  className={`w-4 h-4 mr-2 transition-all duration-200 ${isExpanded ? 'rotate-90' : ''} ${isActive ? 'text-emerald-300' : 'text-gray-300 group-hover:text-white'}`}
                />
              )}
            </div>
            {!isCollapsed && (
              <span className={`
                font-medium truncate text-sm
                ${isActive ? 'text-emerald-200' : 'text-gray-200 group-hover:text-white'}
                transition-colors duration-200
              `}>
                {item.label}
              </span>
            )}
          </div>
          
          {!isCollapsed && hasUnreadNotifications && (
            <div className="flex items-center">
              <span className="bg-emerald-500 text-white text-xs font-bold px-2 py-1 rounded-full min-w-[20px] h-5 flex items-center justify-center">
                {(item.badge ?? 0) > 99 ? '99+' : item.badge}
              </span>
            </div>
          )}

          {isCollapsed && hasUnreadNotifications && (
            <div className="absolute -top-1 -right-1 w-3 h-3 bg-emerald-500 rounded-full border-2 border-gray-800"></div>
          )}
          
          {/* Tooltip pour sidebar collapsée */}
          {isCollapsed && (
            <div className="absolute left-full ml-2 px-3 py-2 bg-gray-800 text-gray-100 text-sm rounded-lg shadow-xl border border-gray-600 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 whitespace-nowrap z-50">
              {item.label}
              {hasUnreadNotifications && (
                <span className="ml-2 bg-emerald-500 text-white text-xs px-1.5 py-0.5 rounded-full">
                  {item.badge}
                </span>
              )}
            </div>
          )}
        </div>
        
        {hasChildren && isExpanded && !isCollapsed && (
          <div className="ml-3 mt-1">
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
        fixed left-0 top-0 h-full z-50 transform flex flex-col
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:translate-x-0 lg:relative lg:z-auto lg:h-full
        ${isCollapsed ? 'w-20' : 'w-72'}
        bg-gray-900 border-r border-gray-700
        transition-all duration-300 ease-in-out
        ${className}
      `}>
        {/* Header */}
        <div className={`flex items-center justify-between ${isCollapsed ? 'px-4' : 'px-6'} py-6 flex-shrink-0`}>
          <div className="flex items-center min-w-0">
            <div className={`
              ${isCollapsed ? 'w-10 h-10' : 'w-12 h-12'} 
              bg-gradient-to-br from-emerald-500 to-emerald-600 
              rounded-xl flex items-center justify-center 
              ${isCollapsed ? '' : 'mr-4'} 
              flex-shrink-0 shadow-lg
            `}>
              <Shield className="w-5 h-5 text-white" />
            </div>
            {!isCollapsed && (
              <div className="min-w-0">
                <h2 className="text-white font-bold text-xl truncate">Msaada</h2>
                <p className="text-emerald-400 text-sm truncate">Technology</p>
              </div>
            )}
          </div>
          
          <div className="flex items-center space-x-2">
            {/* Bouton toggle collapse */}
            <button
              onClick={onToggleCollapse}
              className="flex text-gray-400 hover:text-white hover:bg-gray-800 p-2 rounded-lg transition-all duration-200"
              title={isCollapsed ? 'Étendre la sidebar' : 'Réduire la sidebar'}
            >
              {isCollapsed ? (
                <ChevronRight className="w-4 h-4" />
              ) : (
                <ChevronLeft className="w-4 h-4" />
              )}
            </button>
            
            {/* Bouton fermer mobile */}
            <button
              onClick={onClose}
              className="lg:hidden text-gray-400 hover:text-white hover:bg-gray-800 p-2 rounded-lg transition-all duration-200"
            >
              <XIcon className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto sidebar-nav py-4">
          {/* Section Overview */}
          {!isCollapsed && (
            <div className="px-6 py-2 mb-4">
              <h3 className="text-gray-400 text-xs font-semibold uppercase tracking-wider">
                Overview
              </h3>
            </div>
          )}
          
          <div className="space-y-1">
            {overviewItems.map(item => renderNavigationItem(item))}
          </div>

          {/* Section Account */}
          {accountItems.length > 0 && (
            <>
              {!isCollapsed && (
                <div className="px-6 py-2 mt-8 mb-4">
                  <h3 className="text-gray-400 text-xs font-semibold uppercase tracking-wider">
                    Account
                  </h3>
                </div>
              )}
              <div className="space-y-1">
                {accountItems.map(item => renderNavigationItem(item))}
              </div>
            </>
          )}
        </nav>

        {/* Footer avec profil utilisateur et mode sombre */}
        <div className={`${isCollapsed ? 'px-4' : 'px-6'} py-4 border-t border-gray-800 flex-shrink-0`}>
          {!isCollapsed ? (
            <div className="space-y-4">
              {/* Profil utilisateur */}
              <div className="flex items-center p-3 bg-gray-800 rounded-xl hover:bg-gray-700 transition-colors duration-200 cursor-pointer border border-gray-700">
                <div className="w-10 h-10 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-xl flex items-center justify-center text-white font-bold flex-shrink-0">
                  <UserIcon className="w-4 h-4" />
                </div>
                <div className="ml-3 min-w-0 flex-1">
                  <p className="text-gray-100 text-sm font-medium truncate">Agent connecté</p>
                  <p className="text-emerald-300 text-xs capitalize truncate">{userRole.replace('_', ' ')}</p>
                </div>
                <CogIcon className="w-4 h-4 text-gray-300 hover:text-white transition-colors duration-200" />
              </div>

              {/* Contrôles du mode et version */}
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <button className="p-2 hover:bg-gray-700 rounded-lg transition-colors duration-200 text-gray-300 hover:text-white">
                    <SunIcon className="w-4 h-4" />
                  </button>
                  <div className="w-8 h-4 bg-gray-600 rounded-full relative border border-gray-500">
                    <div className="w-3 h-3 bg-gray-300 rounded-full absolute top-0.5 left-0.5 transition-transform duration-200"></div>
                  </div>
                  <button className="p-2 hover:bg-gray-700 rounded-lg transition-colors duration-200 text-gray-300 hover:text-white">
                    <MoonIcon className="w-4 h-4" />
                  </button>
                </div>
                
                <div className="flex items-center text-gray-300 text-xs">
                  <div className="w-2 h-2 bg-emerald-400 rounded-full mr-2"></div>
                  <span>v2.0</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="flex flex-col items-center space-y-3">
              <div className="w-10 h-10 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-xl flex items-center justify-center text-white border border-gray-700">
                <UserIcon className="w-4 h-4" />
              </div>
              <div className="w-8 h-4 bg-gray-600 rounded-full relative border border-gray-500">
                <div className="w-3 h-3 bg-gray-300 rounded-full absolute top-0.5 left-0.5"></div>
              </div>
              <div className="w-2 h-2 bg-emerald-400 rounded-full"></div>
            </div>
          )}
        </div>
      </div>
    </>
  );
};