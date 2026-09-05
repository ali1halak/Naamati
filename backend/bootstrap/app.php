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
        // Runs before authentication so an unauthenticated request is answered
        // with a 401 envelope instead of a redirect to a non-existent route.
        $middleware->api(prepend: [
            \App\Http\Middleware\ForceJsonResponse::class,
        ]);

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
                    'message' => 'فشل التحقق من البيانات',
                    'errors'  => $e->errors(),
                ], 422),

                $e instanceof \Illuminate\Auth\AuthenticationException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'يجب تسجيل الدخول أولاً',
                    'errors'  => null,
                ], 401),

                $e instanceof \Illuminate\Auth\Access\AuthorizationException,
                $e instanceof \Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'ليس لديك صلاحية لهذا الإجراء',
                    'errors'  => null,
                ], 403),

                $e instanceof \Illuminate\Database\Eloquent\ModelNotFoundException,
                $e instanceof \Symfony\Component\HttpKernel\Exception\NotFoundHttpException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'العنصر المطلوب غير موجود',
                    'errors'  => null,
                ], 404),

                $e instanceof \Illuminate\Http\Exceptions\ThrottleRequestsException => response()->json([
                    'success' => false,
                    'data'    => null,
                    'message' => 'محاولات كثيرة جداً، انتظر قليلاً ثم أعد المحاولة',
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
                    'message' => config('app.debug') ? $e->getMessage() : 'حدث خطأ في الخادم',
                    'errors'  => null,
                ], 500),
            };
        });
    })->create();