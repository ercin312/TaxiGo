<script setup>
import { computed, ref } from 'vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { useI18n } from 'vue-i18n';
import AdminLayout from '@/Layouts/AdminLayout.vue';
import StatusBadge from '@/Components/StatusBadge.vue';
import Modal from '@/Components/Modal.vue';
import { formatDate, formatMoney, storageUrl } from '@/utils/format';

const props = defineProps({
    driver: {
        type: Object,
        required: true,
    },
    document_review: {
        type: Object,
        default: () => ({}),
    },
});

const { t } = useI18n();
const page = usePage();

const showRejectModal = ref(false);
const showBanModal = ref(false);
const showDocRejectModal = ref(false);
const rejectionReason = ref('');
const banReason = ref('');
const docRejectReason = ref('');
const selectedDocument = ref(null);

const canForceApprove = computed(
    () => props.document_review?.can_force_approve
        || page.props.auth?.user?.is_super_admin,
);

const allVerified = computed(() => props.document_review?.all_verified === true);
const allUploaded = computed(() => props.document_review?.all_uploaded === true);

const canApproveNormally = computed(
    () => allUploaded.value && allVerified.value,
);

function approve({ force = false } = {}) {
    router.post(`/admin/drivers/${props.driver.id}/approve`, { force });
}

function reject() {
    router.post(`/admin/drivers/${props.driver.id}/reject`, {
        rejection_reason: rejectionReason.value,
    }, {
        onSuccess: () => {
            showRejectModal.value = false;
            rejectionReason.value = '';
        },
    });
}

function ban() {
    router.post(`/admin/drivers/${props.driver.id}/ban`, {
        rejection_reason: banReason.value,
    }, {
        onSuccess: () => {
            showBanModal.value = false;
            banReason.value = '';
        },
    });
}

function verifyDocument(doc) {
    router.post(`/admin/drivers/${props.driver.id}/documents/${doc.id}/verify`);
}

function openRejectDocument(doc) {
    selectedDocument.value = doc;
    docRejectReason.value = '';
    showDocRejectModal.value = true;
}

function rejectDocument() {
    if (!selectedDocument.value) return;
    router.post(
        `/admin/drivers/${props.driver.id}/documents/${selectedDocument.value.id}/reject`,
        { rejection_reason: docRejectReason.value },
        {
            onSuccess: () => {
                showDocRejectModal.value = false;
                selectedDocument.value = null;
                docRejectReason.value = '';
            },
        },
    );
}

function documentLabel(type) {
    const key = `drivers.docTypes.${type}`;
    const translated = t(key);
    return translated === key ? type : translated;
}
</script>

