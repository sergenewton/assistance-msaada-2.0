import React, { ReactNode } from 'react';

interface ResponsiveGridProps {
  children: ReactNode;
  className?: string;
  variant?: 'stats' | 'cards' | 'modules' | 'custom';
  gap?: 'small' | 'medium' | 'large';
}

export const ResponsiveGrid: React.FC<ResponsiveGridProps> = ({
  children,
  className = '',
  variant = 'cards',
  gap = 'medium'
}) => {
  const gapClasses = {
    small: 'gap-3',
    medium: 'gap-4 sm:gap-6',
    large: 'gap-6 sm:gap-8'
  };

  const variantClasses = {
    stats: `
      grid ${gapClasses[gap]}
      grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6
      transition-all duration-300 ease-in-out
    `,
    cards: `
      grid ${gapClasses[gap]}
      grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5
      transition-all duration-300 ease-in-out
    `,
    modules: `
      grid ${gapClasses[gap]}
      grid-cols-1 sm:grid-cols-2 md:grid-cols-4 xl:grid-cols-6
      transition-all duration-300 ease-in-out
    `,
    custom: `
      grid ${gapClasses[gap]}
      transition-all duration-300 ease-in-out
    `
  };

  const gridClass = `
    ${variantClasses[variant]}
    ${className}
  `.trim();

  return (
    <div className={gridClass}>
      {children}
    </div>
  );
};