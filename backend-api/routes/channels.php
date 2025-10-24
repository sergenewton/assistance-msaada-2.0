<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Ici vous pouvez enregistrer toutes les chaînes de diffusion d'événements
| pour votre application. Les callbacks d'autorisation données seront
| utilisés pour vérifier si un utilisateur authentifié peut écouter le canal.
|
*/

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('reports.{reportId}', function ($user, $reportId) {
    // Vérifier si l'utilisateur peut accéder aux mises à jour de ce signalement
    return $user->can('view', \App\Infrastructure\Persistence\Eloquent\Models\Report::find($reportId));
});

Broadcast::channel('admin.reports', function ($user) {
    // Canal pour les administrateurs seulement
    return $user->hasRole('admin');
});

Broadcast::channel('user.{userId}.notifications', function ($user, $userId) {
    // Canal pour les notifications personnelles
    return (int) $user->id === (int) $userId;
});