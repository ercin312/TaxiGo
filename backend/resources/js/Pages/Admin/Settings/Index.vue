<script setup>
import { computed } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';

const props = defineProps({
    settings: {
        type: Array,
        default: () => [],
    },
    defaults: {
        type: Object,
        default: () => ({}),
    },
});

const { t } = useI18n();

function getSettingValue(key, fallback) {
    const setting = props.settings.find((s) => s.key === key);
    return setting?.value ?? fallback;
}

const form = useForm({
    settings: [
        {
            key: 'commission_rate',
            value: getSettingValue('commission_rate', props.defaults.commission_rate),
            type: 'float',
            group: 'general',
        },
        {
            key: 'ride_expiry_minutes',
            value: getSettingValue('ride_expiry_minutes', props.defaults.ride_expiry_minutes),
            type: 'integer',
            group: 'general',
        },
        {
            key: 'matching_radius_km',
            value: getSettingValue('matching_radius_km', props.defaults.matching_radius_km),
            type: 'float',
            group: 'matching',
        },
        {
            key: 'currency',
            value: getSettingValue('currency', props.defaults.currency),
            type: 'string',
            group: 'general',
        },
        {
            key: 'cancellation_fee',
            value: getSettingValue('cancellation_fee', 0),
            type: 'float',
            group: 'cancellation',
        },
        {
            key: 'free_cancellation_minutes',
            value: getSettingValue('free_cancellation_minutes', 5),
            type: 'integer',
            group: 'cancellation',
        },
        {
            key: 'driver_cancellation_penalty',
            value: getSettingValue('driver_cancellation_penalty', 0),
            type: 'float',
            group: 'cancellation',
        },
    ],
});

const commissionDisplay = computed({
    get: () => Number(form.settings[0].value) * 100,
    set: (val) => {
        form.settings[0].value = Number(val) / 100;
    },
});

function submit() {
    form.put('/admin/settings');
}
</script>

<template>
    <Head :title="t('settings.title')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('settings.title') }}</h1>
        </template>

        <form class="max-w-2xl space-y-8" @submit.prevent="submit">
            <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('settings.general') }}</h2>
                <div class="space-y-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('settings.commissionRate') }} (%)</label>
                        <input
                            v-model.number="commissionDisplay"
                            type="number"
                            step="0.1"
                            min="0"
                            max="100"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('settings.rideExpiry') }}</label>
                        <input
                            v-model.number="form.settings[1].value"
                            type="number"
                            min="1"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('settings.matchingRadius') }}</label>
                        <input
                            v-model.number="form.settings[2].value"
                            type="number"
                            step="0.1"
                            min="0"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('settings.currency') }}</label>
                        <input
                            v-model="form.settings[3].value"
                            type="text"
                            maxlength="3"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm uppercase focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                </div>
            </section>

            <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('settings.cancellationRules') }}</h2>
                <div class="space-y-4">
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">Cancellation Fee</label>
                        <input
                            v-model.number="form.settings[4].value"
                            type="number"
                            step="0.01"
                            min="0"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">Free Cancellation Window (minutes)</label>
                        <input
                            v-model.number="form.settings[5].value"
                            type="number"
                            min="0"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                    <div>
                        <label class="mb-1 block text-sm font-medium text-slate-700">Driver Cancellation Penalty</label>
                        <input
                            v-model.number="form.settings[6].value"
                            type="number"
                            step="0.01"
                            min="0"
                            class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                        />
                    </div>
                </div>
            </section>

            <div v-if="settings.length" class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                <h2 class="mb-4 text-lg font-semibold text-slate-900">All Settings</h2>
                <table class="min-w-full text-sm">
                    <thead>
                        <tr class="border-b border-slate-200 text-left text-slate-500">
                            <th class="pb-2 pr-4">{{ t('settings.key') }}</th>
                            <th class="pb-2 pr-4">{{ t('settings.value') }}</th>
                            <th class="pb-2">{{ t('settings.group') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="setting in settings" :key="setting.id" class="border-b border-slate-100">
                            <td class="py-2 pr-4 font-mono text-slate-700">{{ setting.key }}</td>
                            <td class="py-2 pr-4 text-slate-600">{{ setting.value }}</td>
                            <td class="py-2 capitalize text-slate-500">{{ setting.group }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <button
                type="submit"
                class="rounded-lg bg-amber-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-50"
                :disabled="form.processing"
            >
                {{ t('settings.saveSettings') }}
            </button>
        </form>
    </AdminLayout>
</template>
