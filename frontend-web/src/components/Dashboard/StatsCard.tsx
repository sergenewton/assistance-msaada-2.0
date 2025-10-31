import React from 'react';
import {
  type LucideIcon,
  ArrowUpRight,
  ArrowDownRight,
  Users as UsersIcon,
  User as UserIcon,
  Inbox,
  FolderOpen,
  Eye,
  Calendar,
  Activity,
  BarChart2,
  Folder,
  Circle,
  Clock,
  CheckCircle,
  AlertTriangle,
  Database,
  FileText,
  Building,
  Shield,
  GraduationCap,
  Share2,
  Upload,
  Headphones,
  Map,
  Star,
  ListChecks,
  Loader2,
} from 'lucide-react';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: string;
  color: 'blue' | 'green' | 'red' | 'yellow' | 'purple' | 'indigo';
  trend?: {
    value: number;
    isPositive: boolean;
  };
  onClick?: () => void;
}

const colorClasses = {
  blue: {
    bg: 'bg-blue-500',
    bgLight: 'bg-blue-50',
    text: 'text-blue-600',
    border: 'border-blue-200'
  },
  green: {
    bg: 'bg-green-500',
    bgLight: 'bg-green-50',
    text: 'text-green-600',
    border: 'border-green-200'
  },
  red: {
    bg: 'bg-red-500',
    bgLight: 'bg-red-50',
    text: 'text-red-600',
    border: 'border-red-200'
  },
  yellow: {
    bg: 'bg-yellow-500',
    bgLight: 'bg-yellow-50',
    text: 'text-yellow-600',
    border: 'border-yellow-200'
  },
  purple: {
    bg: 'bg-purple-500',
    bgLight: 'bg-purple-50',
    text: 'text-purple-600',
    border: 'border-purple-200'
  },
  indigo: {
    bg: 'bg-indigo-500',
    bgLight: 'bg-indigo-50',
    text: 'text-indigo-600',
    border: 'border-indigo-200'
  }
};

export const StatsCard: React.FC<StatsCardProps> = ({
  title,
  value,
  icon,
  color,
  trend,
  onClick
}) => {
  const colors = colorClasses[color];
  const iconMap: Record<string, LucideIcon> = {
    'fas fa-users': UsersIcon,
    'fas fa-user': UserIcon,
    'fas fa-inbox': Inbox,
    'fas fa-folder-open': FolderOpen,
    'fas fa-eye': Eye,
    'fas fa-calendar': Calendar,
    'fas fa-activity': Activity,
    'fas fa-chart-line': BarChart2,
    'fas fa-folder': Folder,
    'fas fa-circle': Circle,
    'fas fa-clock': Clock,
    'fas fa-check-circle': CheckCircle,
    'fas fa-exclamation-triangle': AlertTriangle,
    'fas fa-database': Database,
    'fas fa-file-alt': FileText,
    'fas fa-building': Building,
    'fas fa-shield-alt': Shield,
    'fas fa-graduation-cap': GraduationCap,
    'fas fa-share-alt': Share2,
    'fas fa-upload': Upload,
    'fas fa-headset': Headphones,
    'fas fa-map': Map,
    'fas fa-star': Star,
    'fas fa-tasks': ListChecks,
    'fas fa-spinner': Loader2,
  };
  const ResolvedIcon: LucideIcon = iconMap[icon] || Circle;
  
  return (
    <div 
      className={`
        group
        bg-white dark:bg-gray-800 rounded-xl shadow-sm border ${colors.border} 
        p-4 sm:p-6
        transition-all duration-300 ease-in-out
        hover:shadow-lg hover:-translate-y-1 hover:ring-2 hover:ring-blue-500 hover:ring-opacity-20
        focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50
        ${onClick ? 'cursor-pointer' : ''}
      `}
      onClick={onClick}
      tabIndex={onClick ? 0 : undefined}
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs sm:text-sm font-medium text-gray-600 dark:text-gray-400 mb-1 truncate">
            {title}
          </p>
          <p className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">
            {value}
          </p>
          {trend && (
            <div className="flex items-center mt-2">
              {trend.isPositive ? (
                <ArrowUpRight className="w-4 h-4 text-green-500 mr-1" />
              ) : (
                <ArrowDownRight className="w-4 h-4 text-red-500 mr-1" />
              )}
              <span className={`text-sm font-medium ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
                {Math.abs(trend.value)}%
              </span>
              <span className="text-sm text-gray-500 ml-1">vs mois dernier</span>
            </div>
          )}
        </div>
        
        <div className={`w-10 h-10 sm:w-12 sm:h-12 ${colors.bgLight} rounded-lg flex items-center justify-center transition-all duration-200 group-hover:scale-110`}>
          <ResolvedIcon className={`w-5 h-5 sm:w-6 sm:h-6 ${colors.text}`} />
        </div>
      </div>
    </div>
  );
};