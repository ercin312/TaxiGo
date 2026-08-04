<script setup>
import { Head, Link } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import { formatDate } from '@/utils/format';

defineProps({
    notifications: {
        type: Object,
        required: true,
    },
    roles: {
        type: Array,
        default: () => [],
    },
});

const { t } = useI18n();
</script>

<template>
    <Head :title="t('notifications.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">{{ t('notifications.title') }}</h1>
                <Link
                    href="/admin/notifications/create"
                    class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600"
                >
                    {{ t('notifications.create') }}
                </Link>
            </div>
        </template>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <div class="border-b border-slate-200 px-6 py-4">
                <h2 class="font-semibold text-slate-900">{{ t('notifications.list') }}</h2>
            </div>
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('notifications.notificationTitle') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('notifications.body') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('notifications.type') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('complaints.user') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('notifications.sentAt') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="notification in notifications.data" :key="notification.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-medium text-slate-900">{{ notification.title }}</td>
                        <td class="max-w-xs truncate px-6 py-3 text-slate-600">{{ notification.body }}</td>
                        <td class="px-6 py-3 capitalize text-slate-600">{{ notification.type }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ notification.user?.name ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-500">{{ formatDate(notification.created_at) }}</td>
                    </tr>
                    <tr v-if="!notifications.data.length">
                        <td colspan="5" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="notifications.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="notifications.links" />
            </div>
        </div>
    </AdminLayout>
</template>
