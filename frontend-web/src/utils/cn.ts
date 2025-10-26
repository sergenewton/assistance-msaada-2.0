import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Utilitaire pour combiner les classes CSS avec Tailwind
 * Combine clsx et tailwind-merge pour une gestion optimale des classes
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}