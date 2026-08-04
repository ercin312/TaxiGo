<script setup>
import { ref, watch } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { formatDate, formatMoney } from '@/utils/format';

const props = defineProps({
    rides: {
        type: Object,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    statuses: {
        type: Array,
        default: () => [],
    },
});

const { t } = useI18n();

const search = ref(props.filters.search ?? '');
const status = ref(props.filters.status ?? '');
const tab = ref(props.filters.tab ?? 'active');

function applyFilters() {
    router.get(
        '/admin/rides',
        {
            search: search.value || undefined,
            status: status.value || undefined,
            tab: tab.value,
        },
        { preserveState: true, replace: true },
    );
}

watch([search, status], applyFilters);

function setTab(newTab) {
    tab.value = newTab;
    status.value = '';
    applyFilters();
}
</script>

<template>
    <Head :title="t('rides.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">{{ t('rides.title') }}</h1>
                <Link
                    href="/admin/rides/live-map"
                    class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600"
                >
                    {{ t('nav.liveMap') }}
                </Link>
            </div>
        </template>

        <div class="mb-6 flex flex-wrap items-center gap-4">
            <div class="flex rounded-lg border border-slate-200 bg-white p-1">
                <button
                    type="button"
                    class="rounded-md px-4 py-2 text-sm font-medium transition"
                    :class="tab === 'active' ? 'bg-amber-500 text-white' : 'text-slate-600 hover:bg-slate-50'"
                    @click="setTab('active')"
                >
                    {{ t('rides.active') }}
                </button>
                <button
                    type="button"
                    class="rounded-md px-4 py-2 text-sm font-medium transition"
                    :class="tab === 'history' ? 'bg-amber-500 text-white' : 'text-slate-600 hover:bg-slate-50'"
                    @click="setTab('history')"
                >
                    {{ t('rides.history') }}
                </button>
            </div>

            <input
                v-model="search"
                type="search"
                :placeholder="t('rides.searchPlaceholder')"
                class="w-full max-w-xs rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
            <select
                v-model="status"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            >
                <option value="">{{ t('rides.filterStatus') }} — {{ t('common.all') }}</option>
                <option v-for="s in statuses" :key="s" :value="s">{{ s.replace(/_/g, ' ') }}</option>
            </select>
        </div>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('rides.reference') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.passenger') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.driver') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('rides.pickup') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('dashboard.fare') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('rides.createdAt') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="ride in rides.data" :key="ride.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3">
                            <Link :href="`/admin/rides/${ride.id}`" class="font-medium text-amber-600 hover:underline">
                                {{ ride.reference }}
                            </Link>
                        </td>
                        <td class="px-6 py-3 text-slate-700">{{ ride.passenger?.name ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-700">{{ ride.driver?.user?.name ?? '—' }}</td>
                        <td class="max-w-xs truncate px-6 py-3 text-slate-600">{{ ride.pickup_address ?? '—' }}</td>
                        <td class="px-6 py-3">
                            <StatusBadge :status="ride.status" />
                        </td>
                        <td class="px-6 py-3 text-slate-700">
                            {{ formatMoney(ride.final_fare ?? ride.estimated_fare) }}
                        </td>
                        <td class="px-6 py-3 text-slate-500">{{ formatDate(ride.created_at) }}</td>
                    </tr>
                    <tr v-if="!rides.data.length">
                        <td colspan="7" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="rides.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="rides.links" />
            </div>
        </div>
    </AdminLayout>
</template>
