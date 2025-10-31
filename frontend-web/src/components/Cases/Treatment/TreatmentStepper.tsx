import React from 'react';
import { clsx } from 'clsx';

interface TreatmentStepperProps {
  step: 1 | 2 | 3 | 4;
}

const steps = [
  { id: 1, label: 'Analyse du signalement' },
  { id: 2, label: 'Assigner un APS' },
  { id: 3, label: 'Référencements' },
  { id: 4, label: 'Validation & Finalisation' },
] as const;

export const TreatmentStepper: React.FC<TreatmentStepperProps> = ({ step }) => {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4 mb-4">
      <div className="flex items-center justify-between">
        {steps.map((s, idx) => {
          const isActive = s.id === step;
          const isDone = s.id < step;
          return (
            <div key={s.id} className="flex-1 flex items-center">
              <div
                className={clsx(
                  'flex items-center gap-2',
                  isActive && 'text-success-700',
                  isDone && 'text-success-600',
                  !isActive && !isDone && 'text-gray-500'
                )}
              >
                <span
                  className={clsx(
                    'inline-flex items-center justify-center w-8 h-8 rounded-full border text-sm font-semibold',
                    isActive && 'bg-success-100 border-success-300 text-success-700',
                    isDone && 'bg-success-600 border-success-600 text-white',
                    !isActive && !isDone && 'bg-gray-100 border-gray-300 text-gray-600'
                  )}
                >
                  {s.id}
                </span>
                <span className="text-sm font-medium">{s.label}</span>
              </div>
              {idx < steps.length - 1 && (
                <div className={clsx('flex-1 h-0.5 mx-2', isDone ? 'bg-success-400' : 'bg-gray-200')} />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default TreatmentStepper;
