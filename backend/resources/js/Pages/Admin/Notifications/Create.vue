<script setup>
import { computed } from 'vue';
import { Head, useForm } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';

const props = defineProps({
    roles: {
        type: Array,
        default: () => ['passenger', 'driver', 'admin'],
    },
});

const { t } = useI18n();

const form = useForm({
    title: '',
    body: '',
    type: 'announcement',
    recipient_type: 'all',
    user_id: '',
    role: '',
});

const showUserId = computed(() => form.recipient_type === 'user');
const showRole = computed(() => form.recipient_type === 'role');

function submit() {
    const payload = {
        title: form.title,
        body: form.body,
        type: form.type,
    };

    if (form.recipient_type === 'user' && form.user_id) {
        payload.user_id = Number(form.user_id);
    } else if (form.recipient_type === 'role' && form.role) {
        payload.role = form.role;
    }

    form.transform(() => payload).post('/admin/notifications', {
        onSuccess: () => {
            form.reset();
            form.recipient_type = 'all';
            form.type = 'announcement';
        },
        onFinish: () => form.transform((data) => data),
    });
}
</script>

<template>
    <Head :title="t('notifications.createTitle')" />

    <AdminLayout>
        <template #header>
            <h1 class="text-2xl font-bold text-slate-900">{{ t('notifications.createTitle') }}</h1>
        </template>

        <form class="max-w-2xl space-y-6 rounded-xl border border-slate-200 bg-white p-6 shadow-sm" @submit.prevent="submit">
            <div>
                <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('notifications.notificationTitle') }}</label>
                <input
                    v-model="form.title"
                    type="text"
                    required
                    maxlength="255"
                    class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                />
                <p v-if="form.errors.title" class="mt-1 text-sm text-red-600">{{ form.errors.title }}</p>
            </div>

            <div>
                <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('notifications.body') }}</label>
                <textarea
                    v-model="form.body"
                    rows="5"
                    required
                    maxlength="5000"
                    class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                />
                <p v-if="form.errors.body" class="mt-1 text-sm text-red-600">{{ form.errors.body }}</p>
            </div>

            <div>
                <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('notifications.type') }}</label>
                <select
                    v-model="form.type"
                    class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                >
                    <option value="announcement">Announcement</option>
                    <option value="promotion">Promotion</option>
                    <option value="ride">Ride</option>
                    <option value="system">System</option>
                </select>
            </div>

            <div>
                <label class="mb-2 block text-sm font-medium text-slate-700">{{ t('notifications.recipient') }}</label>
                <div class="space-y-2">
                    <label class="flex items-center gap-2 text-sm text-slate-700">
                        <input v-model="form.recipient_type" type="radio" value="all" class="text-amber-500" />
                        {{ t('notifications.allUsers') }}
                    </label>
                    <label class="flex items-center gap-2 text-sm text-slate-700">
                        <input v-model="form.recipient_type" type="radio" value="role" class="text-amber-500" />
                        {{ t('notifications.byRole') }}
                    </label>
                    <label class="flex items-center gap-2 text-sm text-slate-700">
                        <input v-model="form.recipient_type" type="radio" value="user" class="text-amber-500" />
                        {{ t('notifications.specificUser') }}
                    </label>
                </div>
            </div>

            <div v-if="showRole">
                <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('common.role') }}</label>
                <select
                    v-model="form.role"
                    class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                >
                    <option value="">—</option>
                    <option v-for="role in roles" :key="role" :value="role">{{ role }}</option>
                </select>
            </div>

            <div v-if="showUserId">
                <label class="mb-1 block text-sm font-medium text-slate-700">{{ t('notifications.userId') }}</label>
                <input
                    v-model="form.user_id"
                    type="number"
                    min="1"
                    class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                />
            </div>

            <button
                type="submit"
                class="rounded-lg bg-amber-500 px-6 py-2.5 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-50"
                :disabled="form.processing"
            >
                {{ t('notifications.create') }}
            </button>
        </form>
    </AdminLayout>
</template>
