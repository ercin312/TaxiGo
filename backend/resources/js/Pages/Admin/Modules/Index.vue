<script setup>
import { computed } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';

const props = defineProps({
    modules: { type: Array, default: () => [] },
    grouped: { type: Object, default: () => ({}) },
    categories: { type: Object, default: () => ({}) },
});

const { t } = useI18n();

const form = useForm({
    modules: Object.fromEntries(props.modules.map((m) => [m.key, !!m.enabled])),
});

const categoryOrder = ['auth', 'maps', 'payments', 'realtime', 'safety', 'rides'];

const sections = computed(() =>
    categoryOrder
        .filter((key) => props.grouped[key]?.length)
        .map((key) => ({
            key,
            title: props.categories[key] || key,
            items: props.grouped[key],
        })),
);

function enableAll() {
    for (const m of props.modules) {
        form.modules[m.key] = true;
    }
}

function disableAll() {
    for (const m of props.modules) {
        form.modules[m.key] = false;
    }
}

function submit() {
    form.put('/admin/modules');
}
</script>

<template>
    <Head :title="t('modules.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex flex-wrap items-end justify-between gap-3">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-wider text-amber-600">
                        {{ t('modules.superAdmin') }}
                    </p>
                    <h1 class="text-2xl font-bold text-slate-900">{{ t('modules.title') }}</h1>
                    <p class="mt-1 text-sm text-slate-500">{{ t('modules.subtitle') }}</p>
                </div>
                <div class="flex gap-2">
                    <button
                        type="button"
                        class="rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-700 hover:bg-slate-50"
                        @click="enableAll"
                    >
                        {{ t('modules.enableAll') }}
                    </button>
                    <button
                        type="button"
                        class="rounded-lg border border-slate-300 px-3 py-2 text-sm text-slate-700 hover:bg-slate-50"
                        @click="disableAll"
                    >
                        {{ t('modules.disableAll') }}
                    </button>
                </div>
            </div>
        </template>

        <form class="max-w-4xl space-y-6" @submit.prevent="submit">
            <section
                v-for="section in sections"
                :key="section.key"
                class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm"
            >
                <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ section.title }}</h2>
                <div class="divide-y divide-slate-100">
                    <label
                        v-for="item in section.items"
                        :key="item.key"
                        class="flex cursor-pointer items-start justify-between gap-4 py-4 first:pt-0 last:pb-0"
                    >
                        <div class="min-w-0">
                            <div class="font-medium text-slate-900">{{ item.label }}</div>
                            <div class="mt-0.5 text-sm text-slate-500">{{ item.description }}</div>
                            <code class="mt-1 inline-block text-xs text-slate-400">modules.{{ item.key }}</code>
                        </div>
                        <div class="flex shrink-0 items-center gap-3">
                            <span
                                class="text-xs font-medium"
                                :class="form.modules[item.key] ? 'text-emerald-600' : 'text-slate-400'"
                            >
                                {{ form.modules[item.key] ? t('common.active') : t('common.inactive') }}
                            </span>
                            <input
                                v-model="form.modules[item.key]"
                                type="checkbox"
                                class="h-5 w-5 rounded border-slate-300 text-amber-500 focus:ring-amber-500"
                            />
                        </div>
                    </label>
                </div>
            </section>

            <button
                type="submit"
                class="rounded-lg bg-amber-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-50"
                :disabled="form.processing"
            >
                {{ t('modules.save') }}
            </button>
        </form>
    </AdminLayout>
</template>
