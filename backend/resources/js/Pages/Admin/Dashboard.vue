<script setup>
import { Head, Link } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { formatDate, formatMoney } from '@/utils/format';

defineProps({
    stats: {
        type: Object,
        required: true,
    },
    recent_rides: {
        type: Array,
        required: true,
    },
});

const { t } = useI18n();

const statCards = [
    { key: 'total_users', label: 'dashboard.totalUsers', color: 'bg-blue-500' },
    { key: 'total_passengers', label: 'dashboard.passengers', color: 'bg-indigo-500' },
    { key: 'total_drivers', label: 'dashboard.totalDrivers', color: 'bg-violet-500' },
    { key: 'pending_drivers', label: 'dashboard.pendingDrivers', color: 'bg-amber-500' },
    { key: 'online_drivers', label: 'dashboard.onlineDrivers', color: 'bg-emerald-500' },
    { key: 'total_rides', label: 'dashboard.totalRides', color: 'bg-cyan-500' },
    { key: 'active_rides', label: 'dashboard.activeRides', color: 'bg-orange-500' },
    { key: 'completed_rides_today', label: 'dashboard.completedToday', color: 'bg-teal-500' },
    { key: 'open_complaints', label: 'dashboard.openComplaints', color: 'bg-red-500' },
    { key: 'pending_withdrawals', label: 'dashboard.pendingWithdrawals', color: 'bg-pink-500' },
];
</script>

<template>
    <Head :title="t('dashboard.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('dashboard.title') }}</h1>
        </template>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5">
            <div
                v-for="card in statCards"
                :key="card.key"
                class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm"
            >
                <div class="flex items-stretch">
                    <div class="w-1.5" :class="card.color" />
                    <div class="flex-1 p-4">
                        <p class="text-sm text-slate-500">{{ t(card.label) }}</p>
                        <p class="mt-1 text-2xl font-bold text-slate-900">{{ stats[card.key] ?? 0 }}</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="mt-8 rounded-xl border border-slate-200 bg-white shadow-sm">
            <div class="border-b border-slate-200 px-6 py-4">
                <h2 class="text-lg font-semibold text-slate-900">{{ t('dashboard.recentRides') }}</h2>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-slate-200 text-sm">
                    <thead class="bg-slate-50">
                        <tr>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.reference') }}</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.passenger') }}</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.driver') }}</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.fare') }}</th>
                            <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.date') }}</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200">
                        <tr v-for="ride in recent_rides" :key="ride.id" class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <Link :href="`/admin/rides/${ride.id}`" class="font-medium text-amber-600 hover:underline">
                                    {{ ride.reference }}
                                </Link>
                            </td>
                            <td class="px-6 py-3 text-slate-700">{{ ride.passenger?.name ?? '—' }}</td>
                            <td class="px-6 py-3 text-slate-700">{{ ride.driver?.user?.name ?? '—' }}</td>
                            <td class="px-6 py-3">
                                <StatusBadge :status="ride.status" />
                            </td>
                            <td class="px-6 py-3 text-slate-700">
                                {{ formatMoney(ride.final_fare ?? ride.estimated_fare) }}
                            </td>
                            <td class="px-6 py-3 text-slate-500">{{ formatDate(ride.created_at) }}</td>
                        </tr>
                        <tr v-if="!recent_rides.length">
                            <td colspan="6" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </AdminLayout>
</template>
