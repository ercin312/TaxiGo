<script setup>
defineProps({
    show: {
        type: Boolean,
        default: false,
    },
    title: {
        type: String,
        default: '',
    },
});

const emit = defineEmits(['close']);
</script>

<template>
    <Teleport to="body">
        <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-slate-900/50" @click="emit('close')" />
            <div class="relative w-full max-w-lg rounded-xl bg-white p-6 shadow-xl">
                <div class="mb-4 flex items-center justify-between">
                    <h3 class="text-lg font-semibold text-slate-900">{{ title }}</h3>
                    <button
                        type="button"
                        class="rounded-md p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
                        @click="emit('close')"
                    >
                        <span class="sr-only">Close</span>
                        ✕
                    </button>
                </div>
                <slot />
            </div>
        </div>
    </Teleport>
</template>
