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
        bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 p-6
        hover:shadow-md transition-all duration-200 cursor-pointer
        ${!module.isActive ? 'opacity-50 cursor-not-allowed' : ''}
      `}
      onClick={() => module.isActive && onClick?.()}
      style={{ borderLeftColor: module.color, borderLeftWidth: '4px' }}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center">
          <div 
            className="w-12 h-12 rounded-lg flex items-center justify-center mr-4"
            style={{ backgroundColor: `${module.color}15` }}
          >
            <i className={`${module.icon} text-xl`} style={{ color: module.color }}></i>
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
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
      
      <p className="text-gray-600 dark:text-gray-400 text-sm">
        {module.description}
      </p>
    </div>
  );
};