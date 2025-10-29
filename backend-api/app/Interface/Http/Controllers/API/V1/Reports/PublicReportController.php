<?php

namespace App\Interface\Http\Controllers\API\V1\Reports;

use Illuminate\Routing\Controller as Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PublicReportController extends Controller
{
    /**
     * Public submit endpoint: accepts reports without authentication.
     */
    public function submit(Request $request)
    {
        $payload = $request->all();

        // Basic, permissive validation for public submissions
        $v = Validator::make($payload, [
            'violence_type' => 'required', // can be array or string
            'urgency_level' => 'required|string|in:low,moderate,high,critical',
            'incident_location' => 'required',
        ]);

        if ($v->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $v->errors(),
            ], 422);
        }

        $violence = $payload['violence_type'];
        $violencePrimary = is_array($violence) ? ($violence[0] ?? 'other') : $violence;

        // Extract location
        $location = $payload['incident_location'];
        $addressLine = is_array($location) ? ($location['address_line'] ?? null) : (string) $location;
        $lat = is_array($location) ? ($location['latitude'] ?? null) : null;
        $lng = is_array($location) ? ($location['longitude'] ?? null) : null;

        // Contact methods
        $preferredContactMethod = $payload['preferred_contact_method'] ?? null;
        $preferredContactMethods = $payload['preferred_contact_methods'] ?? null;

        // Names / anonymity
        $isAnonymous = (bool) ($payload['is_anonymous'] ?? false);
        $reporterName = $isAnonymous ? null : ($payload['reporter_name'] ?? null);
        $victimName = $isAnonymous ? null : ($payload['victim_name'] ?? null);
        $contactNumber = $isAnonymous && empty($preferredContactMethods) && empty($preferredContactMethod)
            ? null
            : ($payload['contact_number'] ?? null);

        // Generate tracking number VBG-XXXX-XXXX
        $tracking = sprintf('VBG-%04d-%04d', random_int(0, 9999), random_int(0, 9999));

        $report = new Report();
        $report->id = (string) Str::uuid();
        $report->report_number = $tracking;
        $report->reporter_id = null; // public submission
        $report->reporter_name = $reporterName;
        $report->victim_name = $victimName;
        $report->contact_number = $contactNumber;
        $report->is_anonymous = $isAnonymous;
        $report->violence_type = $violencePrimary ?: 'other';
        $report->violence_types = is_array($violence) ? array_values($violence) : [$violencePrimary];
        $report->urgency_level = $payload['urgency_level'];
        $report->incident_location = $addressLine;
        $report->incident_location_json = is_array($location) ? $location : null;
        $report->address_line = $addressLine;
        $report->latitude = $lat;
        $report->longitude = $lng;
        $report->narrative = $payload['narrative'] ?? null;
        $report->preferred_contact_method = $preferredContactMethod;
        $report->preferred_contact_methods = is_array($preferredContactMethods) ? $preferredContactMethods : ($preferredContactMethods ? [$preferredContactMethods] : null);
        $report->attachments = $payload['attachments'] ?? null;
        $report->status = 'new';
        $report->payload = $payload;
        $report->save();

        return response()->json([
            'success' => true,
            'message' => 'Signalement reçu',
            'report_number' => $tracking,
            'data' => [
                'id' => $report->id,
                'created_at' => $report->created_at?->toISOString(),
            ],
        ]);
    }

    /**
     * Public get-by-tracking endpoint.
     */
    public function showByTracking(string $tracking)
    {
        $report = Report::query()->where('report_number', $tracking)->first();
        if (!$report) {
            return response()->json([
                'success' => false,
                'message' => 'Signalement introuvable',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'report_number' => $report->report_number,
                'status' => $report->status,
                'created_at' => $report->created_at?->toISOString(),
                'violence_type' => $report->violence_type,
                'violence_types' => $report->violence_types,
                'urgency_level' => $report->urgency_level,
                'incident_location' => [
                    'address_line' => $report->address_line,
                    'latitude' => $report->latitude,
                    'longitude' => $report->longitude,
                ],
                'preferred_contact_method' => $report->preferred_contact_method,
                'preferred_contact_methods' => $report->preferred_contact_methods,
            ],
        ]);
    }
}
