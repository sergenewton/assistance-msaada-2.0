import React from 'react';

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
              <i className={`fas ${trend.isPositive ? 'fa-arrow-up text-green-500' : 'fa-arrow-down text-red-500'} text-sm mr-1`}></i>
              <span className={`text-sm font-medium ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
                {Math.abs(trend.value)}%
              </span>
              <span className="text-sm text-gray-500 ml-1">vs mois dernier</span>
            </div>
          )}
        </div>
        
        <div className={`w-10 h-10 sm:w-12 sm:h-12 ${colors.bgLight} rounded-lg flex items-center justify-center transition-all duration-200 group-hover:scale-110`}>
          <i className={`${icon} text-lg sm:text-xl ${colors.text} transition-colors duration-200`} style={{strokeWidth: '1.5px'}}></i>
        </div>
      </div>
    </div>
  );
};