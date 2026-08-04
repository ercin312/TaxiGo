<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ForceHttps
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! config('taxigo.force_https', false)) {
            return $next($request);
        }

        if (! $request->secure() && ! app()->runningInConsole()) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'message' => 'HTTPS required.',
                ], 403);
            }

            return redirect()->secure($request->getRequestUri());
        }

        $response = $next($request);

        $response->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');

        return $response;
    }
}
