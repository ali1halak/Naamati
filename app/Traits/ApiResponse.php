<?php

namespace App\Traits;

trait ApiResponse
{
    protected function ok(mixed $data = null, ?string $message = null, int $code = 200)
    {
        return response()->json([
            'success' => true,
            'data'    => $data,
            'message' => $message,
        ], $code);
    }

    protected function fail(string $message, int $code = 400, mixed $errors = null)
    {
        return response()->json([
            'success' => false,
            'data'    => null,
            'message' => $message,
            'errors'  => $errors,
        ], $code);
    }
}