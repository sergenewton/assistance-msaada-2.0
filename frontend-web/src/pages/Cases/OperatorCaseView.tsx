import React from 'react';
import { useParams } from 'react-router-dom';
import { DashboardLayout } from '@/components/Layout/DashboardLayout';
import { OperatorNavigation } from '@/pages/Dashboard/OperatorDashboard';
import { AlertTriangle, Tag, User as UserIcon, FileText, MapPin, Images } from 'lucide-react';

const OperatorCaseView: React.FC = () => {
  const { id } = useParams<{ id: string }>();

  return (
    <DashboardLayout
      title={`Dossier #${id || ''}`}
      subtitle="Consultation du signalement"
      navigationItems={OperatorNavigation}
      userRole="operateur"
    >
      <div className="mb-0">
        <p className="text-sm text-gray-600 dark:text-gray-300">Vue de détail du dossier. (À brancher à l'API de consultation)</p>
      </div>
      <div className="space-y-6 mt-4">
        {/* Informations du signalement */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <AlertTriangle className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Informations du signalement</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div><div className="text-gray-600">Numéro du cas</div><div className="font-medium">#{id}</div></div>
            <div><div className="text-gray-600">Date/Heure du signalement</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Temps écoulé</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Niveau d'urgence</div><div className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-warning-50 text-warning-700 border border-warning-200">Risque élevé</div></div>
          </div>
        </section>

        {/* Type de violence */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <Tag className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Type de violence</h3>
          </div>
          <div className="text-sm text-gray-900">—</div>
        </section>

        {/* Informations victime */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <UserIcon className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Informations victime</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div><div className="text-gray-600">Âge (tranche)</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Genre</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Province</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Commune</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Quartier</div><div className="font-medium">—</div></div>
          </div>
        </section>

        {/* Détails de l'incident */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <FileText className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Détails de l'incident</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div><div className="text-gray-600">Date de l'incident</div><div className="font-medium">—</div></div>
            <div><div className="text-gray-600">Lieu</div><div className="font-medium">—</div></div>
          </div>
          <div className="mt-3">
            <div className="text-sm text-gray-600 mb-1">Description narrative</div>
            <div className="bg-gray-50 dark:bg-gray-700 rounded p-3 text-sm text-gray-800 dark:text-gray-100">—</div>
          </div>
        </section>

        {/* Localisation */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <MapPin className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Localisation & Adresse</h3>
          </div>
          <div className="text-sm text-gray-900">—</div>
          <div className="h-64 mt-3 bg-gray-100 dark:bg-gray-700 rounded flex items-center justify-center text-gray-500 text-sm">Afficher la carte (GPS)</div>
        </section>

        {/* Preuves */}
        <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
          <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
            <Images className="w-4 h-4" />
            <h3 className="text-sm font-semibold">Preuves</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <div className="text-gray-600">Photos</div>
              <div className="text-gray-500">Aucune</div>
            </div>
            <div>
              <div className="text-gray-600">Audios</div>
              <div className="text-gray-500">Aucun</div>
            </div>
          </div>
        </section>
      </div>
    </DashboardLayout>
  );
};

export default OperatorCaseView;
