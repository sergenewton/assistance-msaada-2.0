import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { AlertTriangle, Tag, User as UserIcon, FileText, MapPin, Images, ShieldAlert, ClipboardCheck, Zap } from 'lucide-react';
import Button from '@/components/UI/Button';
import { CaseDetail, EvaluationState, UrgencyLevel } from '@/types/cases';

interface Step1AnalysisProps {
  data: CaseDetail;
  evaluation: EvaluationState;
  onChange: (patch: Partial<EvaluationState>) => void;
  onDecryptNarrative?: () => void;
}

const urgencyLabel: Record<UrgencyLevel, string> = {
  low: 'Risque faible',
  moderate: 'Risque modéré',
  high: 'Risque élevé',
  critical: 'Risque critique',
};

const genderLabels: Record<string, string> = {
  female: 'Féminin',
  male: 'Masculin',
  other: 'Autre',
  unknown: 'Inconnu',
};

const relationshipLabels: Record<string, string> = {
  family_member: 'Membre de la famille',
  employer: 'Employeur',
  colleague: 'Collègue',
  teacher: 'Enseignant',
  authority: 'Autorité',
  religious_leader: 'Leader religieux',
  neighbor: 'Voisin',
  stranger: 'Inconnu',
  partner: 'Partenaire',
  parent: 'Parent',
  unknown: 'Inconnu',
  other: 'Autre',
};

const violenceLabels: Record<string, string> = {
  rape: 'Viol',
  sexual_assault: 'Agression sexuelle',
  sexual_harassment: 'Harcèlement sexuel',
  sexual_exploitation: 'Exploitation sexuelle',
  forced_marriage: 'Mariage forcé / viol conjugal',
  female_genital_mutilation: 'Mutilations génitales féminines',
  incest: 'Inceste',
  sextortion: 'Chantage sexuel / sextorsion',
  sexual_slavery: 'Esclavage sexuel',
  physical_assault: 'Violence physique',
  psychological_violence: 'Violence psychologique',
  denial_resources: 'Déni de ressources / économique',
  other: 'Autre forme de violence',
};


const urgencyClass: Record<UrgencyLevel, string> = {
  critical: 'badge badge-danger inline-flex px-3 py-1 rounded-full text-sm font-medium bg-danger-50 text-danger-700 border border-danger-200',
  high: 'badge badge-warning inline-flex px-3 py-1 rounded-full text-sm font-medium bg-warning-50 text-warning-700 border border-warning-200',
  moderate: 'badge badge-gray inline-flex px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-700 border border-gray-200',
  low: 'badge badge-secondary inline-flex px-3 py-1 rounded-full text-sm font-medium bg-secondary-100 text-secondary-800 border border-secondary-200',
};

function ItemRow({ label, value }: { label: string; value?: React.ReactNode }) {
  return (
    <div className="flex justify-between py-2 border-b border-gray-100">
      <div className="text-sm text-gray-600">{label}</div>
      <div className="text-sm text-gray-900 dark:text-gray-100">{value ?? '—'}</div>
    </div>
  );
}

