<script setup>
import { onMounted, onUnmounted, ref, watch } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import L from 'leaflet';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import StatusBadge from '@/Components/StatusBadge.vue';

const props = defineProps({
    rides: {
        type: Array,
        default: () => [],
    },
    onlineDrivers: {
        type: Array,
        default: () => [],
    },
});

const { t } = useI18n();

const mapContainer = ref(null);
let map = null;
let markersLayer = null;
let refreshInterval = null;

const defaultCenter = [41.0082, 28.9784];

function initMap() {
    if (!mapContainer.value || map) return;

    map = L.map(mapContainer.value).setView(defaultCenter, 12);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors',
        maxZoom: 19,
    }).addTo(map);

    markersLayer = L.layerGroup().addTo(map);
    updateMarkers();
}

function rideIcon(color) {
    return L.divIcon({
        className: '',
        html: `<div style="background:${color};width:14px;height:14px;border-radius:50%;border:2px solid white;box-shadow:0 1px 4px rgba(0,0,0,.4)"></div>`,
        iconSize: [14, 14],
        iconAnchor: [7, 7],
    });
}

function updateMarkers() {
    if (!markersLayer) return;
    markersLayer.clearLayers();

    const bounds = [];

    props.rides.forEach((ride) => {
        if (ride.pickup_latitude && ride.pickup_longitude) {
            const lat = Number(ride.pickup_latitude);
            const lng = Number(ride.pickup_longitude);
            bounds.push([lat, lng]);
            const marker = L.marker([lat, lng], { icon: rideIcon('#f59e0b') });
            marker.bindPopup(
                `<strong>${ride.reference}</strong><br>${ride.pickup_address ?? ''}<br><em>${ride.status}</em>`,
            );
            markersLayer.addLayer(marker);
        }

        if (ride.dropoff_latitude && ride.dropoff_longitude) {
            const lat = Number(ride.dropoff_latitude);
            const lng = Number(ride.dropoff_longitude);
            bounds.push([lat, lng]);
            const marker = L.marker([lat, lng], { icon: rideIcon('#ef4444') });
            marker.bindPopup(`<strong>Dropoff</strong><br>${ride.dropoff_address ?? ''}`);
            markersLayer.addLayer(marker);
        }

        if (ride.driver?.current_latitude && ride.driver?.current_longitude) {
            const lat = Number(ride.driver.current_latitude);
            const lng = Number(ride.driver.current_longitude);
            bounds.push([lat, lng]);
            const marker = L.marker([lat, lng], { icon: rideIcon('#10b981') });
            marker.bindPopup(`<strong>${ride.driver.user?.name ?? 'Driver'}</strong>`);
            markersLayer.addLayer(marker);
        }
    });

    props.onlineDrivers.forEach((driver) => {
        if (!driver.current_latitude || !driver.current_longitude) return;
        const lat = Number(driver.current_latitude);
        const lng = Number(driver.current_longitude);
        bounds.push([lat, lng]);
        const marker = L.marker([lat, lng], { icon: rideIcon('#3b82f6') });
        marker.bindPopup(`<strong>${driver.user?.name ?? 'Driver'}</strong><br>Online`);
        markersLayer.addLayer(marker);
    });

    if (bounds.length) {
        map.fitBounds(bounds, { padding: [40, 40], maxZoom: 14 });
    }
}

function refresh() {
    router.reload({ only: ['rides', 'onlineDrivers'] });
}

onMounted(() => {
    initMap();
    refreshInterval = setInterval(refresh, 30000);
});

watch(() => [props.rides, props.onlineDrivers], updateMarkers, { deep: true });

onUnmounted(() => {
    if (refreshInterval) clearInterval(refreshInterval);
    if (map) {
        map.remove();
        map = null;
    }
});
</script>

<template>
    <Head :title="t('rides.liveMapTitle')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <div>
                    <Link href="/admin/rides" class="text-sm text-slate-500 hover:text-slate-700">
                        ← {{ t('rides.title') }}
                    </Link>
                    <h1 class="text-2xl font-bold text-slate-900">{{ t('rides.liveMapTitle') }}</h1>
                    <p class="text-sm text-slate-500">{{ t('rides.liveMapDescription') }}</p>
                </div>
                <button
                    type="button"
                    class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600"
                    @click="refresh"
                >
                    {{ t('rides.refreshMap') }}
                </button>
            </div>
        </template>

        <div class="mb-4 flex gap-4">
            <div class="rounded-lg border border-slate-200 bg-white px-4 py-3 shadow-sm">
                <p class="text-sm text-slate-500">{{ t('rides.activeRidesCount') }}</p>
                <p class="text-xl font-bold text-amber-600">{{ rides.length }}</p>
            </div>
            <div class="rounded-lg border border-slate-200 bg-white px-4 py-3 shadow-sm">
                <p class="text-sm text-slate-500">{{ t('rides.onlineDrivers') }}</p>
                <p class="text-xl font-bold text-blue-600">{{ onlineDrivers.length }}</p>
            </div>
        </div>

        <div class="mb-4 flex flex-wrap gap-4 text-xs text-slate-600">
            <span class="flex items-center gap-1.5"><span class="h-3 w-3 rounded-full bg-amber-500" /> Pickup</span>
            <span class="flex items-center gap-1.5"><span class="h-3 w-3 rounded-full bg-red-500" /> Dropoff</span>
            <span class="flex items-center gap-1.5"><span class="h-3 w-3 rounded-full bg-emerald-500" /> Ride driver</span>
            <span class="flex items-center gap-1.5"><span class="h-3 w-3 rounded-full bg-blue-500" /> Online driver</span>
        </div>

        <div ref="mapContainer" class="h-[calc(100vh-280px)] min-h-[400px] rounded-xl border border-slate-200 shadow-sm" />

        <div class="mt-6 rounded-xl border border-slate-200 bg-white shadow-sm">
            <div class="border-b border-slate-200 px-6 py-4">
                <h2 class="font-semibold text-slate-900">{{ t('rides.active') }}</h2>
            </div>
            <div class="divide-y divide-slate-100">
                <div
                    v-for="ride in rides"
                    :key="ride.id"
                    class="flex items-center justify-between px-6 py-3 hover:bg-slate-50"
                >
                    <div>
                        <Link :href="`/admin/rides/${ride.id}`" class="font-medium text-amber-600 hover:underline">
                            {{ ride.reference }}
                        </Link>
                        <p class="text-sm text-slate-500">{{ ride.pickup_address }}</p>
                    </div>
                    <StatusBadge :status="ride.status" />
                </div>
                <p v-if="!rides.length" class="px-6 py-8 text-center text-sm text-slate-500">
                    {{ t('common.noResults') }}
                </p>
            </div>
        </div>
    </AdminLayout>
</template>

<style>
.leaflet-container {
    z-index: 0;
    border-radius: 0.75rem;
}
</style>
