import React from 'react';
import { Module } from '@/types/dashboard';

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
        transition-all duration-300 ease-in-out
        hover:shadow-lg hover:-translate-y-1 hover:ring-2 hover:ring-blue-500 hover:ring-opacity-20
        focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50
        ${module.isActive ? 'cursor-pointer' : 'opacity-50 cursor-not-allowed'}
      `}
      onClick={() => module.isActive && onClick?.()}
      style={{ borderLeftColor: module.color, borderLeftWidth: '4px' }}
      tabIndex={module.isActive ? 0 : undefined}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center">
          <div 
            className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg flex items-center justify-center mr-3 sm:mr-4 transition-all duration-200 group-hover:scale-110"
            style={{ backgroundColor: `${module.color}15` }}
          >
            <i className={`${module.icon} text-lg sm:text-xl transition-all duration-200`} style={{ color: module.color, strokeWidth: '1.5px' }}></i>
          </div>
          <div className="min-w-0 flex-1">
            <h3 className="text-base sm:text-lg font-semibold text-gray-900 dark:text-white truncate">
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
          <i className="fas fa-arrow-right text-gray-400 hover:text-gray-600"></i>
        )}
      </div>
      
      <p className="text-gray-600 dark:text-gray-400 text-xs sm:text-sm line-clamp-3">
        {module.description}
      </p>
    </div>
  );
};