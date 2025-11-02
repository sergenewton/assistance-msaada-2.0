import React, { useState, useRef, useEffect } from 'react';
import { MoreVertical, Edit2, Trash2, Power, PowerOff } from 'lucide-react';

interface UserActionsMenuProps {
  userId: string;
  userEmail: string;
  isActive: boolean;
  onEdit: () => void;
  onDelete: () => void;
  onToggleActive: () => void;
}

export const UserActionsMenu: React.FC<UserActionsMenuProps> = ({
  userId,
  userEmail,
  isActive,
  onEdit,
  onDelete,
  onToggleActive,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
      >
        <MoreVertical className="w-4 h-4" />
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-10">
          <button
            onClick={() => {
              onEdit();
              setIsOpen(false);
            }}
            className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center"
          >
            <Edit2 className="w-4 h-4 mr-2 text-gray-500" />
            Modifier
          </button>

          <button
            onClick={() => {
              onToggleActive();
              setIsOpen(false);
            }}
            className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center"
          >
            {isActive ? (
              <>
                <PowerOff className="w-4 h-4 mr-2 text-orange-500" />
                Désactiver
              </>
            ) : (
              <>
                <Power className="w-4 h-4 mr-2 text-green-500" />
                Activer
              </>
            )}
          </button>

          <div className="border-t border-gray-200 my-1" />

          <button
            onClick={() => {
              onDelete();
              setIsOpen(false);
            }}
            className="w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-red-50 flex items-center"
          >
            <Trash2 className="w-4 h-4 mr-2" />
            Supprimer
          </button>
        </div>
      )}
    </div>
  );
};
