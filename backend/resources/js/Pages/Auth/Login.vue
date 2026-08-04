<script setup>
import { useForm } from '@inertiajs/vue3';

const form = useForm({
    email: '',
    password: '',
    remember: false,
});

const submit = () => {
    form.post('/login');
};
</script>

<template>
    <div class="relative flex min-h-screen items-center justify-center overflow-hidden px-4">
        <div class="absolute inset-0 bg-[linear-gradient(135deg,#0B1220_0%,#152748_45%,#1A3358_100%)]" />
        <div class="absolute -right-24 -top-24 h-80 w-80 rounded-full bg-[#F5B400]/20 blur-3xl" />
        <div class="absolute -bottom-20 -left-16 h-72 w-72 rounded-full bg-[#F5B400]/10 blur-3xl" />

        <div class="relative w-full max-w-md border border-white/10 bg-[#FAF9F7] p-8 shadow-[0_24px_80px_rgba(11,18,32,0.35)]"
             style="border-radius: 28px;">
            <div class="mb-1 text-xs font-semibold uppercase tracking-[0.18em] text-[#C48A00]">Super Admin</div>
            <h1 class="text-3xl font-bold tracking-tight text-[#0B1220]">TaxiGo</h1>
            <p class="mt-2 mb-8 text-sm text-[#5B6475]">Operasyon paneline giriş</p>

            <form class="space-y-4" @submit.prevent="submit">
                <div>
                    <label class="mb-1 block text-sm font-medium text-[#0F172A]">Email</label>
                    <input
                        v-model="form.email"
                        type="email"
                        required
                        class="w-full rounded-xl border border-[#D9D3C8] bg-white px-3 py-2.5 text-sm outline-none ring-[#F5B400] focus:ring-2"
                    />
                    <p v-if="form.errors.email" class="mt-1 text-sm text-[#D14343]">{{ form.errors.email }}</p>
                </div>

                <div>
                    <label class="mb-1 block text-sm font-medium text-[#0F172A]">Password</label>
                    <input
                        v-model="form.password"
                        type="password"
                        required
                        class="w-full rounded-xl border border-[#D9D3C8] bg-white px-3 py-2.5 text-sm outline-none ring-[#F5B400] focus:ring-2"
                    />
                </div>

                <label class="flex items-center gap-2 text-sm text-[#5B6475]">
                    <input v-model="form.remember" type="checkbox" class="rounded border-[#D9D3C8] text-[#F5B400]" />
                    Beni hatırla
                </label>

                <button
                    type="submit"
                    :disabled="form.processing"
                    class="w-full rounded-xl bg-[#0B1220] py-3 text-sm font-bold tracking-wide text-[#F5B400] transition hover:bg-[#151E32] disabled:opacity-50"
                >
                    Giriş Yap
                </button>
            </form>
        </div>
    </div>
</template>
