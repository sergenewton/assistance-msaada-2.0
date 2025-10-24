<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

/*
|--------------------------------------------------------------------------
| Console Routes
|--------------------------------------------------------------------------
|
| Ce fichier est l'endroit où vous pouvez définir toutes vos commandes
| de console personnalisées basées sur des Closures. Chaque Closure est
| liée à une instance de commande permettant une approche simple.
|
*/

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('reports:cleanup', function () {
    $this->info('Nettoyage des anciens signalements...');
    // Logique de nettoyage des rapports
    $this->info('Nettoyage terminé!');
})->purpose('Nettoyer les anciens signalements');

Artisan::command('users:verify-expired', function () {
    $this->info('Vérification des comptes utilisateurs expirés...');
    // Logique de vérification des comptes expirés
    $this->info('Vérification terminée!');
})->purpose('Vérifier et gérer les comptes utilisateurs expirés');