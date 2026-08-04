<script setup>
import { Link } from '@inertiajs/vue3';

defineProps({
    links: {
        type: Array,
        required: true,
    },
});
</script>

<template>
    <nav v-if="links.length > 3" class="flex flex-wrap items-center gap-1">
        <template v-for="(link, index) in links" :key="index">
            <span
                v-if="!link.url"
                class="rounded-md px-3 py-1.5 text-sm text-slate-400"
                v-html="link.label"
            />
            <Link
                v-else
                :href="link.url"
                class="rounded-md px-3 py-1.5 text-sm transition"
                :class="
                    link.active
                        ? 'bg-amber-500 font-medium text-white'
                        : 'text-slate-600 hover:bg-slate-100'
                "
                v-html="link.label"
            />
        </template>
    </nav>
</template>
