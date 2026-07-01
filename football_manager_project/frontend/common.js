const API_BASE = "/api";

function adminKey() {
    return localStorage.getItem("football_admin_key") || "";
}

function setAdminKey(value) {
    localStorage.setItem("football_admin_key", value.trim());
}

async function api(path, options = {}) {
    const config = { ...options };
    config.headers = { ...(options.headers || {}) };

    if (config.body && !(config.body instanceof FormData)) {
        config.headers["Content-Type"] = "application/json";
    }
    if (config.method && config.method.toUpperCase() !== "GET") {
        config.headers["X-Admin-Key"] = adminKey();
    }

    const response = await fetch(`${API_BASE}${path}`, config);
    const contentType = response.headers.get("content-type") || "";
    const payload = contentType.includes("application/json")
        ? await response.json()
        : await response.text();

    if (!response.ok) {
        const message = payload && payload.error
            ? payload.error
            : `请求失败（HTTP ${response.status}）`;
        throw new Error(message);
    }
    return payload;
}

function escapeHtml(value) {
    if (value === null || value === undefined) return "";
    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}

function formatDate(value) {
    if (!value) return "—";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return String(value);
    return new Intl.DateTimeFormat("zh-CN", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
    }).format(date);
}

const STATUS_LABELS = {
    scheduled: "未开始",
    live: "进行中",
    finished: "已结束",
    postponed: "延期",
    cancelled: "取消",
};

function statusBadge(status) {
    const text = STATUS_LABELS[status] || status;
    return `<span class="badge ${escapeHtml(status)}">${escapeHtml(text)}</span>`;
}

function queryParam(name) {
    return new URLSearchParams(window.location.search).get(name);
}

function showNotice(element, message, type = "info") {
    element.innerHTML = `<div class="notice ${type}">${escapeHtml(message)}</div>`;
}

function eventLabel(event) {
    const time = event.stoppage_minute
        ? `${event.minute}+${event.stoppage_minute}'`
        : `${event.minute}'`;
    const player = escapeHtml(event.player_name);
    const related = escapeHtml(event.related_player_name);

    switch (event.event_type) {
        case "goal":
            return `⚽ ${time} ${player} 进球${related ? `（助攻：${related}）` : ""}`;
        case "penalty_goal":
            return `⚽ ${time} ${player} 点球命中`;
        case "own_goal":
            return `⚠️ ${time} ${player} 乌龙球`;
        case "yellow_card":
            return `🟨 ${time} ${player} 黄牌`;
        case "red_card":
            return `🟥 ${time} ${player} 红牌`;
        case "substitution":
            return `🔁 ${time} ${player} 被换下，${related} 换上`;
        default:
            return `${time} ${player} ${event.event_type}`;
    }
}
