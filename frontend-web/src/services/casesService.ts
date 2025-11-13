import { AxiosInstance } from 'axios';
import { authService } from '@/services/authService';
import { CaseDetail, UrgencyLevel } from '@/types/cases';

function normalizeUrgency(v: any): UrgencyLevel {
  if (!v && v !== 0) return 'moderate';
  const s = String(v).toLowerCase();
  if (['critical', 'critique', 'very_high'].includes(s)) return 'critical';
  if (['high', 'eleve', 'elevé', 'urgent'].includes(s)) return 'high';
  if (['moderate', 'medium', 'modere', 'modéré'].includes(s)) return 'moderate';
  if (['low', 'faible'].includes(s)) return 'low';
  const num = Number(v);
  if (!Number.isNaN(num)) {
    if (num >= 80) return 'critical';
    if (num >= 60) return 'high';
    if (num >= 30) return 'moderate';
    return 'low';
  }
  return 'moderate';
}

function formatElapsedTime(createdAt: string): string {
  try {
    const createdDate = new Date(createdAt);
    const now = new Date();
    const diffMs = now.getTime() - createdDate.getTime();

    const totalMinutes = Math.floor(diffMs / (1000 * 60));
    const days = Math.floor(totalMinutes / (60 * 24));
    const hours = Math.floor((totalMinutes % (60 * 24)) / 60);
    const minutes = totalMinutes % 60;

    // Format avec padding (ex: 02J 05Hrs 07Min)
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${pad(days)}J ${pad(hours)}Hrs ${pad(minutes)}Min`;
  } catch {
    return '00J 00Hrs 00Min';
  }
}


function pick<T=any>(obj: any, keys: string[], fallback?: any): T | any {
  for (const k of keys) {
    const parts = k.split('.');
    let val: any = obj;
    for (const p of parts) {
      if (val && typeof val === 'object' && p in val) {
        val = val[p];
      } else {
        val = undefined;
        break;
      }
    }
    if (val !== undefined && val !== null) return val as T;
  }
  return fallback as T;
}

function mapApiToCaseDetail(raw: any, fallbackId: string): CaseDetail {
  const r = raw?.data ?? raw?.report ?? raw?.case ?? raw ?? {};
  // Payload (JSON )
let payload = pick<any>(r, ['payload'], {});
if (typeof payload === 'string') {
  try {
    payload = JSON.parse(payload);
  } catch {
    payload = {};
  }
}  

  const id = pick<string>(r, ['id', 'uuid', 'report_id'], fallbackId);
  const trackingNumber = pick<string>(r, ['report_number', 'tracking', 'trackingNumber', 'number', 'id'], String(fallbackId));
  const createdAtRaw = pick<any>(r, ['created_at', 'createdAt', 'created', 'date_created'], new Date().toISOString());
  const createdAt = typeof createdAtRaw === 'string' ? createdAtRaw : new Date(createdAtRaw).toISOString();
  const urgency = normalizeUrgency(pick<any>(r, ['urgency_level', 'risk', 'risk_level', 'priority', 'autoUrgencyScore']));
  const violenceType = (pick<string>(r, ['violence_type', 'violenceType', 'type', 'category'], 'other') || 'other') as CaseDetail['violenceType'];
 const violenceTypes = pick<any>(r, ['violence_types', 'violenceTypes', 'types'], []);
  



  // Victim info
  const victim = {
    ageRange: pick<string>(r, ['victim_age_range', 'victim.age_range', 'victim.ageRange']),
    gender: pick<string>(r, ['victim_gender', 'victim.gender']) as any,
    province: pick<string>(r, ['location_province', 'victim.province', 'province']),
    commune: pick<string>(r, ['location_commune', 'victim.commune', 'commune']),
    quartier: pick<string>(r, ['location_quartier', 'victim.quartier', 'quartier']),
    is_anonymous: Boolean(pick<any>(r, ['is_anonymous', 'victim.is_anonymous', 'anonymous'])),
    reporter_name: pick<string>(r, ['reporter_name', 'victim.reporter_name', 'reporterName']),
    victim_name: pick<string>(r, ['victim_name', 'victim.name', 'name']),
    contact_number: pick<string>(r, ['contact_number', 'victim.contact_number', 'contactNumber']),
    address_line: pick<string>(r, ['address_line', 'victim.address_line', 'addressLine']),
    victim_status: pick<string>(r, ['victim_status', 'victim.status', 'status']),
  };

  // Incident info
  const narrationRaw = payload?.narrative ?? '';
  const incident = {
    place: pick<string>(r, ['incident_place', 'incident.place', 'place']) as any,
    narrativeEncrypted: pick<string>(r, ['narrative', 'incident.narrative_encrypted']),
    narrativePreview: narrationRaw,
    perpetrator_relationship: pick<string>(r, ['perpetrator_relationship', 'incident.perpetrator_relationship']) as any,
  };

  // Location
  const latitude = pick<number>(r, ['latitude', 'lat', 'location.latitude']);
  const longitude = pick<number>(r, ['longitude', 'lng', 'location.longitude']);
  const location = {
    address: pick<string>(r, ['incident_location', 'location.address']),
    latitude: typeof latitude === 'string' ? parseFloat(latitude) : latitude,
    longitude: typeof longitude === 'string' ? parseFloat(longitude) : longitude,
  } as CaseDetail['location'];

  // Attachments
  const photos = pick<string[]>(r, ['attachments.photos', 'photos'], []) || [];
  const audio = pick<string[]>(r, ['attachments.audio', 'audios', 'audio'], []) || [];

  // Danger indicators
  const dangerIndicators = {
    safeNow: Boolean(pick<any>(r, ['is_safe_now', 'danger.safe_now'])),
    urgentCareNeeded: Boolean(pick<any>(r, ['needs_urgent_medical', 'danger.urgent_care_needed'])),
    childrenAtRisk: Boolean(pick<any>(r, ['children_at_risk', 'danger.children_at_risk'])),
    recentDeathThreats: Boolean(pick<any>(r, ['death_threats', 'danger.recent_death_threats'])),
    perpetratorHasHomeAccess: Boolean(pick<any>(r, ['perpetrator_has_home_access', 'danger.perpetrator_has_home_access'])),
  };



// Besoins (récupérés depuis payload.needs)
const needsRaw = payload?.needs ?? {};
const needs = {
  psycho: Boolean(needsRaw?.psycho),
  medical: Boolean(needsRaw?.medical),
  legal: Boolean(needsRaw?.legal),
  shelter: Boolean(needsRaw?.shelter),
  economic: Boolean(needsRaw?.economic),
  police: Boolean(needsRaw?.police),
  };

  // Calcul du temps écoulé depuis la création jusqu'à maintenant (en minutes)
  const elapsedFormatted = formatElapsedTime(createdAt);



  const detail: CaseDetail = {
    id: String(id),
    trackingNumber: String(trackingNumber),
    createdAt,
    elapsedMinutes: elapsedFormatted,
    autoUrgencyScore: pick<number>(r, ['urgency_score', 'autoUrgencyScore']),
    urgency,
    violenceType: (violenceType || 'other') as CaseDetail['violenceType'],
    violenceTypes: violenceTypes || {},
    victim,
    incident,
    location,
    attachments: { photos, audio },
    dangerIndicators,
    needs,

  };

  return detail;
}

class CasesService {
  private api: AxiosInstance;
  constructor() {
    this.api = authService.getApi();
  }

  async getCaseDetail(id: string): Promise<CaseDetail> {
    // Try multiple endpoints for compatibility across backend builds
    const endpoints = [
      `/reports/${encodeURIComponent(id)}`,
      `/reports/show/${encodeURIComponent(id)}`,
      `/cases/${encodeURIComponent(id)}`,
      `/cases/detail/${encodeURIComponent(id)}`,
    ];

    let lastError: any;
    for (const url of endpoints) {
      try {
        if (import.meta.env.DEV) console.debug('[casesService] GET', url);
        const { data } = await this.api.get(url);
        return mapApiToCaseDetail(data, id);
      } catch (e) {
        lastError = e;
      }
    }
    // Fallback strategy: search through listing endpoints and pick the matching item
    const listingEndpoints = [
      `/reports/unprocessed`,
      `/reports/unprocessed-urgent`,
      `/reports`,
    ];
    for (const url of listingEndpoints) {
      try {
        const { data } = await this.api.get(url, { params: { limit: 200 } });
        const items = data?.data?.items || data?.items || [];
        const found = (items as any[]).find((r) => {
          const rid = r?.id || r?.uuid || r?.report_id;
          const rn = r?.report_number || r?.tracking || r?.trackingNumber;
          return String(rid) === String(id) || String(rn) === String(id);
        });
        if (found) {
          return mapApiToCaseDetail(found, id);
        }
      } catch (e) {
        lastError = e;
      }
    }
    // As a last resort, throw the last error
    throw lastError ?? new Error('Impossible de charger le dossier.');
  }
}

export const casesService = new CasesService();
