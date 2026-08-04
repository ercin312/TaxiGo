<script setup>
import { computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import FlashMessages from '@/Components/FlashMessages.vue';

const { t, locale } = useI18n();
const page = usePage();

const user = computed(() => page.props.auth?.user);

const navigation = [
    { name: 'dashboard', href: '/admin', icon: '📊' },
    { name: 'users', href: '/admin/users', icon: '👥' },
    { name: 'drivers', href: '/admin/drivers', icon: '🚕' },
    { name: 'rides', href: '/admin/rides', icon: '🛣️' },
    { name: 'liveMap', href: '/admin/rides/live-map', icon: '🗺️' },
    { name: 'tariffs', href: '/admin/tariffs', icon: '💰' },
    { name: 'promos', href: '/admin/promos', icon: '🎟️' },
    { name: 'complaints', href: '/admin/complaints', icon: '⚠️' },
    { name: 'withdrawals', href: '/admin/withdrawals', icon: '🏦' },
    { name: 'notifications', href: '/admin/notifications', icon: '🔔' },
    { name: 'settings', href: '/admin/settings', icon: '⚙️' },
    { name: 'modules', href: '/admin/modules', icon: '🧩', superAdminOnly: true },
];

const visibleNavigation = computed(() =>
    navigation.filter((item) => !item.superAdminOnly || user.value?.is_super_admin),
);

function isActive(href) {
    const path = page.url.split('?')[0];
    if (href === '/admin') {
        return path === '/admin';
    }
    return path.startsWith(href);
}

function switchLocale(code) {
    locale.value = code;
    document.documentElement.lang = code;
}
</script>

<template>
    <div class="min-h-screen bg-slate-50">
        <FlashMessages />

        <div class="flex min-h-screen">
            <aside class="fixed inset-y-0 left-0 z-30 flex w-64 flex-col border-r border-slate-800 bg-[#0B1220] text-white">
                <div class="border-b border-white/10 px-6 py-5">
                    <div class="text-xl font-bold tracking-tight">TaxiGo</div>
                    <div class="mt-1 text-xs uppercase tracking-[0.14em] text-[#F5B400]/90">Admin Panel</div>
                </div>

                <nav class="flex-1 space-y-1 overflow-y-auto px-3 py-4">
                    <Link
                        v-for="item in visibleNavigation"
                        :key="item.name"
                        :href="item.href"
                        class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition"
                        :class="
                            isActive(item.href)
                                ? 'bg-[#F5B400] text-[#0B1220]'
                                : 'text-slate-300 hover:bg-white/5 hover:text-white'
                        "
                    >
                        <span class="text-base">{{ item.icon }}</span>
                        {{ t(`nav.${item.name}`) }}
                    </Link>
                </nav>

                <div class="border-t border-white/10 px-4 py-4">
                    <div class="mb-3 flex gap-1">
                        <button
                            type="button"
                            class="rounded px-2 py-1 text-xs"
                            :class="locale === 'en' ? 'bg-[#F5B400] text-[#0B1220]' : 'text-slate-400 hover:text-white'"
                            @click="switchLocale('en')"
                        >
                            EN
                        </button>
                        <button
                            type="button"
                            class="rounded px-2 py-1 text-xs"
                            :class="locale === 'tr' ? 'bg-[#F5B400] text-[#0B1220]' : 'text-slate-400 hover:text-white'"
                            @click="switchLocale('tr')"
                        >
                            TR
                        </button>
                    </div>
                    <div v-if="user" class="truncate text-sm text-slate-300">
                        {{ user.name }}
                    </div>
                </div>
            </aside>

            <div class="flex flex-1 flex-col bg-[#F3F1EC] pl-64">
                <header class="sticky top-0 z-20 border-b border-[#D9D3C8]/80 bg-[#FAF9F7]/90 px-8 py-4 backdrop-blur">
                    <slot name="header" />
                </header>

                <main class="flex-1 px-8 py-6">
                    <slot />
                </main>
            </div>
        </div>
    </div>
</template>
