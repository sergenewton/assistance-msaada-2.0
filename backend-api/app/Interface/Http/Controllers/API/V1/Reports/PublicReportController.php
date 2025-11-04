<?php

namespace App\Interface\Http\Controllers\API\V1\Reports;

use Illuminate\Routing\Controller as Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PublicReportController extends Controller
{
    /**
     * Public submit endpoint: accepts reports without authentication.
     */
    public function submit(Request $request): JsonResponse
    {
        $payload = $request->all();

        // Basic validation (support both legacy and new mobile payloads)
        $v = Validator::make($payload, [
            'violence_type' => 'sometimes',
            'violence_types' => 'sometimes|array|min:1',
            'violence_types.*' => 'string|max:50',
            'urgency_level' => 'required|string|in:low,moderate,high,critical',
            'incident_location' => 'sometimes',
            'address_line' => 'sometimes|string',
            'latitude' => 'sometimes|numeric',
            'longitude' => 'sometimes|numeric',
            'incident_date' => 'sometimes|date',
            'preferred_contact_methods' => 'sometimes|array',
            'preferred_contact_method' => 'sometimes|nullable|string',
            'preferred_contact_hours' => 'sometimes',
            'narrative' => 'sometimes|nullable|string|max:1000',
            'narrative_encrypted' => 'sometimes|boolean',
            'is_anonymous' => 'sometimes|boolean',
        ]);

        if ($v->fails()) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => $v->errors(),
            ], 422);
        }

        // Normalize violence types
        $normalizeViolence = function ($s) {
            if ($s === null) return null;
            $map = [
                'rape' => 'sexual',
                'sexual_assault' => 'sexual',
                'sexual-violence' => 'sexual',
                'fgm' => 'mgf',
                'female_genital_mutilation' => 'mgf',
                'physical_assault' => 'physical',
                'psychological_abuse' => 'psychological',
                'forced_marriage' => 'forced_marriage',
            ];
            $k = strtolower((string) $s);
            return $map[$k] ?? $k;
        };

        $violenceTypes = [];
        if (isset($payload['violence_types']) && is_array($payload['violence_types'])) {
            $violenceTypes = array_values(array_filter(array_map($normalizeViolence, $payload['violence_types'])));
        } elseif (isset($payload['violence_type'])) {
            $vSingle = $payload['violence_type'];
            if (is_array($vSingle)) {
                $violenceTypes = array_values(array_filter(array_map($normalizeViolence, $vSingle)));
            } else {
                $violenceTypes = [$normalizeViolence($vSingle) ?? 'other'];
            }
        }

        if (empty($violenceTypes)) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Données invalides',
                'errors' => ['violence_types' => ['Au moins un type de violence est requis.']],
            ], 422);
        }

        $violencePrimary = $violenceTypes[0] ?? 'other';

        // Extract location
        $place = null;
        $addressLine = $payload['address_line'] ?? null;
        $lat = $payload['latitude'] ?? null;
        $lng = $payload['longitude'] ?? null;
        if (isset($payload['incident_location'])) {
            $loc = $payload['incident_location'];
            if (is_array($loc)) {
                $addressLine = $addressLine ?? ($loc['address_line'] ?? ($loc['address'] ?? null));
                $lat = $lat ?? ($loc['latitude'] ?? null);
                $lng = $lng ?? ($loc['longitude'] ?? null);
                $place = $loc['place'] ?? null;
            } elseif (is_string($loc)) {
                $place = $loc;
            }
        }

        // Contact methods
        $preferredContactMethod = $payload['preferred_contact_method'] ?? null;
        $preferredContactMethods = $payload['preferred_contact_methods'] ?? null;

        // Normalize contact hours: accept string or array, store as JSON
        $preferredContactHours = $payload['preferred_contact_hours'] ?? null;
        if (is_string($preferredContactHours)) {
            $preferredContactHours = [$preferredContactHours];
        }

        // Names / anonymity
        $isAnonymous = (bool) ($payload['is_anonymous'] ?? false);
        $reporterName = $isAnonymous ? null : ($payload['reporter_name'] ?? null);
        $victimName = $isAnonymous ? null : ($payload['victim_name'] ?? null);
        $contactNumber = $isAnonymous && empty($preferredContactMethods) && empty($preferredContactMethod)
            ? null
            : ($payload['contact_number'] ?? null);

        // Generate tracking number VBG-YYYY-XXXX-XXXX
        $tracking = sprintf('VBG-%s-%04d-%04d', date('Y'), random_int(0, 9999), random_int(0, 9999));

        $report = new Report();
        $report->id = (string) Str::uuid();
        $report->report_number = $tracking;
        $report->reporter_id = null; // public submission
        $report->reporter_name = $reporterName;
        $report->victim_name = $victimName;
        $report->contact_number = $contactNumber;
        $report->is_anonymous = $isAnonymous;
        $report->violence_type = $violencePrimary ?: 'other';
        $report->violence_types = $violenceTypes;
        $report->urgency_level = $payload['urgency_level'];
        $report->incident_date = $payload['incident_date'] ?? null;

        // Incident & location fields
        $report->incident_location = $place ?? $addressLine;
        $report->incident_location_json = [
            'place' => $place,
            'address_line' => $addressLine,
            'latitude' => $lat,
            'longitude' => $lng,
        ];
        $report->address_line = $addressLine;
        $report->latitude = $lat;
        $report->longitude = $lng;

        // Narrative & victim details
        $report->narrative = $payload['narrative'] ?? null;
        $report->victim_age_range = $payload['victim_age_range'] ?? null;
        $report->victim_gender = $payload['victim_gender'] ?? null;
        $report->location_province = $payload['location_province'] ?? null;
        $report->location_commune = $payload['location_commune'] ?? null;
        $report->location_quartier = $payload['location_quartier'] ?? null;
        $report->perpetrator_relationship = $payload['perpetrator_relationship'] ?? null;
        $report->perpetrator_has_home_access = $payload['perpetrator_has_home_access'] ?? null;

        // Danger indicators
        $report->is_safe_now = array_key_exists('is_safe_now', $payload) ? (bool)$payload['is_safe_now'] : null;
        $report->needs_urgent_medical = array_key_exists('needs_urgent_medical', $payload) ? (bool)$payload['needs_urgent_medical'] : null;
        $report->children_at_risk = array_key_exists('children_at_risk', $payload) ? (bool)$payload['children_at_risk'] : null;
        $report->death_threats = array_key_exists('death_threats', $payload) ? (bool)$payload['death_threats'] : null;

        // Contact preferences
        $report->preferred_contact_method = $preferredContactMethod;
        $report->preferred_contact_methods = is_array($preferredContactMethods)
            ? $preferredContactMethods
            : ($preferredContactMethods ? [$preferredContactMethods] : null);
        $report->preferred_contact_hours = $preferredContactHours
            ? json_encode($preferredContactHours)
            : null;

        $report->safety_code_word = $payload['safety_code_word'] ?? null;
        $report->attachments = $payload['attachments'] ?? null;
        $report->status = 'new';
        $report->created_by = 'public_api'; // audit trail

        // Full payload for traceability
        $report->payload = $payload;
        $report->save();

        return new JsonResponse([
            'success' => true,
            'message' => 'Signalement reçu',
            'report_number' => $tracking,
            'data' => [
                'id' => $report->id,
                'created_at' => $report->created_at?->toISOString(),
                'urgency_level' => $report->urgency_level,
                'violence_types' => $report->violence_types,
            ],
        ], 201);
    }

    /**
     * Public get-by-tracking endpoint.
     */
    public function showByTracking(string $tracking): JsonResponse
    {
        $report = Report::query()->where('report_number', $tracking)->first();

        if (!$report) {
            return new JsonResponse([
                'success' => false,
                'message' => 'Signalement introuvable',
            ], 404);
        }

        return new JsonResponse([
            'success' => true,
            'data' => [
                'report_number' => $report->report_number,
                'status' => $report->status,
                'status_label' => ucfirst($report->status),
                'created_at' => $report->created_at?->toISOString(),
                'violence_type' => $report->violence_type,
                'violence_types' => $report->violence_types,
                'urgency_level' => $report->urgency_level,
                'victim_age_range' => $report->victim_age_range,
                'victim_gender' => $report->victim_gender,
                'location_province' => $report->location_province,
                'location_commune' => $report->location_commune,
                'incident_location' => [
                    'place' => $report->incident_location,
                    'address_line' => $report->address_line,
                    'latitude' => $report->latitude,
                    'longitude' => $report->longitude,
                ],
                'preferred_contact_method' => $report->preferred_contact_method,
                'preferred_contact_methods' => $report->preferred_contact_methods,
                'preferred_contact_hours' => $report->preferred_contact_hours
                    ? json_decode($report->preferred_contact_hours, true)
                    : null,
            ],
        ]);
    }
}
