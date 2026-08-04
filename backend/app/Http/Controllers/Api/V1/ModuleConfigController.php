<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\FeatureModuleService;
use Illuminate\Http\JsonResponse;

class ModuleConfigController extends Controller
{
    public function __construct(
        protected FeatureModuleService $modules,
    ) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'modules' => $this->modules->flags(),
        ]);
    }
}
