<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Schema;
use Doctrine\DBAL\Types\Type;
use Doctrine\DBAL\Types\StringType;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
         // Correction pour le type ENUM non reconnu
        if (!Type::hasType('enum')) {
            Type::addType('enum', StringType::class);
        }

        Schema::defaultStringLength(191);
    }
}