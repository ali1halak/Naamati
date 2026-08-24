<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'type'        => \App\Http\Middleware\EnsureUserType::class,
            'admin.token' => \App\Http\Middleware\AdminToken::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (\Throwable $e, \Illuminate\Http\Request $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            return match (true) {
                $e instanceof \Illuminate\Validation\ValidationException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'Validation failed',
                    'errors'  => $e->errors(),
                ], 422),

                $e instanceof \Illuminate\Auth\AuthenticationException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'Unauthenticated',
                    'errors'  => null,
                ], 401),

                $e instanceof \Illuminate\Auth\Access\AuthorizationException,
                $e instanceof \Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'Forbidden',
                    'errors'  => null,
                ], 403),

                $e instanceof \Illuminate\Database\Eloquent\ModelNotFoundException,
                $e instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'Not found',
                    'errors'  => null,
                ], 404),

                $e instanceof \Illuminate\Http\Exceptions\ThrottleRequestsException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'Too many requests',
                    'errors'  => null,
                ], 429),

                $e instanceof \Symfony\Component\HttpKernel\Exception\HttpExceptionInterface => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => $e->getMessage() ?: 'Error',
                    'errors'  => null,
                ], $e->getStatusCode()),

                default => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => config('app.debug') ? $e->getMessage() : 'Server error',
                    'errors'  => null,
                ], 500),
            };
        });
    })->create();