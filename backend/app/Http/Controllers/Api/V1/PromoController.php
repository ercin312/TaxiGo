<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\PromoCode;
use App\Services\FareCalculatorService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function __construct(
        protected FareCalculatorService $fareCalculator,
    ) {}

    public function validateCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => ['required', 'string'],
            'fare' => ['required', 'numeric', 'min:0'],
        ]);

        $promoCode = PromoCode::query()
            ->where('code', strtoupper($validated['code']))
            ->first();

        if (! $promoCode || ! $promoCode->isValid()) {
            return response()->json(['message' => 'Invalid or expired promo code.'], 422);
        }

        $userUsageCount = $promoCode->usages()
            ->where('user_id', $request->user()->id)
            ->count();

        if ($userUsageCount >= $promoCode->per_user_limit) {
            return response()->json(['message' => 'Promo code usage limit reached.'], 422);
        }

        $discount = $this->fareCalculator->calculateDiscount(
            (float) $validated['fare'],
            $promoCode,
        );

        return response()->json([
            'valid' => true,
            'promo_code' => $promoCode,
            'discount' => round($discount, 2),
            'final_fare' => round(max((float) $validated['fare'] - $discount, 0), 2),
        ]);
    }
}
