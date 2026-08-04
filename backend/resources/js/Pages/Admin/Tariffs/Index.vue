<script setup>
import { ref } from 'vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import Pagination from '@/Components/Pagination.vue';
import Modal from '@/Components/Modal.vue';
import { formatMoney } from '@/utils/format';

defineProps({
    tariffs: {
        type: Object,
        required: true,
    },
});

const { t } = useI18n();

const showCreateModal = ref(false);
const editingTariff = ref(null);

const emptyForm = () => ({
    name: '',
    vehicle_type: 'standard',
    base_fare: 0,
    per_km_rate: 0,
    per_minute_rate: 0,
    minimum_fare: 0,
    surge_multiplier: 1,
    currency: 'USD',
    is_active: true,
});

const form = useForm(emptyForm());

function openCreate() {
    editingTariff.value = null;
    form.reset();
    form.defaults(emptyForm());
    showCreateModal.value = true;
}

function openEdit(tariff) {
    editingTariff.value = tariff;
    form.defaults({
        name: tariff.name,
        vehicle_type: tariff.vehicle_type,
        base_fare: tariff.base_fare,
        per_km_rate: tariff.per_km_rate,
        per_minute_rate: tariff.per_minute_rate,
        minimum_fare: tariff.minimum_fare,
        surge_multiplier: tariff.surge_multiplier ?? 1,
        currency: tariff.currency ?? 'USD',
        is_active: tariff.is_active,
    });
    form.reset();
    showCreateModal.value = true;
}

function submit() {
    if (editingTariff.value) {
        form.put(`/admin/tariffs/${editingTariff.value.id}`, {
            onSuccess: () => {
                showCreateModal.value = false;
            },
        });
    } else {
        form.post('/admin/tariffs', {
            onSuccess: () => {
                showCreateModal.value = false;
                form.reset();
            },
        });
    }
}

function destroyTariff(tariff) {
    if (confirm(t('tariffs.deleteConfirm'))) {
        router.delete(`/admin/tariffs/${tariff.id}`);
    }
}
</script>

<template>
    <Head :title="t('tariffs.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">{{ t('tariffs.title') }}</h1>
                <button
                    type="button"
                    class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600"
                    @click="openCreate"
                >
                    {{ t('tariffs.createTariff') }}
                </button>
            </div>
        </template>

        <div class="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-sm">
            <table class="min-w-full divide-y divide-slate-200 text-sm">
                <thead class="bg-slate-50">
                    <tr>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.name') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('tariffs.vehicleType') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('tariffs.baseFare') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('tariffs.perKm') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('tariffs.perMinute') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('tariffs.minimumFare') }}</th>
                        <th class="px-6 py-3 text-left font-medium text-slate-500">{{ t('common.status') }}</th>
                        <th class="px-6 py-3 text-right font-medium text-slate-500">{{ t('common.actions') }}</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-200">
                    <tr v-for="tariff in tariffs.data" :key="tariff.id" class="hover:bg-slate-50">
                        <td class="px-6 py-3 font-medium text-slate-900">{{ tariff.name }}</td>
                        <td class="px-6 py-3 capitalize text-slate-600">{{ tariff.vehicle_type }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ formatMoney(tariff.base_fare, tariff.currency) }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ formatMoney(tariff.per_km_rate, tariff.currency) }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ formatMoney(tariff.per_minute_rate, tariff.currency) }}</td>
                        <td class="px-6 py-3 text-slate-600">{{ formatMoney(tariff.minimum_fare, tariff.currency) }}</td>
                        <td class="px-6 py-3">
                            <span
                                class="inline-flex rounded-full px-2 py-0.5 text-xs font-medium"
                                :class="tariff.is_active ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-600'"
                            >
                                {{ tariff.is_active ? t('common.active') : t('common.inactive') }}
                            </span>
                        </td>
                        <td class="px-6 py-3 text-right">
                            <button
                                type="button"
                                class="mr-2 text-amber-600 hover:underline"
                                @click="openEdit(tariff)"
                            >
                                {{ t('common.edit') }}
                            </button>
                            <button
                                type="button"
                                class="text-red-600 hover:underline"
                                @click="destroyTariff(tariff)"
                            >
                                {{ t('common.delete') }}
                            </button>
                        </td>
                    </tr>
                    <tr v-if="!tariffs.data.length">
                        <td colspan="8" class="px-6 py-8 text-center text-slate-500">{{ t('common.noResults') }}</td>
                    </tr>
                </tbody>
            </table>

            <div v-if="tariffs.links" class="border-t border-slate-200 px-6 py-4">
                <Pagination :links="tariffs.links" />
            </div>
        </div>

        <Modal
            :show="showCreateModal"
            :title="editingTariff ? t('tariffs.editTariff') : t('tariffs.createTariff')"
            @close="showCreateModal = false"
        >
            <form class="space-y-4" @submit.prevent="submit">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('common.name') }}</label>
                        <input v-model="form.name" type="text" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.vehicleType') }}</label>
                        <input v-model="form.vehicle_type" type="text" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.baseFare') }}</label>
                        <input v-model.number="form.base_fare" type="number" step="0.01" min="0" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.perKm') }}</label>
                        <input v-model.number="form.per_km_rate" type="number" step="0.01" min="0" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.perMinute') }}</label>
                        <input v-model.number="form.per_minute_rate" type="number" step="0.01" min="0" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.minimumFare') }}</label>
                        <input v-model.number="form.minimum_fare" type="number" step="0.01" min="0" required class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.surgeMultiplier') }}</label>
                        <input v-model.number="form.surge_multiplier" type="number" step="0.1" min="1" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('tariffs.currency') }}</label>
                        <input v-model="form.currency" type="text" maxlength="3" class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500" />
                    </div>
                </div>
                <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input v-model="form.is_active" type="checkbox" class="rounded border-slate-300 text-amber-500" />
                    {{ t('common.active') }}
                </label>
                <div class="flex justify-end gap-2 pt-2">
                    <button type="button" class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100" @click="showCreateModal = false">
                        {{ t('common.cancel') }}
                    </button>
                    <button type="submit" class="rounded-lg bg-amber-500 px-4 py-2 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-50" :disabled="form.processing">
                        {{ t('common.save') }}
                    </button>
                </div>
            </form>
        </Modal>
    </AdminLayout>
</template>
