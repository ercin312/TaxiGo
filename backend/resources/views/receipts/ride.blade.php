<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $receipt['receipt_number'] }}</title>
    <style>
        :root { color-scheme: light; }
        body { font-family: Georgia, "Times New Roman", serif; margin: 0; background: #f3f1ec; color: #0b1220; }
        .sheet { max-width: 640px; margin: 24px auto; background: #fff; padding: 32px; border-radius: 16px; box-shadow: 0 10px 30px rgba(11,18,32,.08); }
        h1 { margin: 0 0 4px; font-size: 28px; letter-spacing: .02em; }
        .muted { color: #5b6475; font-size: 13px; }
        .row { display: flex; justify-content: space-between; gap: 16px; margin: 8px 0; }
        .label { color: #5b6475; }
        .value { font-weight: 600; text-align: right; }
        .divider { height: 1px; background: #e8e4dc; margin: 18px 0; }
        .total { font-size: 22px; font-weight: 800; }
        .badge { display: inline-block; background: #0b1220; color: #f5b400; padding: 4px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; }
        @media print {
            body { background: #fff; }
            .sheet { box-shadow: none; margin: 0; border-radius: 0; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>
<div class="sheet">
    <div class="no-print" style="margin-bottom:16px;">
        <button onclick="window.print()" style="background:#0b1220;color:#f5b400;border:0;padding:10px 16px;border-radius:10px;font-weight:700;cursor:pointer;">Print / Save PDF</button>
    </div>
    <div class="row" style="align-items:flex-start;">
        <div>
            <h1>{{ $receipt['company']['name'] }}</h1>
            @if(!empty($receipt['company']['address']))
                <div class="muted">{{ $receipt['company']['address'] }}</div>
            @endif
            @if(!empty($receipt['company']['tax_id']))
                <div class="muted">Tax ID: {{ $receipt['company']['tax_id'] }}</div>
            @endif
            @if(!empty($receipt['company']['email']))
                <div class="muted">{{ $receipt['company']['email'] }}</div>
            @endif
        </div>
        <div style="text-align:right;">
            <span class="badge">E-RECEIPT</span>
            <div style="margin-top:8px;font-weight:700;">{{ $receipt['receipt_number'] }}</div>
            <div class="muted">{{ \Illuminate\Support\Carbon::parse($receipt['issued_at'])->format('Y-m-d H:i') }}</div>
        </div>
    </div>

    <div class="divider"></div>

    <div class="row"><span class="label">Trip</span><span class="value">{{ $receipt['ride']['reference'] }}</span></div>
    <div class="row"><span class="label">Completed</span><span class="value">{{ $receipt['ride']['completed_at'] ? \Illuminate\Support\Carbon::parse($receipt['ride']['completed_at'])->format('Y-m-d H:i') : '—' }}</span></div>
    <div class="row"><span class="label">From</span><span class="value">{{ $receipt['ride']['pickup_address'] }}</span></div>
    <div class="row"><span class="label">To</span><span class="value">{{ $receipt['ride']['dropoff_address'] }}</span></div>
    <div class="row"><span class="label">Distance</span><span class="value">{{ number_format($receipt['ride']['distance_km'], 1) }} km</span></div>
    <div class="row"><span class="label">Duration</span><span class="value">{{ $receipt['ride']['duration_minutes'] }} min</span></div>
    <div class="row"><span class="label">Payment</span><span class="value">{{ strtoupper($receipt['ride']['payment_method']) }}</span></div>

    <div class="divider"></div>

    <div class="row"><span class="label">Passenger</span><span class="value">{{ $receipt['passenger']['name'] ?? '—' }}</span></div>
    <div class="row"><span class="label">Driver</span><span class="value">{{ $receipt['driver']['name'] ?? '—' }}</span></div>
    @if(!empty($receipt['driver']['vehicle_plate']))
        <div class="row"><span class="label">Vehicle</span><span class="value">{{ $receipt['driver']['vehicle_plate'] }} {{ $receipt['driver']['vehicle_model'] ? '· '.$receipt['driver']['vehicle_model'] : '' }}</span></div>
    @endif

    <div class="divider"></div>

    <div class="row"><span class="label">Subtotal</span><span class="value">{{ number_format($receipt['amounts']['subtotal'], 2) }} {{ $receipt['amounts']['currency'] }}</span></div>
    @if($receipt['amounts']['discount'] > 0)
        <div class="row"><span class="label">Discount{{ $receipt['amounts']['promo_code'] ? ' ('.$receipt['amounts']['promo_code'].')' : '' }}</span><span class="value">-{{ number_format($receipt['amounts']['discount'], 2) }} {{ $receipt['amounts']['currency'] }}</span></div>
    @endif
    <div class="row total"><span>Total</span><span>{{ number_format($receipt['amounts']['total'], 2) }} {{ $receipt['amounts']['currency'] }}</span></div>

    <div class="divider"></div>
    @foreach($receipt['notes'] as $note)
        <div class="muted">{{ $note }}</div>
    @endforeach
</div>
</body>
</html>
