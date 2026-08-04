<script setup>
import { ref, watch } from 'vue';
import { Head, Link, router, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import Modal from '@/Components/Modal.vue';
import { formatDate } from '@/utils/format';

const props = defineProps({
    complaints: {
        type: Object,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
});

const { t } = useI18n();

const status = ref(props.filters.status ?? '');
const resolvingComplaint = ref(null);
const showResolveModal = ref(false);

const resolveForm = useForm({
    status: 'resolved',
    admin_response: '',
});

const statusOptions = ['open', 'urgent', 'in_progress', 'resolved', 'closed'];

watch(status, () => {
    router.get(
        '/admin/complaints',
        { status: status.value || undefined },
        { preserveState: true, replace: true },
    );
});

function openResolve(complaint) {
    resolvingComplaint.value = complaint;
    resolveForm.status = complaint.status === 'open' || complaint.status === 'urgent' ? 'resolved' : complaint.status;
    resolveForm.admin_response = complaint.admin_response ?? '';
    showResolveModal.value = true;
}

function submitResolve() {
    resolveForm.put(`/admin/complaints/${resolvingComplaint.value.id}`, {
        onSuccess: () => {
            showResolveModal.value = false;
            resolvingComplaint.value = null;
        },
    });
}
</script>

<template>
    <Head :title="t('complaints.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('complaints.title') }}</h1>
        </template>

        <div class="mb-6">
            <select
                v-model="status"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            >
                <option value="">{{ t('complaints.filterStatus') }} — {{ t('common.all') }}</option>
                <option v-for="s in statusOptions" :key="s" :value="s">{{ s.replace(/_/g, ' ') }}</option>
            </select>
        </div>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('complaints.subject') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('complaints.user') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('complaints.ride') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.date') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="complaint in complaints.data" :key="complaint.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3">
                            <p class="font-medium text-slate-900">{{ complaint.subject }}</p>
                            <p class="max-w-xs truncate text-slate-500">{{ complaint.description }}</p>
                        </td>
                        <td class="px-6 py-3 text-slate-700">{{ complaint.user?.name ?? '—' }}</td>
                        <td class="px-6 py-3">
                            <Link
                                v-if="complaint.ride"
                                :href="`/admin/rides/${complaint.ride.id}`"
                                class="text-amber-600 hover:underline"
                            >
                                {{ complaint.ride.reference }}
                            </Link>
                            <span v-else>—</span>
                        </td>
                        <td class="px-6 py-3">
                            <StatusBadge :status="complaint.status" />
                        </td>
                        <td class="px-6 py-3 text-slate-500">{{ formatDate(complaint.created_at) }}</td>
                        <td class="px-6 py-3 text-right">
                            <button
                                type="button"
                                class="rounded-md px-3 py-1.5 text-xs font-medium text-amber-600 hover:bg-amber-50"
                                @click="openResolve(complaint)"
                            >
                                {{ t('complaints.resolveComplaint') }}
                            </button>
                        </td>
                    </tr>
                    <tr v-if="!complaints.data.length">
                        <td colspan="6" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="complaints.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="complaints.links" />
            </div>
        </div>

        <Modal
            :show="showResolveModal"
            :title="t('complaints.resolveComplaint')"
            @close="showResolveModal = false"
        >
            <form class="space-y-4" @submit.prevent="submitResolve">
                <div>
                    <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('complaints.updateStatus') }}</label>
                    <select
                        v-model="resolveForm.status"
                        class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                    >
                        <option v-for="s in statusOptions" :key="s" :value="s">{{ s.replace(/_/g, ' ') }}</option>
                    </select>
                </div>
                <div>
                    <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('complaints.adminResponse') }}</label>
                    <textarea
                        v-model="resolveForm.admin_response"
                        rows="4"
                        class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                    />
                </div>
                <div class="flex justify-end gap-2">
                    <button type="button" class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100" @click="showResolveModal = false">
                        {{ t('common.cancel') }}
                    </button>
                    <button type="submit" class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600" :disabled="resolveForm.processing">
                        {{ t('common.save') }}
                    </button>
                </div>
            </form>
        </Modal>
    </AdminLayout>
</template>
