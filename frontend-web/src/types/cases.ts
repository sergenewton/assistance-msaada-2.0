export type UrgencyLevel = 'low' | 'moderate' | 'high' | 'critical';

export interface CaseDetail {
  id: string;
  trackingNumber: string;
  createdAt: string;
  incidentDate?: string;
  elapsedMinutes?: number;
  autoUrgencyScore?: number; // 0-100
  urgency: UrgencyLevel;
  violenceType:
    | 'physical'
    | 'sexual'
    | 'psychological'
    | 'economic'
    | 'forced_marriage'
    | 'mgf'
    | 'other';
  victim: {
    ageRange?: string;
    gender?: 'f' | 'm' | 'other' | 'unknown';
    province?: string;
    commune?: string;
    quartier?: string;
  };
  incident: {
    place?: 'domicile' | 'travail' | 'espace_public' | 'autre';
    narrativeEncrypted?: boolean;
    narrativePreview?: string;
  };
  location?: {
    address?: string;
    latitude?: number;
    longitude?: number;
  };
  attachments?: {
    photos?: string[]; // URLs
    audio?: string[]; // URLs
  };
  dangerIndicators?: {
    safeNow?: boolean;
    urgentCareNeeded?: boolean;
    childrenAtRisk?: boolean;
    recentDeathThreats?: boolean;
    perpetratorHasHomeAccess?: boolean;
  };
  needs?: {
    psycho?: boolean;
    medical?: boolean;
    legal?: boolean;
    shelter?: boolean;
    economic?: boolean;
    police?: boolean;
  };
}

export interface EvaluationState {
  confirmedUrgency: UrgencyLevel;
  imminentDanger: boolean;
  immediateActions: string; // max 500
}

export interface APSProfile {
  id: string;
  fullName: string;
  title: string;
  yearsExp: number;
  relevanceScore: number; // 0-100
  specialties: string[];
  languages: string[];
  location: string;
  workload: number; // X/15
  satisfaction: number; // 0-5
  casesHandled: number;
  avgResponseHours: number;
  availability: 'now' | 'in-hours' | 'not-available';
}

export interface AssignApsState {
  selectedApsId?: string;
  message?: string;
  notifySms?: boolean;
  notifyPush?: boolean;
  notifyEmail?: boolean;
}

export interface OrganizationProfile {
  id: string;
  name: string;
  kind: string; // ONG, Hopital, Police, etc.
  distanceKm?: number;
  satisfaction?: number; // 0-5
  responseTime?: string; // e.g., "2h"
  cost?: 'gratuit' | 'participation' | 'payant';
  capacity?: number; // available slots
  availability?: 'green' | 'yellow' | 'red';
  openingHours?: string;
  services?: string[];
}

export type ReferralPriority = 'urgent_24h' | 'high_48h' | 'normal_7d' | 'low_14d';

export interface ReferralItem {
  id: string;
  serviceType: string; // Soins médicaux, Hébergement sûr, etc.
  priority: ReferralPriority;
  notes?: string;
  orgId?: string; // selected organization
}

export interface ReferralsState {
  items: ReferralItem[];
  notifyAps: boolean;
  smsVictim: boolean;
  callOrgBefore?: boolean;
}

export interface ValidationChecklist {
  infoChecked: boolean;
  orgsSelected: boolean;
  messagesRespectful: boolean;
  priorityUnderstood: boolean;
}

export interface TreatmentState {
  evaluation: EvaluationState;
  assignAps: AssignApsState;
  referrals: ReferralsState;
  validation: ValidationChecklist;
}
