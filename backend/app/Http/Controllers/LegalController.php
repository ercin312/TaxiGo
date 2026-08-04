<?php

namespace App\Http\Controllers;

use Illuminate\View\View;

class LegalController extends Controller
{
    public function privacy(): View
    {
        return view('legal.privacy', [
            'appName' => config('app.name', 'TaxiGo'),
            'supportEmail' => config('taxigo.support_email', 'destek@taxigo.app'),
            'updatedAt' => '4 Ağustos 2026',
        ]);
    }

    public function terms(): View
    {
        return view('legal.terms', [
            'appName' => config('app.name', 'TaxiGo'),
            'supportEmail' => config('taxigo.support_email', 'destek@taxigo.app'),
            'updatedAt' => '4 Ağustos 2026',
        ]);
    }

    public function support(): View
    {
        return view('legal.support', [
            'appName' => config('app.name', 'TaxiGo'),
            'supportEmail' => config('taxigo.support_email', 'destek@taxigo.app'),
        ]);
    }

    public function deleteAccount(): View
    {
        return view('legal.delete-account', [
            'appName' => config('app.name', 'TaxiGo'),
            'supportEmail' => config('taxigo.support_email', 'destek@taxigo.app'),
        ]);
    }
}
