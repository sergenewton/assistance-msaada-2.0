import React from 'react';

export interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  variant?: 'full' | 'icon' | 'text';
  className?: string;
}

/**
 * Composant Logo pour Assistance Msaada
 */
const Logo: React.FC<LogoProps> = ({
  size = 'md',
  variant = 'full',
  className = '',
}) => {
  const sizeClasses = {
    sm: 'h-8',
    md: 'h-12',
    lg: 'h-16',
    xl: 'h-24',
  };

  const textSizeClasses = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl',
    xl: 'text-4xl',
  };

  // Icône VBG avec symbole de protection
  const IconComponent = () => (
    <div className={`${sizeClasses[size]} flex items-center justify-center`}>
      <div className="relative">
        {/* Cercle de protection */}
        <svg
          className="w-full h-full"
          viewBox="0 0 64 64"
          fill="none"
        >
          {/* Bouclier principal */}
          <path
            d="M32 4L48 12V28C48 42 38 54 32 60C26 54 16 42 16 28V12L32 4Z"
            fill="#3B82F6"
            stroke="#1E40AF"
            strokeWidth="2"
          />
          
          {/* Cœur au centre */}
          <path
            d="M32 20C28 16 20 18 20 26C20 34 32 44 32 44S44 34 44 26C44 18 36 16 32 20Z"
            fill="#EF4444"
          />
          
          {/* Mains protectrices */}
          <path
            d="M22 30C20 28 18 30 18 32C18 34 20 36 22 34L26 32"
            fill="#FBBF24"
            opacity="0.8"
          />
          <path
            d="M42 30C44 28 46 30 46 32C46 34 44 36 42 34L38 32"
            fill="#FBBF24"
            opacity="0.8"
          />
        </svg>
      </div>
    </div>
  );

  // Texte du logo
  const TextComponent = () => (
    <div className={`font-bold ${textSizeClasses[size]} text-blue-600`}>
      <span className="text-blue-700">Assistance</span>{' '}
      <span className="text-red-500">Msaada</span>
    </div>
  );

  return (
    <div className={`inline-flex items-center gap-3 ${className}`}>
      {(variant === 'full' || variant === 'icon') && <IconComponent />}
      {(variant === 'full' || variant === 'text') && <TextComponent />}
    </div>
  );
};

export { Logo };