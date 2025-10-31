import React from 'react';
import { Module } from '@/types/dashboard';
import {
  type LucideIcon,
  Lock,
  FolderOpen,
  Shield,
  GraduationCap,
  Eye,
  Inbox,
  Hourglass,
  List,
  User as UserIcon,
  Users as UsersIcon,
  Bell,
  Settings,
  Database,
  BarChart2,
  FileText,
  Calendar,
  ClipboardCheck,
  AlertTriangle,
  CheckCircle,
  Upload,
  Pencil as EditIcon,
  Share2,
  Map,
  Headphones,
  Building,
  UserCheck,
  RadioTower,
  Circle,
  ArrowRight,
  History,
  CloudUpload,
  Download,
  Globe,
  SlidersHorizontal,
  Wrench,
  Clock,
  Gauge,
  Newspaper,
  Star,
} from 'lucide-react';

const moduleIconMap: Record<string, LucideIcon> = {
  'fas fa-lock': Lock,
  'fas fa-folder-open': FolderOpen,
  'fas fa-shield-alt': Shield,
  'fas fa-shield': Shield,
  'fas fa-graduation-cap': GraduationCap,
  'fas fa-eye': Eye,
  'fas fa-inbox': Inbox,
  'fas fa-hourglass-half': Hourglass,
  'fas fa-list': List,
  'fas fa-user': UserIcon,
  'fas fa-users': UsersIcon,
  'fas fa-bell': Bell,
  'fas fa-cog': Settings,
  'fas fa-database': Database,
  'fas fa-chart-line': BarChart2,
  'fas fa-file-alt': FileText,
  'fas fa-calendar': Calendar,
  'fas fa-calendar-alt': Calendar,
  'fas fa-clipboard-check': ClipboardCheck,
  'fas fa-exclamation-triangle': AlertTriangle,
  'fas fa-check-circle': CheckCircle,
  'fas fa-upload': Upload,
  'fas fa-file-upload': Upload,
  'fas fa-cloud-upload-alt': CloudUpload,
  'fas fa-edit': EditIcon,
  'fas fa-share-alt': Share2,
  'fas fa-map': Map,
  'fas fa-headset': Headphones,
  'fas fa-building': Building,
  'fas fa-user-check': UserCheck,
  'fas fa-broadcast-tower': RadioTower,
  'fas fa-history': History,
  'fas fa-download': Download,
  'fas fa-globe': Globe,
  'fas fa-sliders-h': SlidersHorizontal,
  'fas fa-tools': Wrench,
  'fas fa-newspaper': Newspaper,
  'fas fa-clock': Clock,
  'fas fa-tachometer-alt': Gauge,
  'fas fa-star': Star,
};

const resolveModuleIcon = (icon?: string): LucideIcon => {
  if (icon && moduleIconMap[icon]) return moduleIconMap[icon];
  return Circle;
};

interface ModuleCardProps {
  module: Module;
  onClick?: () => void;
}

export const ModuleCard: React.FC<ModuleCardProps> = ({ module, onClick }) => {
  return (
    <div
      className={`
        group
        bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 
        p-4 sm:p-6
        min-h-[140px] sm:min-h-[160px]
        flex flex-col
        transition-all duration-300 ease-in-out
        hover:shadow-lg hover:-translate-y-1 hover:ring-2 hover:ring-blue-500 hover:ring-opacity-20
        focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50
        ${module.isActive ? 'cursor-pointer' : 'opacity-50 cursor-not-allowed'}
      `}
      onClick={() => module.isActive && onClick?.()}
      style={{ borderLeftColor: module.color, borderLeftWidth: '4px' }}
      tabIndex={module.isActive ? 0 : undefined}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center min-w-0 flex-1">
          <div 
            className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg flex items-center justify-center mr-3 sm:mr-4 transition-all duration-200 group-hover:scale-110 flex-shrink-0"
            style={{ backgroundColor: `${module.color}15` }}
          >
            {(() => {
              const Icon = resolveModuleIcon(module.icon);
              return <Icon className="w-5 h-5 sm:w-6 sm:h-6" style={{ color: module.color }} />;
            })()}
          </div>
          <div className="min-w-0 flex-1">
            <h3 className="text-base sm:text-lg font-semibold text-gray-900 dark:text-white line-clamp-2 leading-tight">
              {module.name}
            </h3>
            {!module.isActive && (
              <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800 mt-1">
                Bientôt disponible
              </span>
            )}
          </div>
        </div>
        
        {module.isActive && (
          <ArrowRight className="w-4 h-4 text-gray-400 hover:text-gray-600 flex-shrink-0 ml-2" />
        )}
      </div>
      
      <p className="text-gray-600 dark:text-gray-400 text-xs sm:text-sm line-clamp-3 leading-relaxed break-words flex-1">
        {module.description}
      </p>
    </div>
  );
};