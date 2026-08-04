<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title') — {{ $appName ?? 'TaxiGo' }}</title>
    <style>
        :root {
            --ink: #0f172a;
            --muted: #475569;
            --accent: #f59e0b;
            --bg: #f8fafc;
            --card: #ffffff;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
            color: var(--ink);
            background: linear-gradient(180deg, #0f172a 0%, #1e293b 180px, var(--bg) 180px);
            line-height: 1.65;
        }
        header {
            max-width: 720px;
            margin: 0 auto;
            padding: 28px 20px 12px;
            color: #fff;
        }
        header a { color: #fde68a; text-decoration: none; font-weight: 600; }
        header h1 { margin: 8px 0 0; font-size: 1.75rem; letter-spacing: -0.02em; }
        main {
            max-width: 720px;
            margin: 0 auto 48px;
            padding: 24px 20px;
            background: var(--card);
            border-radius: 18px;
            box-shadow: 0 12px 40px rgba(15, 23, 42, 0.12);
        }
        h2 { margin-top: 1.75rem; font-size: 1.15rem; }
        p, li { color: var(--muted); }
        ul { padding-left: 1.2rem; }
        .meta { font-size: 0.9rem; color: #94a3b8; }
        footer {
            max-width: 720px;
            margin: 0 auto 40px;
            padding: 0 20px;
            font-size: 0.9rem;
            color: var(--muted);
        }
        footer a { color: #b45309; }
        .nav { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 10px; font-size: 0.9rem; }
    </style>
</head>
<body>
    <header>
        <a href="{{ url('/') }}">{{ $appName ?? 'TaxiGo' }}</a>
        <h1>@yield('heading')</h1>
        <div class="nav">
            <a href="{{ route('legal.privacy') }}">Gizlilik</a>
            <a href="{{ route('legal.terms') }}">Şartlar</a>
            <a href="{{ route('legal.support') }}">Destek</a>
            <a href="{{ route('legal.delete-account') }}">Hesap silme</a>
        </div>
    </header>
    <main>
        @yield('content')
    </main>
    <footer>
        © {{ date('Y') }} {{ $appName ?? 'TaxiGo' }} ·
        <a href="mailto:{{ $supportEmail ?? 'destek@taxigo.app' }}">{{ $supportEmail ?? 'destek@taxigo.app' }}</a>
    </footer>
</body>
</html>