<template>
    <Head :title="driver.user?.name ?? t('drivers.title')" />

    <AdminLayout>
        <template #header>
            <div class="flex items-center gap-4">
                <Link href="/admin/drivers" class="text-sm text-slate-500 hover:text-slate-700">
                    ← {{ t('common.back') }}
                </Link>
                <h1 class="text-2xl font-bold text-slate-900">{{ driver.user?.name }}</h1>
                <StatusBadge :status="driver.approval_status" />
            </div>
        </template>

        <div class="grid gap-6 lg:grid-cols-3">
            <div class="space-y-6 lg:col-span-2">
                <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                    <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('common.name') }}</h2>
                    <dl class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('common.email') }}</dt>
                            <dd class="font-medium text-slate-900">{{ driver.user?.email ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('common.phone') }}</dt>
                            <dd class="font-medium text-slate-900">{{ driver.user?.phone ?? '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('drivers.rating') }}</dt>
                            <dd class="font-medium text-slate-900">
                                {{ driver.rating_average ?? '—' }} ({{ driver.rating_count ?? 0 }})
                            </dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('drivers.totalRides') }}</dt>
                            <dd class="font-medium text-slate-900">{{ driver.total_rides ?? 0 }}</dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('drivers.approvedAt') }}</dt>
                            <dd class="font-medium text-slate-900">{{ formatDate(driver.approved_at) }}</dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('drivers.online') }}</dt>
                            <dd class="font-medium text-slate-900">
                                {{ driver.is_online ? t('drivers.online') : t('drivers.offline') }}
                            </dd>
                        </div>
                    </dl>
                    <p v-if="driver.rejection_reason" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
                        {{ driver.rejection_reason }}
                    </p>
                </section>

                <section v-if="driver.vehicle" class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                    <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('drivers.vehicle') }}</h2>
                    <dl class="grid gap-4 sm:grid-cols-2">
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('tariffs.vehicleType') }}</dt>
                            <dd class="font-medium capitalize text-slate-900">{{ driver.vehicle.vehicle_type }}</dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">{{ t('common.name') }}</dt>
                            <dd class="font-medium text-slate-900">
                                {{ driver.vehicle.make }} {{ driver.vehicle.model }} ({{ driver.vehicle.year }})
                            </dd>
                        </div>
                        <div>
                            <dt class="text-sm text-slate-500">Color / Plate</dt>
                            <dd class="font-medium text-slate-900">
                                {{ driver.vehicle.color }} — {{ driver.vehicle.plate_number }}
                            </dd>
                        </div>
                    </dl>
                </section>

                <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                    <div class="mb-4 flex flex-wrap items-center justify-between gap-2">
                        <h2 class="text-lg font-semibold text-slate-900">{{ t('drivers.documents') }}</h2>
                        <p class="text-sm text-slate-500">
                            {{ document_review.uploaded_count ?? driver.documents?.length ?? 0 }}
                            /
                            {{ document_review.required_count ?? 4 }}
                            ·
                            <span :class="allVerified ? 'text-emerald-600' : 'text-amber-600'">
                                {{ allVerified ? t('drivers.allDocsVerified') : t('drivers.docsAwaitingReview') }}
                            </span>
                        </p>
                    </div>
                    <div v-if="driver.documents?.length" class="space-y-3">
                        <div
                            v-for="doc in driver.documents"
                            :key="doc.id"
                            class="flex flex-col gap-3 rounded-lg border border-slate-200 p-4 sm:flex-row sm:items-center sm:justify-between"
                        >
                            <div>
                                <p class="font-medium text-slate-900">{{ documentLabel(doc.type) }}</p>
                                <p class="text-sm text-slate-500">{{ doc.original_name }}</p>
                                <StatusBadge :status="doc.status ?? 'pending'" class="mt-1" />
                                <p
                                    v-if="doc.rejection_reason"
                                    class="mt-2 text-sm text-red-600"
                                >
                                    {{ doc.rejection_reason }}
                                </p>
                            </div>
                            <div class="flex flex-wrap items-center gap-2">
                                <a
                                    v-if="doc.file_path"
                                    :href="storageUrl(doc.file_path)"
                                    target="_blank"
                                    rel="noopener"
                                    class="rounded-md bg-amber-500 px-3 py-1.5 text-xs font-medium text-white hover:bg-amber-600"
                                >
                                    {{ t('drivers.viewDocument') }}
                                </a>
                                <button
                                    v-if="doc.status !== 'verified'"
                                    type="button"
                                    class="rounded-md bg-emerald-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-emerald-700"
                                    @click="verifyDocument(doc)"
                                >
                                    {{ t('drivers.verifyDocument') }}
                                </button>
                                <button
                                    v-if="doc.status !== 'rejected'"
                                    type="button"
                                    class="rounded-md bg-orange-500 px-3 py-1.5 text-xs font-medium text-white hover:bg-orange-600"
                                    @click="openRejectDocument(doc)"
                                >
                                    {{ t('drivers.rejectDocument') }}
                                </button>
                            </div>
                        </div>
                    </div>
                    <p v-else class="text-sm text-slate-500">{{ t('drivers.noDocuments') }}</p>
                </section>

                <section v-if="driver.rides?.length" class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                    <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('drivers.ridesHistory') }}</h2>
                    <div class="space-y-2">
                        <div
                            v-for="ride in driver.rides.slice(0, 10)"
                            :key="ride.id"
                            class="flex items-center justify-between rounded-lg border border-slate-100 px-4 py-3"
                        >
                            <Link :href="`/admin/rides/${ride.id}`" class="font-medium text-amber-600 hover:underline">
                                {{ ride.reference }}
                            </Link>
                            <StatusBadge :status="ride.status" />
                            <span class="text-sm text-slate-500">{{ formatMoney(ride.final_fare ?? ride.estimated_fare) }}</span>
                        </div>
                    </div>
                </section>
            </div>

            <div class="space-y-4">
                <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
                    <h2 class="mb-4 text-lg font-semibold text-slate-900">{{ t('common.actions') }}</h2>
                    <div
                        v-if="!canApproveNormally && (driver.approval_status === 'pending' || driver.approval_status === 'rejected')"
                        class="mb-3 rounded-lg bg-amber-50 p-3 text-sm text-amber-800"
                    >
                        {{ t('drivers.approveRequiresDocs') }}
                    </div>
                    <div class="space-y-3">
                        <button
                            v-if="(driver.approval_status === 'pending' || driver.approval_status === 'rejected') && canApproveNormally"
                            type="button"
                            class="w-full rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-emerald-700"
                            @click="approve()"
                        >
                            {{ t('drivers.approveDriver') }}
                        </button>
                        <button
                            v-if="(driver.approval_status === 'pending' || driver.approval_status === 'rejected') && canForceApprove && !canApproveNormally"
                            type="button"
                            class="w-full rounded-lg border border-emerald-600 bg-white px-4 py-2.5 text-sm font-medium text-emerald-700 hover:bg-emerald-50"
                            @click="approve({ force: true })"
                        >
                            {{ t('drivers.forceApprove') }}
                        </button>
                        <button
                            v-if="driver.approval_status === 'pending'"
                            type="button"
                            class="w-full rounded-lg bg-orange-500 px-4 py-2.5 text-sm font-medium text-white hover:bg-orange-600"
                            @click="showRejectModal = true"
                        >
                            {{ t('drivers.rejectDriver') }}
                        </button>
                        <button
                            v-if="driver.approval_status !== 'banned'"
                            type="button"
                            class="w-full rounded-lg bg-red-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-red-700"
                            @click="showBanModal = true"
                        >
                            {{ t('drivers.banDriver') }}
                        </button>
                    </div>
                </section>
            </div>
        </div>

        <Modal :show="showRejectModal" :title="t('drivers.rejectDriver')" @close="showRejectModal = false">
            <textarea
                v-model="rejectionReason"
                rows="4"
                class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                :placeholder="t('drivers.rejectionReason')"
            />
            <div class="mt-4 flex justify-end gap-2">
                <button
                    type="button"
                    class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100"
                    @click="showRejectModal = false"
                >
                    {{ t('common.cancel') }}
                </button>
                <button
                    type="button"
                    class="rounded-lg bg-orange-500 px-4 py-2 text-sm font-medium text-white hover:bg-orange-600"
                    :disabled="!rejectionReason.trim()"
                    @click="reject"
                >
                    {{ t('common.reject') }}
                </button>
            </div>
        </Modal>

        <Modal :show="showBanModal" :title="t('drivers.banDriver')" @close="showBanModal = false">
            <textarea
                v-model="banReason"
                rows="4"
                class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                :placeholder="t('drivers.banReason')"
            />
            <div class="mt-4 flex justify-end gap-2">
                <button
                    type="button"
                    class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100"
                    @click="showBanModal = false"
                >
                    {{ t('common.cancel') }}
                </button>
                <button
                    type="button"
                    class="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
                    :disabled="!banReason.trim()"
                    @click="ban"
                >
                    {{ t('common.ban') }}
                </button>
            </div>
        </Modal>

        <Modal
            :show="showDocRejectModal"
            :title="t('drivers.rejectDocument')"
            @close="showDocRejectModal = false"
        >
            <textarea
                v-model="docRejectReason"
                rows="4"
                class="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
                :placeholder="t('drivers.rejectionReason')"
            />
            <div class="mt-4 flex justify-end gap-2">
                <button
                    type="button"
                    class="rounded-lg px-4 py-2 text-sm text-slate-600 hover:bg-slate-100"
                    @click="showDocRejectModal = false"
                >
                    {{ t('common.cancel') }}
                </button>
                <button
                    type="button"
                    class="rounded-lg bg-orange-500 px-4 py-2 text-sm font-medium text-white hover:bg-orange-600"
                    :disabled="!docRejectReason.trim()"
                    @click="rejectDocument"
                >
                    {{ t('common.reject') }}
                </button>
            </div>
        </Modal>
    </AdminLayout>
</template>
