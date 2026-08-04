<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>TaxiGo — Yolculuk Takibi</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <style>
        :root { --ink:#0f172a; --muted:#64748b; --accent:#0ea5e9; --bg:#f8fafc; }
        * { box-sizing: border-box; }
        body { margin:0; font-family: "Segoe UI", system-ui, sans-serif; background:var(--bg); color:var(--ink); }
        header { padding:16px 20px; background:linear-gradient(135deg,#0ea5e9,#0369a1); color:#fff; }
        header h1 { margin:0; font-size:1.25rem; letter-spacing:.02em; }
        header p { margin:4px 0 0; opacity:.9; font-size:.9rem; }
        .panel { padding:16px 20px; display:grid; gap:8px; }
        .label { color:var(--muted); font-size:.75rem; text-transform:uppercase; letter-spacing:.06em; }
        .value { font-size:1rem; font-weight:600; }
        #map { height:55vh; min-height:280px; width:100%; border-top:1px solid #e2e8f0; }
        .status { display:inline-block; padding:4px 10px; border-radius:999px; background:#e0f2fe; color:#0369a1; font-size:.85rem; font-weight:600; }
        .error { padding:24px; color:#b91c1c; }
    </style>
</head>
<body>
<header>
    <h1>TaxiGo</h1>
    <p>Canlı yolculuk paylaşımı · {{ $reference }}</p>
</header>
<div class="panel" id="info">
    <div><div class="label">Durum</div><div class="value"><span class="status" id="status">Yükleniyor…</span></div></div>
    <div><div class="label">Alış</div><div class="value" id="pickup">—</div></div>
    <div><div class="label">Varış</div><div class="value" id="dropoff">—</div></div>
    <div><div class="label">Sürücü</div><div class="value" id="driver">—</div></div>
</div>
<div id="map"></div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
(() => {
  const apiUrl = @json($apiUrl);
  const map = L.map('map').setView([41.01, 28.97], 12);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap'
  }).addTo(map);

  let pickupMarker, dropoffMarker, driverMarker;

  function setMarker(ref, lat, lng, label, color) {
    if (lat == null || lng == null) return ref;
    const icon = L.divIcon({
      className: '',
      html: `<div style="background:${color};width:14px;height:14px;border-radius:50%;border:2px solid #fff;box-shadow:0 1px 4px rgba(0,0,0,.35)"></div>`,
      iconSize: [14,14], iconAnchor: [7,7]
    });
    if (ref) { ref.setLatLng([lat, lng]); return ref; }
    return L.marker([lat, lng], {icon}).addTo(map).bindPopup(label);
  }

  async function refresh() {
    try {
      const res = await fetch(apiUrl, { headers: { 'Accept': 'application/json' } });
      if (!res.ok) throw new Error('unavailable');
      const data = await res.json();
      const ride = data.ride || {};
      document.getElementById('status').textContent = ride.status || '—';
      document.getElementById('pickup').textContent = ride.pickup_address || '—';
      document.getElementById('dropoff').textContent = ride.dropoff_address || '—';
      const d = ride.driver;
      document.getElementById('driver').textContent = d
        ? [d.name, d.vehicle && (d.vehicle.plate || [d.vehicle.make, d.vehicle.model].filter(Boolean).join(' '))].filter(Boolean).join(' · ')
        : 'Atanmadı';

      pickupMarker = setMarker(pickupMarker, +ride.pickup_latitude, +ride.pickup_longitude, 'Alış', '#0ea5e9');
      dropoffMarker = setMarker(dropoffMarker, +ride.dropoff_latitude, +ride.dropoff_longitude, 'Varış', '#16a34a');
      const loc = ride.driver_location;
      if (loc && loc.latitude && loc.longitude) {
        driverMarker = setMarker(driverMarker, +loc.latitude, +loc.longitude, 'Sürücü', '#f59e0b');
      }

      const pts = [];
      if (ride.pickup_latitude) pts.push([+ride.pickup_latitude, +ride.pickup_longitude]);
      if (ride.dropoff_latitude) pts.push([+ride.dropoff_latitude, +ride.dropoff_longitude]);
      if (loc && loc.latitude) pts.push([+loc.latitude, +loc.longitude]);
      if (pts.length) map.fitBounds(pts, { padding: [40, 40] });
    } catch (e) {
      document.getElementById('status').textContent = 'Bağlantı hatası';
    }
  }

  refresh();
  setInterval(refresh, 8000);
})();
</script>
</body>
</html>
