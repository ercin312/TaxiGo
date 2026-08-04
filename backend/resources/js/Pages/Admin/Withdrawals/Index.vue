<script setup>
import { ref, watch } from 'vue';
import { Head, router } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import Modal from '@/Components/Modal.vue';
import { formatDate, formatMoney } from '@/utils/format';

const props = defineProps({
    withdrawals: {
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
const actionWithdrawal = ref(null);
const showApproveModal = ref(false);
const showRejectModal = ref(false);
const adminNote = ref('');
const rejectionReason = ref('');

const statusOptions = ['pending', 'approved', 'rejected'];

watch(status, () => {
    router.get(
        '/admin/withdrawals',
        { status: status.value || undefined },
        { preserveState: true, replace: true },
    );
});

function openApprove(withdrawal) {
    actionWithdrawal.value = withdrawal;
    adminNote.value = '';
    showApproveModal.value = true;
}

function openReject(withdrawal) {
    actionWithdrawal.value = withdrawal;
    rejectionReason.value = '';
    showRejectModal.value = true;
}

function approve() {
    router.post(`/admin/withdrawals/${actionWithdrawal.value.id}/approve`, {
        admin_note: adminNote.value || undefined,
    }, {
        onSuccess: () => {
            showApproveModal.value = false;
        },
    });
}

function reject() {
    router.post(`/admin/withdrawals/${actionWithdrawal.value.id}/reject`, {
        rejection_reason: rejectionReason.value,
    }, {
        onSuccess: () => {
            showRejectModal.value = false;
        },
    });
}
</script>

<template>
    <Head :title="t('withdrawals.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('withdrawals.title') }}</h1>
        </template>

        <div class="mb-6">
            <select
                v-model="status"
                class="rounded-lg border border-slate-300 px-4 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            >
                <option value="">{{ t('withdrawals.filterStatus') }} — {{ t('common.all') }}</option>
                <option v-for="s in statusOptions" :key="s" :value="s">{{ s }}</option>
            </select>
        </div>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('withdrawals.driver') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.amount') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('withdrawals.bankName') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('withdrawals.accountHolder') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.date') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="withdrawal in withdrawals.data" :key="withdrawal.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-medium text-slate-900">
                            {{ withdrawal.driver?.user?.name ?? '—' }}
                        </td>
                        <td class="px-6 py-3 font-medium text-slate-900">{{ formatMoney(withdrawal.amount) }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ withdrawal.bank_name ?? '—' }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ withdrawal.account_holder ?? '—' }}</td>
                        <td class="px-6 py-3">
                            <StatusBadge :status="withdrawal.status" />
                        </td>
                        <td class="px-6 py-3 text-slate-500">{{ formatDate(withdrawal.created_at) }}</td>
                        <td class="px-6 py-3 text-right">
                            <template v-if="withdrawal.status === 'pending'">
                                <button
                                    type="button"
                                    class="mr-2 rounded-md px-3 py-1.5 text-xs font-medium text-emerald-600 hover:bg-emerald-50"
                                    @click="openApprove(withdrawal)"
                                >
                                    {{ t('common.approve') }}
                                </button>
                                <button
                                    type="button"
                                    class="rounded-md px-3 py-1.5 text-xs font-medium text-red-600 hover:bg-red-50"
                                    @click="openReject(withdrawal)"
                                >
                                    {{ t('common.reject') }}
                                </button>
                            </template>
                            <span v-else class="text-xs text-slate-400">{{ formatDate(withdrawal.processed_at) }}</span>
                        </td>
                    </tr>
                    <tr v-if="!withdrawals.data.length">
                        <td colspan="7" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="withdrawals.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="withdrawals.links" />
            </div>
        </div>

        <Modal :show="showApproveModal" :title="t('withdrawals.approveWithdrawal')" @close="showApproveModal = false">
            <p class="mb-4 text-sm text-slate-600">
                {{ t('common.amount') }}: <strong>{{ formatMoney(actionWithdrawal?.amount) }}</strong>
            </p>
            <textarea
                v-model="adminNote"
                rows="3"
                class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                :placeholder="t('withdrawals.adminNote')"
            />
            <div class="mt-4 flex justify-end gap-2">
                <button type="button" class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100" @click="showApproveModal = false">
                    {{ t('common.cancel') }}
                </button>
                <button type="button" class="rounded-lg bg-emerald-600 px-4 py-2 text-sm font-medium text-white hover:bg-emerald-700" @click="approve">
                    {{ t('common.approve') }}
                </button>
            </div>
        </Modal>

        <Modal :show="showRejectModal" :title="t('withdrawals.rejectWithdrawal')" @close="showRejectModal = false">
            <textarea
                v-model="rejectionReason"
                rows="4"
                class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm"
                :placeholder="t('withdrawals.rejectionReason')"
            />
            <div class="mt-4 flex justify-end gap-2">
                <button type="button" class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100" @click="showRejectModal = false">
                    {{ t('common.cancel') }}
                </button>
                <button
                    type="button"
                    class="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
                    :disabled="!rejectionReason.trim()"
                    @click="reject"
                >
                    {{ t('common.reject') }}
                </button>
            </div>
        </Modal>
    </AdminLayout>
</template>
