import { createApp, h } from 'vue';
import { createInertiaApp } from '@inertiajs/vue3';
import { createI18n } from 'vue-i18n';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import 'leaflet/dist/leaflet.css';

import en from '@/i18n/en.json';
import tr from '@/i18n/tr.json';

const i18n = createI18n({
    legacy: false,
    locale: document.documentElement.lang?.slice(0, 2) || 'en',
    fallbackLocale: 'en',
    messages: { en, tr },
});

createInertiaApp({
    title: (title) => (title ? `${title} - TaxiGo` : 'TaxiGo'),
    resolve: (name) =>
        resolvePageComponent(`./Pages/${name}.vue`, import.meta.glob('./Pages/**/*.vue')),
    setup({ el, App, props, plugin }) {
        createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(i18n)
            .mount(el);
    },
    progress: {
        color: '#f59e0b',
    },
});