export const Step1Analysis: React.FC<Step1AnalysisProps> = ({ data, evaluation, onChange, onDecryptNarrative }) => {
  const elapsed = data.elapsedMinutes != null ? `${data.elapsedMinutes} min` : '—';
  return (
    <div className="space-y-6">
      {/* Groupe 1 */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="-mx-4 -mt-4 mb-3 px-4 py-2 bg-success-600 dark:bg-success-700 text-white rounded-t-md flex items-center gap-2">
          <AlertTriangle className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Informations du signalement</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ItemRow label="Numéro du cas" value={`#${data.trackingNumber}`} />
          <ItemRow label="Date/Heure du signalement" value={new Date(data.createdAt).toLocaleString('fr-FR')} />
          <ItemRow label="Temps écoulé" value={`${data.elapsedMinutes}`} />
          <ItemRow label="Score d'urgence" value={`${data.autoUrgencyScore ?? 0}/100`} />
          <div className="flex justify-between py-2">
            <div className="text-sm text-gray-600">Niveau d'urgence</div>
            <span className={urgencyClass[data.urgency]}>{urgencyLabel[data.urgency]}</span>
          </div>
        </div>
      </section>

      {/* 🟩 Type(s) de violence subie(s) */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <Tag className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Type(s) de violence subie(s)</h3>
        </div>

    

        {/* Liste des types supplémentaires */}
        <div className="flex flex-wrap gap-2 text-xs">
          {(() => {
              // On normalise les types
              let types: string[] = [];

              if (Array.isArray(data.violenceTypes)) {
                types = data.violenceTypes;
              } else if (data.violenceTypes && typeof data.violenceTypes === 'object') {
                types = Object.entries(data.violenceTypes)
                  .filter(([_, val]) => val)
                  .map(([key]) => key);
              }

              const translated = types.map(
                (key) => violenceLabels[key] || key.replace(/_/g, ' ')
              );

              return (
                <>
                
                  {/* Liste complète */}
                  <div className="flex flex-wrap gap-2 text-xs">
                    {translated.length > 0 ? (
                      translated.map((label, i) => (
                        <span
                          key={i}
                          className="px-2 py-1 rounded border border-success-200 bg-success-50 text-success-800"
                        >
                          {label}
                        </span>
                      ))
                    ) : (
                      <span className="text-sm text-gray-500">Aucun autre type signalé</span>
                    )}
                  </div>
                </>
              );
          })()}
        </div>
      </section>


      {/* 🟩 Informations sur la victime */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <UserIcon className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Informations sur la victime</h3>
        </div>

        {(() => {
       
          return (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <ItemRow label="Âge (tranche)" value={data.victim.ageRange} />
              <ItemRow label="Genre" value={genderLabels[data.victim.gender ?? 'unknown'] || 'Inconnu'}/>
              <ItemRow label="Province" value={data.victim.province} />
              <ItemRow label="Commune" value={data.victim.commune} />
              <ItemRow label="Quartier" value={data.victim.quartier} />
            </div>
          );
        })()}
                 {/* Adresse */}
         <div className="text-sm text-gray-600 mb-1">Addresse</div>
        <div className="text-sm text-gray-900 mb-3">{data.location?.address || '—'}</div>
      </section>


     {/* 🟩 3. Localisation & Adresse */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <MapPin className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Localisation GPS</h3>
        </div>

       

        {/* Carte Leaflet */}
        <div className="rounded overflow-hidden border border-gray-200 dark:border-gray-700">
          {typeof data.location?.latitude === 'number' && typeof data.location?.longitude === 'number' ? (
            <MapContainer
              center={[data.location.latitude, data.location.longitude]}
              zoom={13}
              style={{ height: 256, width: '100%' }}
            >
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <Marker position={[data.location.latitude, data.location.longitude]}>
                <Popup>{data.location.address || 'Position du signalement'}</Popup>
              </Marker>
            </MapContainer>
          ) : (
            <div className="h-64 bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-500 text-sm">
              Carte indisponible (coordonnées manquantes)
            </div>
          )}
        </div>
      </section>
            {/* 🟩 4. Détails de l’incident */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <FileText className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Détails de l'incident</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ItemRow label="Date de l'incident" value={data.incidentDate ? new Date(data.incidentDate).toLocaleDateString('fr-FR') : '—'} />
          <ItemRow label="Lien avec l'agresseur" value={data.incident.perpetrator_relationship ? relationshipLabels[data.incident.perpetrator_relationship] || '—' : '—'} />
        </div>
        <div className="mt-3">
          <div className="text-sm text-gray-600 mb-1">Description narrative</div>
          <div className="text-sm text-gray-900 mb-3">
            {data.incident.narrativeEncrypted ? (
              <div className="flex items-center justify-between">
                <span className="italic text-gray-500">[Chiffrée] Accès via traçabilité</span>
                <Button size="sm" variant="successOutline" className="rounded-full" onClick={onDecryptNarrative}>
                  Déchiffrer
                </Button>
              </div>
            ) : (
              data.incident.narrativePreview || '—'
            )}

          </div>
        </div>

     
      </section>

      {/* 🟩 5. Preuves jointes */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <Images className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Preuves jointes</h3>
        </div>

        <div className="space-y-4 text-sm">
          {/* Photos */}
          <div>
            <div className="text-gray-600 mb-1">Photos</div>
            {data.attachments?.photos?.length ? (
              <div className="flex flex-wrap gap-2">
                {data.attachments.photos.map((url, i) => (
                  <img key={i} src={url} alt={`photo-${i}`} className="w-24 h-24 object-cover rounded border" />
                ))}
              </div>
            ) : (
              <span className="text-gray-500">Aucune photo disponible</span>
            )}
          </div>

          {/* Audios */}
          <div>
            <div className="text-gray-600 mb-1">Audios</div>
            {data.attachments?.audio?.length ? (
              <div className="space-y-1">
                {data.attachments.audio.map((url, i) => (
                  <audio key={i} controls className="w-full">
                    <source src={url} />
                  </audio>
                ))}
              </div>
            ) : (
              <span className="text-gray-500">Aucun fichier audio</span>
            )}
          </div>
        </div>
      </section>

      {/* 🟩 6. État actuel de la victime */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <ShieldAlert className="w-4 h-4" />
          <h3 className="text-sm font-semibold">État actuel de la victime</h3>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
          <ItemRow label="En sécurité actuellement ?" value={data.dangerIndicators?.safeNow ? 'Oui' : 'Non'} />
          <ItemRow label="Besoin de soins urgents ?" value={data.dangerIndicators?.urgentCareNeeded ? 'Oui' : 'Non'} />
          <ItemRow label="Enfants en danger ?" value={data.dangerIndicators?.childrenAtRisk ? 'Oui' : 'Non'} />
          <ItemRow label="Menaces de mort récentes ?" value={data.dangerIndicators?.recentDeathThreats ? 'Oui' : 'Non'} />
          <ItemRow label="Auteur a accès au domicile ?" value={data.dangerIndicators?.perpetratorHasHomeAccess ? 'Oui' : 'Non'} />
        </div>
      </section>

      {/* 🟩 7. Besoins exprimés */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <ClipboardCheck className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Besoins exprimés</h3>
        </div>

        <div className="flex flex-wrap gap-2 text-xs">
          {data.needs?.psycho && <span className="px-2 py-1 rounded border">Écoute psychologique</span>}
          {data.needs?.medical && <span className="px-2 py-1 rounded border">Soins médicaux</span>}
          {data.needs?.legal && <span className="px-2 py-1 rounded border">Aide juridique</span>}
          {data.needs?.shelter && <span className="px-2 py-1 rounded border">Hébergement sûr</span>}
          {data.needs?.economic && <span className="px-2 py-1 rounded border">Aide économique</span>}
          {data.needs?.police && <span className="px-2 py-1 rounded border">Protection policière</span>}
          {!data.needs && <span className="text-sm text-gray-500">Aucun besoin renseigné</span>}
        </div>
      </section>

     

     {/* 🟩 Évaluation de l’opérateur */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <ClipboardCheck className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Évaluation de l'opérateur</h3>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Niveau d'urgence */}
          <div>
            <div className="text-xs text-gray-600 mb-1">Confirmer le niveau d'urgence</div>
            <div className="flex flex-col gap-2 text-sm">
              {(['low', 'moderate', 'high', 'critical'] as UrgencyLevel[]).map((v) => (
                <label key={v} className="inline-flex items-center gap-2">
                  <input
                    type="radio"
                    name="confirmedUrgency"
                    className="text-success-600 focus:ring-success-500"
                    checked={evaluation.confirmedUrgency === v}
                    onChange={() => onChange({ confirmedUrgency: v })}
                  />
                  <span>{urgencyLabel[v]}</span>
                </label>
              ))}
            </div>
          </div>

          {/* Danger imminent */}
          <div>
            <div className="text-xs text-gray-600 mb-1">Danger imminent détecté</div>
            <div className="flex flex-col gap-2 text-sm">
              <label className="inline-flex items-center gap-2">
                <input
                  type="radio"
                  name="imminentDanger"
                  className="text-success-600 focus:ring-success-500"
                  checked={evaluation.imminentDanger === true}
                  onChange={() => onChange({ imminentDanger: true })}
                />
                <span>Oui</span>
              </label>
              <label className="inline-flex items-center gap-2">
                <input
                  type="radio"
                  name="imminentDanger"
                  className="text-danger-600 focus:ring-danger-500"
                  checked={evaluation.imminentDanger === false}
                  onChange={() => onChange({ imminentDanger: false })}
                />
                <span>Non</span>
              </label>
            </div>
          </div>

     
        </div>
             {/* Actions immédiates */}
          <div>
            <div className="text-xs text-gray-600 mb-1 mt-6">Actions immédiates recommandées</div>
            <textarea
              maxLength={500}
              placeholder="Ex : Contacter la police immédiatement, hébergement d'urgence, soins médicaux prioritaires..."
              className="w-full border rounded-md p-2 text-sm min-h-[96px] focus:ring-success-500 focus:border-success-500"
              value={evaluation.immediateActions}
              onChange={(e) => onChange({ immediateActions: e.target.value })}
            />
            <div className="text-xs text-gray-500 mt-1 text-right">
              {evaluation.immediateActions?.length ?? 0}/500 caractères
            </div>
          </div>
      </section>

      {/* 🟩 Actions rapides */}
      <section className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 p-4">
        <div className="flex items-center gap-2 bg-success-600 text-white px-4 py-2 rounded-t-md -mx-4 -mt-4 mb-3">
          <Zap className="w-4 h-4" />
          <h3 className="text-sm font-semibold">Actions rapides</h3>
        </div>

        <div className="flex flex-wrap gap-2">
          <Button variant="danger" size="sm" className="rounded-full">
            🚨 Alerter les services d'urgence
          </Button>
          <Button variant="successOutline" size="sm" className="rounded-full">
            📞 Appeler la victime
          </Button>
          <Button variant="warningOutline" size="sm" className="rounded-full">
            🏥 Orienter vers un centre médical
          </Button>
          <Button variant="secondaryOutline" size="sm" className="rounded-full">
            🧭 Enregistrer une note interne
          </Button>
        </div>
      </section>

    </div>
  );
};

export default Step1Analysis;
