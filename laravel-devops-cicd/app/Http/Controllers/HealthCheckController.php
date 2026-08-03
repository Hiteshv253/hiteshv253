<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Cache;
use Exception;

class HealthCheckController extends Controller
{
    /**
     * Liveness Probe: Checks if the PHP application process is running.
     */
    public function liveness(): JsonResponse
    {
        return response()->json([
            'status' => 'UP',
            'timestamp' => now()->toIso8601String(),
            'service' => 'laravel-app-api'
        ], 200);
    }

    /**
     * Readiness Probe: Checks system dependencies (Database, Redis, Cache) 
     * to ensure the application is ready to accept user requests.
     */
    public function readiness(): JsonResponse
    {
        $checks = [
            'database' => false,
            'redis' => false,
            'cache' => false,
        ];
        
        $statusCode = 200;

        // 1. Verify Database Connection
        try {
            DB::connection()->getPdo();
            $checks['database'] = true;
        } catch (Exception $e) {
            $statusCode = 503;
            $checks['database'] = 'ERROR: ' . $e->getMessage();
        }

        // 2. Verify Redis Connection
        try {
            $redisConnection = Redis::connection();
            $redisConnection->ping();
            $checks['redis'] = true;
        } catch (Exception $e) {
            $statusCode = 503;
            $checks['redis'] = 'ERROR: ' . $e->getMessage();
        }

        // 3. Verify Cache driver
        try {
            Cache::put('healthcheck_ping', 'pong', 10);
            if (Cache::get('healthcheck_ping') === 'pong') {
                $checks['cache'] = true;
            }
        } catch (Exception $e) {
            $statusCode = 503;
            $checks['cache'] = 'ERROR: ' . $e->getMessage();
        }

        return response()->json([
            'status' => $statusCode === 200 ? 'READY' : 'DOWN',
            'timestamp' => now()->toIso8601String(),
            'checks' => $checks
        ], $statusCode);
    }
}
