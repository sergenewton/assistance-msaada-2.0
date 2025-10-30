import React, { ReactNode } from 'react';

interface ResponsiveCardProps {
  title: string;
  description?: string;
  icon?: React.ComponentType<{ className?: string }>;
  value?: string | number;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  action?: {
    label: string;
    onClick: () => void;
  };
  children?: ReactNode;
  className?: string;
  variant?: 'default' | 'stats' | 'action';
  size?: 'sm' | 'md' | 'lg';
}

export const ResponsiveCard: React.FC<ResponsiveCardProps> = ({
  title,
  description,
  icon: Icon,
  value,
  trend,
  action,
  children,
  className = '',
  variant = 'default',
  size = 'md'
}) => {
  const sizeClasses = {
    sm: 'p-4',
    md: 'p-6',
    lg: 'p-8'
  };

  const cardClasses = `
    bg-white dark:bg-gray-800 
    rounded-xl 
    shadow-sm hover:shadow-lg 
    border border-gray-100 dark:border-gray-700
    ${sizeClasses[size]}
    transition-all duration-300 ease-in-out
    hover:-translate-y-1 hover:ring-2 hover:ring-blue-500 hover:ring-opacity-20
    cursor-pointer
    focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50
    animate-fade-in-up
    ${className}
  `;

  return (
    <div className={cardClasses} tabIndex={0}>
      {/* Header avec icône */}
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-3">
          {Icon && (
            <div className="
              w-10 h-10 sm:w-12 sm:h-12
              p-2 sm:p-3
              bg-gray-50 dark:bg-gray-700 
              rounded-lg 
              flex items-center justify-center
              transition-all duration-200
              group-hover:bg-blue-50 group-hover:dark:bg-blue-900/20
              group-hover:text-blue-600 group-hover:dark:text-blue-400
              group-hover:scale-110
            ">
              <Icon className="w-5 h-5 sm:w-6 sm:h-6 stroke-1.5" />
            </div>
          )}
          <div className="min-w-0 flex-1">
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 dark:text-white truncate">
              {title}
            </h3>
            {description && (
              <p className="text-sm sm:text-base text-gray-600 dark:text-gray-400 mt-1 line-clamp-2">
                {description}
              </p>
            )}
          </div>
        </div>
        
        {trend && (
          <div className={`flex items-center text-xs sm:text-sm font-medium ${
            trend.isPositive ? 'text-emerald-600' : 'text-red-600'
          }`}>
            <span className={`mr-1 ${
              trend.isPositive ? '↗' : '↘'
            }`}></span>
            {Math.abs(trend.value)}%
          </div>
        )}
      </div>

      {/* Valeur pour les cartes stats */}
      {variant === 'stats' && value && (
        <div className="mb-4">
          <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">
            {value}
          </div>
        </div>
      )}

      {/* Contenu personnalisé */}
      {children && (
        <div className="mb-4">
          {children}
        </div>
      )}

      {/* Action */}
      {action && (
        <div className="pt-4 border-t border-gray-100 dark:border-gray-700">
          <button
            onClick={action.onClick}
            className="
              w-full flex items-center justify-center 
              px-4 py-2 
              text-sm sm:text-base font-medium
              text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300
              hover:bg-blue-50 dark:hover:bg-blue-900/20
              rounded-lg 
              transition-colors duration-200
              focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50
            "
          >
            {action.label}
            <svg className="ml-2 h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      )}
    </div>
  );
};