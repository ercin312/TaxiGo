<script setup>
import { computed, watch } from 'vue';
import { usePage } from '@inertiajs/vue3';

const page = usePage();

const success = computed(() => page.props.flash?.success);
const error = computed(() => page.props.flash?.error);

const visible = computed(() => success.value || error.value);

watch(visible, (show) => {
    if (show) {
        setTimeout(() => {
            page.props.flash.success = null;
            page.props.flash.error = null;
        }, 5000);
    }
});
</script>

<template>
    <div v-if="visible" class="fixed right-4 top-4 z-50 max-w-sm space-y-2">
        <div
            v-if="success"
            class="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800 shadow-lg"
        >
            {{ success }}
        </div>
        <div
            v-if="error"
            class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800 shadow-lg"
        >
            {{ error }}
        </div>
    </div>
</template>
