<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Assets\Css;
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentAsset;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

/**
 * The admin dashboard, served from the same application as the API.
 *
 * One codebase over one schema: the panel reads the very rows the mobile apps
 * write, so an approval here is visible to a charity on its next request with
 * no syncing of any kind.
 *
 * It signs in against the `admin` guard (the admins table). Donors and
 * charities never reach it — they authenticate with Sanctum tokens on /api.
 */
class AdminPanelProvider extends PanelProvider
{
    public function boot(): void
    {
        // Served from public/ rather than compiled through Vite: the panel is
        // the only thing that uses it, and this keeps the backend free of a
        // node build step.
        FilamentAsset::register([
            Css::make('naamaty-panel', asset('css/naamaty-panel.css')),
        ]);
    }

    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->authGuard('admin')
            ->brandName('نعمتي')
            ->favicon(asset('images/logo.png'))
            // Matched to the mobile app rather than the dashboard prototype:
            // the deep forest green of its headers and primary buttons, on the
            // same warm stone neutral. One identity across app and panel.
            ->colors([
                'primary' => Color::hex('#1F4A34'),
                'success' => Color::hex('#3E8E4F'),
                'warning' => Color::hex('#D9822B'),
                'danger' => Color::hex('#B3452C'),
                'info' => Color::hex('#1F4A34'),
                'gray' => Color::Stone,
            ])
            ->font('Cairo')
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
