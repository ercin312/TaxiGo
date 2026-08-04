<script setup>
import { ref, watch } from 'vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import { formatDate } from '@/utils/format';

const props = defineProps({
    users: {
        type: Object,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    roles: {
        type: Array,
        default: () => [],
    },
});

const { t } = useI18n();

const search = ref(props.filters.search ?? '');
const role = ref(props.filters.role ?? '');

watch([search, role], () => {
    router.get(
        '/admin/users',
        { search: search.value || undefined, role: role.value || undefined },
        { preserveState: true, replace: true },
    );
});

function toggleActive(user) {
    if (!user.is_active) {
        router.put(`/admin/users/${user.id}`, { is_active: true });
        return;
    }
    if (confirm(t('users.deactivateConfirm'))) {
        router.delete(`/admin/users/${user.id}`);
    }
}
</script>

<template>
    <Head :title="t('users.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('users.title') }}</h1>
        </template>

        <div class="mb-6 flex flex-wrap gap-4">
            <input
                v-model="search"
                type="search"
                :placeholder="t('users.searchPlaceholder')"
                class="w-full max-w-xs rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
            <select
                v-model="role"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            >
                <option value="">{{ t('users.filterRole') }} — {{ t('common.all') }}</option>
                <option v-for="r in roles" :key="r" :value="r">{{ r }}</option>
            </select>
        </div>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.name') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.email') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.phone') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.role') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('users.isActive') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.date') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="user in users.data" :key="user.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-medium text-slate-900">{{ user.name }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ user.email ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ user.phone ?? '—' }}</td>
                        <td class="px-6 py-3 capitalize text-slate-600">{{ user.role }}</td>
                        <td class="px-6 py-3">
                            <StatusBadge :status="user.is_active ? 'active' : 'inactive'" />
                        </td>
                        <td class="px-6 py-3 text-slate-500">{{ formatDate(user.created_at) }}</td>
                        <td class="px-6 py-3 text-right">
                            <div class="flex items-center justify-end gap-2">
                                <Link
                                    :href="`/admin/users/${user.id}`"
                                    class="rounded-md px-3 py-1.5 text-xs font-medium text-amber-600 hover:bg-amber-50"
                                >
                                    {{ t('common.view') }}
                                </Link>
                                <button
                                    v-if="user.role !== 'admin'"
                                    type="button"
                                    class="rounded-md px-3 py-1.5 text-xs font-medium"
                                    :class="
                                        user.is_active
                                            ? 'text-red-600 hover:bg-red-50'
                                            : 'text-emerald-600 hover:bg-emerald-50'
                                    "
                                    @click="toggleActive(user)"
                                >
                                    {{ user.is_active ? t('common.deactivate') : t('common.activate') }}
                                </button>
                            </div>
                        </td>
                    </tr>
                    <tr v-if="!users.data.length">
                        <td colspan="7" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="users.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="users.links" />
            </div>
        </div>
    </AdminLayout>
</template>
