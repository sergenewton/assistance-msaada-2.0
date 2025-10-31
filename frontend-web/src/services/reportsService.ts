import { AxiosInstance } from 'axios';
import { CaseOverview } from '@/types/dashboard';
import { authService } from '@/services/authService';

export interface ListReportsParams {
  status?: string;
  urgency?: string | string[]; // e.g. 'high,critical'
  limit?: number;
  page?: number;
  sort?: string; // e.g. '-created_at'
}

class ReportsService {
  private api: AxiosInstance;

  constructor() {
    // Reuse the same Axios instance and interceptors as authService
    this.api = authService.getApi();
  }

  async listReports(params: ListReportsParams = {}): Promise<CaseOverview[]> {
    const query: Record<string, any> = {};

    if (params.status) query.status = params.status;
    if (params.urgency) {
      if (Array.isArray(params.urgency)) query.urgency = params.urgency.join(',');
      else query.urgency = params.urgency;
    }
    if (params.limit) query.limit = params.limit;
    if (params.page) query.page = params.page;
    if (params.sort) query.sort = params.sort;

    try {
      // Primary endpoint: GET /reports
      if (import.meta.env.DEV) console.debug('[reportsService] GET /reports', query);
      const { data } = await this.api.get('/reports', { params: query });
      const items = data?.data?.items || data?.data?.reports || data?.data || data?.items || data || [];
      return (items as any[]).map(this.mapReportToCaseOverview);
    } catch (err: any) {
      // Fallback to /reports/filter if /reports is not found on this backend build
      if (err?.response?.status === 404) {
        try {
          if (import.meta.env.DEV) console.debug('[reportsService] Fallback GET /reports/filter', query);
          const { data } = await this.api.get('/reports/filter', { params: query });
          const items = data?.data?.items || data?.data?.reports || data?.data || data?.items || data || [];
          return (items as any[]).map(this.mapReportToCaseOverview);
        } catch (e2: any) {
          if (e2?.response?.status === 404) {
            // Try user-specific listing
            if (import.meta.env.DEV) console.debug('[reportsService] Fallback GET /reports/my-reports', query);
            const { data } = await this.api.get('/reports/my-reports', { params: query });
            const items = data?.data?.items || data?.data?.reports || data?.data || data?.items || data || [];
            return (items as any[]).map(this.mapReportToCaseOverview);
          }
          throw e2;
        }
      }
      throw err;
    }
  }

  private mapReportToCaseOverview = (r: any): CaseOverview => {
    const urgencyMap: Record<string, 'critical' | 'high' | 'moderate' | 'low'> = {
      critical: 'critical',
      high: 'high',
      moderate: 'moderate',
      low: 'low',
    };

    // Try to derive a display type; fallback to raw violence_type
    const typeMap: Record<string, string> = {
      physical: 'Violence physique',
      sexual: 'Violence sexuelle',
      psychological: 'Violence psychologique',
      economic: 'Violence économique',
    };

    const createdAt = r.created_at || r.createdAt;
    const updatedAt = r.updated_at || r.updatedAt || createdAt;

    return {
      id: r.id || r.uuid || String(r.report_number || r.reportNumber || Math.random()),
      trackingNumber: r.report_number || r.tracking || r.reportNumber || 'N/A',
      urgency: urgencyMap[r.urgency_level] || 'low',
      status: (r.status || 'new') as any,
      type: typeMap[r.violence_type] || r.violence_type || 'Signalement',
      createdAt: typeof createdAt === 'string' ? createdAt : new Date(createdAt).toISOString(),
      lastUpdate: typeof updatedAt === 'string' ? updatedAt : new Date(updatedAt).toISOString(),
      assignedTo: r.assigned_aps?.name || r.assignedAPS?.name,
      organization: r.organization?.name,
    };
  };

  // Dedicated endpoints for operator triage
  async listUnprocessed(limit = 25): Promise<CaseOverview[]> {
    const { data } = await this.api.get('/reports/unprocessed', { params: { limit } });
    const items = data?.data?.items || data?.data || data?.items || data || [];
    return (items as any[]).map(this.mapReportToCaseOverview);
  }

  async listUnprocessedUrgent(limit = 25): Promise<CaseOverview[]> {
    const { data } = await this.api.get('/reports/unprocessed-urgent', { params: { limit } });
    const items = data?.data?.items || data?.data || data?.items || data || [];
    return (items as any[]).map(this.mapReportToCaseOverview);
  }
}

export const reportsService = new ReportsService();
