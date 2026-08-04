<script setup>
import { ref, watch } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { formatDate } from '@/utils/format';

const props = defineProps({
    drivers: {
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

watch([search, status], () => {
    router.get(
        '/admin/drivers',
        { search: search.value || undefined, status: status.value || undefined },
        { preserveState: true, replace: true },
    );
});
</script>

<template>
    <Head :title="t('drivers.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('drivers.title') }}</h1>
        </template>

        <div class="mb-6 flex flex-wrap gap-4">
            <input
                v-model="search"
                type="search"
                :placeholder="t('drivers.searchPlaceholder')"
                class="w-full max-w-xs rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
            <select
                v-model="status"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            >
                <option value="">{{ t('drivers.filterStatus') }} — {{ t('common.all') }}</option>
                <option v-for="s in statuses" :key="s" :value="s">{{ s }}</option>
            </select>
        </div>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.name') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.phone') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('drivers.vehicle') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('drivers.rating') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('drivers.documents') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('drivers.online') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="driver in drivers.data" :key="driver.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-medium text-slate-900">{{ driver.user?.name ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ driver.user?.phone ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-600">
                            <span v-if="driver.vehicle">
                                {{ driver.vehicle.make }} {{ driver.vehicle.model }}
                                <span class="text-slate-400">({{ driver.vehicle.plate_number }})</span>
                            </span>
                            <span v-else>—</span>
                        </td>
                        <td class="px-6 py-3 text-slate-600">
                            {{ driver.rating_average ?? '—' }}
                            <span class="text-slate-400">({{ driver.rating_count ?? 0 }})</span>
                        </td>
                        <td class="px-6 py-3 text-slate-600">
                            {{ driver.verified_documents_count ?? 0 }}/{{ driver.documents_count ?? 0 }}
                        </td>
                        <td class="px-6 py-3">
                            <StatusBadge :status="driver.approval_status" />
                        </td>
                        <td class="px-6 py-3">
                            <span
                                class="inline-flex h-2.5 w-2.5 rounded-full"
                                :class="driver.is_online ? 'bg-emerald-500' : 'bg-slate-300'"
                            />
                            {{ driver.is_online ? t('drivers.online') : t('drivers.offline') }}
                        </td>
                        <td class="px-6 py-3 text-right">
                            <Link
                                :href="`/admin/drivers/${driver.id}`"
                                class="rounded-md px-3 py-1.5 text-xs font-medium text-amber-600 hover:bg-amber-50"
                            >
                                {{ t('common.view') }}
                            </Link>
                        </td>
                    </tr>
                    <tr v-if="!drivers.data.length">
                        <td colspan="8" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="drivers.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="drivers.links" />
            </div>
        </div>
    </AdminLayout>
</template>
