<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo($request)
    {
        // For API, return null so framework returns 401 JSON when expectsJson()
        if ($request->expectsJson()) {
            return null;
        }
        return route('login');
    }
}
