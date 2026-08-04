<script setup>
import { ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import Modal from '@/Components/Modal.vue';
import { formatDate, formatMoney } from '@/utils/format';

defineProps({
    promoCodes: {
        type: Object,
        required: true,
    },
});

const { t } = useI18n();

const showModal = ref(false);
const editingPromo = ref(null);

const emptyForm = () => ({
    code: '',
    description: '',
    discount_type: 'percentage',
    discount_value: 0,
    max_discount: null,
    min_fare: null,
    max_uses: null,
    per_user_limit: 1,
    is_active: true,
    starts_at: '',
    expires_at: '',
});

const form = useForm(emptyForm());

function openCreate() {
    editingPromo.value = null;
    form.reset();
    form.defaults(emptyForm());
    showModal.value = true;
}

function openEdit(promo) {
    editingPromo.value = promo;
    form.defaults({
        code: promo.code,
        description: promo.description ?? '',
        discount_type: promo.discount_type,
        discount_value: promo.discount_value,
        max_discount: promo.max_discount,
        min_fare: promo.min_fare,
        max_uses: promo.max_uses,
        per_user_limit: promo.per_user_limit ?? 1,
        is_active: promo.is_active,
        starts_at: promo.starts_at ? promo.starts_at.slice(0, 16) : '',
        expires_at: promo.expires_at ? promo.expires_at.slice(0, 16) : '',
    });
    form.reset();
    showModal.value = true;
}

function submit() {
    const payload = { ...form.data() };
    if (!payload.starts_at) delete payload.starts_at;
    if (!payload.expires_at) delete payload.expires_at;

    if (editingPromo.value) {
        const { code, ...updateData } = payload;
        form.transform(() => updateData).put(`/admin/promos/${editingPromo.value.id}`, {
            onSuccess: () => {
                showModal.value = false;
                form.transform((data) => data);
            },
        });
    } else {
        form.post('/admin/promos', {
            onSuccess: () => {
                showModal.value = false;
                form.reset();
            },
        });
    }
}

function deactivate(promo) {
    if (confirm(t('promos.deactivateConfirm'))) {
        router.delete(`/admin/promos/${promo.id}`);
    }
}
</script>

<template>
    <Head :title="t('promos.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">{{ t('promos.title') }}</h1>
                <button type="button" class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600" @click="openCreate">
                    {{ t('promos.createPromo') }}
                </button>
            </div>
        </template>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('promos.code') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.description') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('promos.discountType') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('promos.discountValue') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('promos.usedCount') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="promo in promoCodes.data" :key="promo.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-mono font-medium text-slate-900">{{ promo.code }}</td>
                        <td class="max-w-xs truncate px-6 py-3 text-slate-600">{{ promo.description ?? '—' }}</td>
                        <td class="px-6 py-3 capitalize text-slate-600">{{ promo.discount_type }}</td>
                        <td class="px-6 py-3 text-slate-600">
                            {{ promo.discount_type === 'percentage' ? `${promo.discount_value}%` : formatMoney(promo.discount_value) }}
                        </td>
                        <td class="px-6 py-3 text-slate-600">
                            {{ promo.used_count ?? 0 }}{{ promo.max_uses ? ` / ${promo.max_uses}` : '' }}
                        </td>
                        <td class="px-6 py-3">
                            <span
                                class="inline-flex rounded-full px-2 py-0.5 text-xs font-medium"
                                :class="promo.is_active ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'"
                            >
                                {{ promo.is_active ? t('common.active') : t('common.inactive') }}
                            </span>
                        </td>
                        <td class="px-6 py-3 text-right">
                            <button type="button" class="mr-2 text-amber-600 hover:underline" @click="openEdit(promo)">
                                {{ t('common.edit') }}
                            </button>
                            <button
                                v-if="promo.is_active"
                                type="button"
                                class="text-red-600 hover:underline"
                                @click="deactivate(promo)"
                            >
                                {{ t('common.deactivate') }}
                            </button>
                        </td>
                    </tr>
                    <tr v-if="!promoCodes.data.length">
                        <td colspan="7" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="promoCodes.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="promoCodes.links" />
            </div>
        </div>

        <Modal
            :show="showModal"
            :title="editingPromo ? t('common.edit') : t('promos.createPromo')"
            @close="showModal = false"
        >
            <form class="space-y-4" @submit.prevent="submit">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.code') }}</label>
                        <input
                            v-model="form.code"
                            type="text"
                            required
                            :disabled="!!editingPromo"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm uppercase focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500 disabled:bg-slate-100"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.discountType') }}</label>
                        <select v-model="form.discount_type" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm">
                            <option value="percentage">{{ t('promos.percentage') }}</option>
                            <option value="fixed">{{ t('promos.fixed') }}</option>
                        </select>
                    </div>
                    <div class="sm:col-span-2">
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('common.description') }}</label>
                        <input v-model="form.description" type="text" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.discountValue') }}</label>
                        <input v-model.number="form.discount_value" type="number" step="0.01" min="0" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.maxDiscount') }}</label>
                        <input v-model.number="form.max_discount" type="number" step="0.01" min="0" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.minFare') }}</label>
                        <input v-model.number="form.min_fare" type="number" step="0.01" min="0" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.maxUses') }}</label>
                        <input v-model.number="form.max_uses" type="number" min="1" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.perUserLimit') }}</label>
                        <input v-model.number="form.per_user_limit" type="number" min="1" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.startsAt') }}</label>
                        <input v-model="form.starts_at" type="datetime-local" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('promos.expiresAt') }}</label>
                        <input v-model="form.expires_at" type="datetime-local" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm" />
                    </div>
                </div>
                <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input v-model="form.is_active" type="checkbox" class="rounded border-slate-300 text-amber-500" />
                    {{ t('common.active') }}
                </label>
                <div class="flex justify-end gap-2">
                    <button type="button" class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100" @click="showModal = false">
                        {{ t('common.cancel') }}
                    </button>
                    <button type="submit" class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600" :disabled="form.processing">
                        {{ t('common.save') }}
                    </button>
                </div>
            </form>
        </Modal>
    </AdminLayout>
</template>
