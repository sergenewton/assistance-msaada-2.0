import React from 'react';
import { cn } from '../../utils/cn';

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  variant?: 'default' | 'filled';
  inputSize?: 'sm' | 'md' | 'lg';
}

/**
 * Composant Input avec label, erreurs et icônes
 */
const Input = React.forwardRef<HTMLInputElement, InputProps>(
  (
    {
      className,
      type,
      label,
      error,
      helperText,
      leftIcon,
      rightIcon,
      variant = 'default',
      inputSize = 'md',
      id,
      disabled,
      ...props
    },
    ref
  ) => {
    // Génération automatique d'un ID si non fourni
    const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`;

    const sizeClasses = {
      sm: 'h-8 px-3 text-sm',
      md: 'h-10 px-4 text-sm',
      lg: 'h-12 px-4 text-base',
    };

    const variantClasses = {
      default: 'border border-gray-300 bg-white',
      filled: 'border-0 bg-gray-100',
    };

    return (
      <div className="w-full">
        {/* Label */}
        {label && (
          <label
            htmlFor={inputId}
            className={cn(
              'block text-sm font-medium mb-2',
              error ? 'text-red-700' : 'text-gray-700',
              disabled && 'opacity-50'
            )}
          >
            {label}
          </label>
        )}

        {/* Container avec icônes */}
        <div className="relative">
          {/* Icône gauche */}
          {leftIcon && (
            <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none">
              {leftIcon}
            </div>
          )}

          {/* Input field */}
          <input
            type={type}
            id={inputId}
            className={cn(
              // Base styles
              'w-full rounded-md transition-all duration-200',
              'focus:outline-none focus:ring-2 focus:ring-blue-500',
              'placeholder:text-gray-400',
              'disabled:opacity-50 disabled:cursor-not-allowed disabled:bg-gray-50',

              // Variant styles
              variantClasses[variant],

              // Size styles
              sizeClasses[inputSize],

              // Icon padding adjustments
              leftIcon && 'pl-10',
              rightIcon && 'pr-10',

              // Error state
              error && [
                'border-red-300 focus:border-red-500 focus:ring-red-500',
                variant === 'filled' && 'bg-red-50',
              ],

              className
            )}
            ref={ref}
            disabled={disabled}
            aria-invalid={error ? 'true' : 'false'}
            aria-describedby={
              error
                ? `${inputId}-error`
                : helperText
                ? `${inputId}-helper`
                : undefined
            }
            {...props}
          />

          {/* Icône droite */}
          {rightIcon && (
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400">
              {rightIcon}
            </div>
          )}
        </div>

        {/* Message d'erreur */}
        {error && (
          <p
            id={`${inputId}-error`}
            className="mt-2 text-sm text-red-600"
            role="alert"
          >
            {error}
          </p>
        )}

        {/* Texte d'aide */}
        {helperText && !error && (
          <p
            id={`${inputId}-helper`}
            className="mt-2 text-sm text-gray-500"
          >
            {helperText}
          </p>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';

export { Input };