<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OrganizationsSeeder extends Seeder
{
    /**
     * Seed des organisations partenaires par type de service
     */
    public function run(): void
    {
        $organizations = [
            // Organisations Médicales
            [
                'name' => 'Hôpital Général de Kinshasa',
                'type' => 'medical',
                'sector' => 'Santé',
                'address' => 'Avenue du 24 Novembre, Kinshasa/Gombe',
                'phone' => '+243814567890',
                'email' => 'contact@hgk.cd',
                'contact_person' => 'Dr. Michel Tshala',
                'services_offered' => json_encode([
                    'Soins médicaux d\'urgence',
                    'Certificats médicaux',
                    'Suivi psychologique',
                    'Examens médico-légaux'
                ]),
                'specialities' => json_encode(['VBG', 'Urgences', 'Psychologie']),
                'availability' => '24h/7j',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Centre Médical Monkole',
                'type' => 'medical',
                'sector' => 'Santé',
                'address' => 'Mont Ngafula, Kinshasa',
                'phone' => '+243815678901',
                'email' => 'vbg@monkole.org',
                'contact_person' => 'Dr. Marie Nzuzi',
                'services_offered' => json_encode([
                    'Consultations VBG',
                    'Soins post-viol',
                    'Accompagnement psychologique',
                    'Formation médicale'
                ]),
                'specialities' => json_encode(['VBG', 'Gynécologie', 'Pédiatrie']),
                'availability' => 'Lun-Ven 7h-17h, Urgences 24h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Forces de Sécurité
            [
                'name' => 'Police Nationale Congolaise - Bureau VBG',
                'type' => 'security',
                'sector' => 'Sécurité',
                'address' => 'Avenue Kabasele Tshamala, Kinshasa/Kalamu',
                'phone' => '+243816789012',
                'email' => 'vbg@pnc.cd',
                'contact_person' => 'Commissaire Grace Matondo',
                'services_offered' => json_encode([
                    'Dépôt de plaintes VBG',
                    'Protection des victimes',
                    'Enquêtes spécialisées',
                    'Arrestations'
                ]),
                'specialities' => json_encode(['VBG', 'Violence domestique', 'Crimes sexuels']),
                'availability' => '24h/7j',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Bureau Spécialisé VBG - Parquet de Kinshasa',
                'type' => 'security',
                'sector' => 'Justice',
                'address' => 'Palais de Justice, Kinshasa/Gombe',
                'phone' => '+243817890123',
                'email' => 'vbg@parquet-kinshasa.cd',
                'contact_person' => 'Procureur Adjoint Joseph Mbala',
                'services_offered' => json_encode([
                    'Poursuites judiciaires',
                    'Instruction des dossiers VBG',
                    'Protection judiciaire',
                    'Orientation juridique'
                ]),
                'specialities' => json_encode(['Droit pénal', 'VBG', 'Mineurs']),
                'availability' => 'Lun-Ven 8h-16h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Organisations Juridiques
            [
                'name' => 'Centre d\'Assistance Juridique aux Femmes (CAJF)',
                'type' => 'legal',
                'sector' => 'Juridique',
                'address' => 'Avenue Tombalbaye, Kinshasa/Kalamu',
                'phone' => '+243818901234',
                'email' => 'info@cajf.org',
                'contact_person' => 'Me. Antoinette Nsimba',
                'services_offered' => json_encode([
                    'Conseil juridique gratuit',
                    'Représentation en justice',
                    'Médiation familiale',
                    'Éducation juridique'
                ]),
                'specialities' => json_encode(['Droit de la famille', 'VBG', 'Droits des femmes']),
                'availability' => 'Lun-Ven 8h-17h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Association des Femmes Juristes du Congo (AFJC)',
                'type' => 'legal',
                'sector' => 'Juridique',
                'address' => 'Avenue du Commerce, Kinshasa/Gombe',
                'phone' => '+243819012345',
                'email' => 'contact@afjc.org',
                'contact_person' => 'Me. Claudine Mukamana',
                'services_offered' => json_encode([
                    'Assistance juridique VBG',
                    'Plaidoyer juridique',
                    'Formation en droits',
                    'Accompagnement judiciaire'
                ]),
                'specialities' => json_encode(['Droits humains', 'VBG', 'Advocacy']),
                'availability' => 'Lun-Ven 8h-16h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // ONG Psychosociales
            [
                'name' => 'HEAL Africa',
                'type' => 'psychosocial',
                'sector' => 'Psychosocial',
                'address' => 'Goma, Nord-Kivu',
                'phone' => '+243820123456',
                'email' => 'vbg@healafrica.org',
                'contact_person' => 'Dr. Zawadi Mukamana',
                'services_offered' => json_encode([
                    'Thérapie individuelle',
                    'Thérapie de groupe',
                    'Réinsertion sociale',
                    'Formation en traumatisme'
                ]),
                'specialities' => json_encode(['Traumatisme', 'VBG', 'Réhabilitation']),
                'availability' => 'Lun-Sam 8h-18h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'name' => 'Centre Olame - Accompagnement Psychosocial',
                'type' => 'psychosocial',
                'sector' => 'Psychosocial',
                'address' => 'Avenue Lumumba, Kinshasa/Limete',
                'phone' => '+243821234567',
                'email' => 'accompagnement@olame.org',
                'contact_person' => 'Psychologue Sarah Kambale',
                'services_offered' => json_encode([
                    'Counseling VBG',
                    'Thérapie familiale',
                    'Groupes de parole',
                    'Suivi post-traumatique'
                ]),
                'specialities' => json_encode(['Psychologie clinique', 'VBG', 'Famille']),
                'availability' => 'Lun-Ven 8h-17h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Organisations d'Hébergement
            [
                'name' => 'Foyer d\'Accueil Sécurisé Mama Jeanne',
                'type' => 'shelter',
                'sector' => 'Hébergement',
                'address' => 'Adresse confidentielle, Kinshasa',
                'phone' => '+243822345678',
                'email' => 'urgence@mamajeanne.org',
                'contact_person' => 'Coordinatrice Mama Jeanne',
                'services_offered' => json_encode([
                    'Hébergement d\'urgence',
                    'Sécurité 24h',
                    'Accompagnement social',
                    'Orientation vers services'
                ]),
                'specialities' => json_encode(['Protection', 'Urgence', 'Femmes et enfants']),
                'availability' => '24h/7j - Urgences uniquement',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            
            // Organisations de Réinsertion Économique
            [
                'name' => 'Programme de Réinsertion Économique des Femmes (PREF)',
                'type' => 'economic',
                'sector' => 'Économique',
                'address' => 'Avenue des Cliniques, Kinshasa/Kalamu',
                'phone' => '+243823456789',
                'email' => 'insertion@pref.org',
                'contact_person' => 'Coordinateur Albert Mukendi',
                'services_offered' => json_encode([
                    'Formation professionnelle',
                    'Micro-crédit',
                    'Accompagnement business',
                    'Alphabétisation'
                ]),
                'specialities' => json_encode(['Entrepreneuriat', 'Formation', 'Autonomisation']),
                'availability' => 'Lun-Ven 8h-16h',
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now()
            ]
        ];

        // Insertion des organisations
        foreach ($organizations as $org) {
            DB::table('organizations')->updateOrInsert(
                ['name' => $org['name']], 
                $org
            );
        }
        
        $this->command->info('✅ Organisations partenaires créées par secteur:');
        $this->command->info('   🏥 Santé: 2 organisations');
        $this->command->info('   👮 Sécurité/Justice: 2 organisations');
        $this->command->info('   ⚖️ Juridique: 2 organisations');
        $this->command->info('   🧠 Psychosocial: 2 organisations');
        $this->command->info('   🏠 Hébergement: 1 organisation');
        $this->command->info('   💼 Réinsertion économique: 1 organisation');
    }
}