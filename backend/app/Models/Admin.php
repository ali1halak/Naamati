<?php

namespace App\Models;

use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Admin extends Authenticatable implements FilamentUser
{
    use HasApiTokens;

    /**
     * Everyone in this table is an admin — the row existing is the permission.
     * Accounts are created from the server with `php artisan admin:create`,
     * never through a public sign-up.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        return true;
    }

    protected $fillable = ['name', 'email', 'password'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    public function charityStatusLogs()
    {
        return $this->hasMany(CharityStatusLog::class);
    }
}
