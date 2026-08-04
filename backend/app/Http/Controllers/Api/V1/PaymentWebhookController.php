<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Services\CardPaymentService;
use App\Services\FeatureModuleService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentWebhookController extends Controller
{
    public function __construct(
        protected CardPaymentService $cardPayment,
        protected FeatureModuleService $modules,
    ) {}

    /**
     * iyzico / generic card callback — marks payment captured when module enabled.
     */
    public function iyzicoCallback(Request $request): JsonResponse
    {
        if ($this->modules->disabled('card_payments')) {
            return response()->json(['message' => 'Card payments module is disabled.'], 403);
        }

        $token = (string) $request->input('token', $request->input('paymentId', ''));
        $conversationId = (string) $request->input('conversationId', '');
        $rideId = null;

        if (preg_match('/ride-(\d+)/', $conversationId, $m)) {
            $rideId = (int) $m[1];
        } elseif ($request->filled('basketId')) {
            $ride = Ride::query()->where('reference', $request->input('basketId'))->first();
            $rideId = $ride?->id;
        }

        if (! $rideId) {
            Log::warning('iyzico callback without ride', $request->all());

            return response()->json(['message' => 'Ride not found for payment callback.'], 404);
        }

        $ride = Ride::query()->findOrFail($rideId);
        $reference = $token !== '' ? $token : ('IYZ-CB-'.$ride->id);

        $this->cardPayment->markCaptured($ride, $reference, [
            'callback' => true,
            'payload_keys' => array_keys($request->all()),
        ]);

        return response()->json([
            'message' => 'Payment marked as captured.',
            'ride_id' => $ride->id,
            'payment_reference' => $reference,
        ]);
    }
}
