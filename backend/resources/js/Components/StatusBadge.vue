<script setup>
import { computed } from 'vue';

const props = defineProps({
    status: {
        type: String,
        required: true,
    },
});

const classes = computed(() => {
    const map = {
        pending: 'bg-amber-100 text-amber-800',
        approved: 'bg-emerald-100 text-emerald-800',
        rejected: 'bg-red-100 text-red-800',
        banned: 'bg-slate-800 text-white',
        active: 'bg-emerald-100 text-emerald-800',
        inactive: 'bg-slate-100 text-slate-600',
        open: 'bg-blue-100 text-blue-800',
        urgent: 'bg-red-100 text-red-800',
        in_progress: 'bg-cyan-100 text-cyan-800',
        resolved: 'bg-emerald-100 text-emerald-800',
        closed: 'bg-slate-100 text-slate-600',
        completed: 'bg-emerald-100 text-emerald-800',
        cancelled_by_passenger: 'bg-orange-100 text-orange-800',
        cancelled_by_driver: 'bg-orange-100 text-orange-800',
        expired: 'bg-slate-100 text-slate-600',
        driver_assigned: 'bg-blue-100 text-blue-800',
        driver_arriving: 'bg-indigo-100 text-indigo-800',
        driver_arrived: 'bg-violet-100 text-violet-800',
        passenger_on_board: 'bg-purple-100 text-purple-800',
    };

    return map[props.status] || 'bg-slate-100 text-slate-700';
});
</script>

<template>
    <span
        class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium capitalize"
        :class="classes"
    >
        {{ status.replace(/_/g, ' ') }}
    </span>
</template>
