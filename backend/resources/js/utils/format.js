export function formatDate(value) {
    if (!value) return '—';
    return new Date(value).toLocaleString();
}

export function formatMoney(value, currency = 'USD') {
    if (value === null || value === undefined || value === '') return '—';
    return new Intl.NumberFormat(undefined, {
        style: 'currency',
        currency,
        minimumFractionDigits: 2,
    }).format(Number(value));
}

export function formatPercent(value) {
    if (value === null || value === undefined) return '—';
    return `${(Number(value) * 100).toFixed(1)}%`;
}

export function storageUrl(path) {
    if (!path) return null;
    if (path.startsWith('http')) return path;
    return `/storage/${path.replace(/^\//, '')}`;
}
