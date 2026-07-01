from pathlib import Path
import re

BASE = Path(".")
app_path = BASE / "app.py"
frontend_dir = BASE / "frontend"
admin_path = frontend_dir / "admin.html"
login_path = frontend_dir / "admin-login.html"

if not app_path.exists():
    raise FileNotFoundError("找不到 app.py，请在项目根目录运行。")

if not frontend_dir.exists():
    raise FileNotFoundError("找不到 frontend 文件夹。")

if not admin_path.exists():
    raise FileNotFoundError("找不到 frontend/admin.html。")

# 备份
(app_path.with_suffix(".before_admin_login.py")).write_text(
    app_path.read_text(encoding="utf-8", errors="ignore"),
    encoding="utf-8"
)

(admin_path.with_name("admin.before_admin_login.html")).write_text(
    admin_path.read_text(encoding="utf-8", errors="ignore"),
    encoding="utf-8"
)

# ========== 1. 修改 app.py ==========
s = app_path.read_text(encoding="utf-8", errors="ignore")

# 1.1 Flask import 增加 session / redirect
s = s.replace(
    "from flask import Flask, jsonify, request",
    "from flask import Flask, jsonify, request, session, redirect"
)

# 1.2 增加 app.secret_key
if "app.secret_key" not in s:
    s = s.replace(
        'static_url_path="",\n)\n\nALLOWED_MATCH_STATUS',
        'static_url_path="",\n)\n\napp.secret_key = os.environ.get("SECRET_KEY", "football-manager-dev-secret")\n\nALLOWED_MATCH_STATUS'
    )

# 1.3 替换 require_admin
new_require_admin = '''def require_admin(func: F) -> F:
    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any):
        supplied = request.headers.get("X-Admin-Key", "")
        session_ok = session.get("is_admin") is True
        key_ok = bool(ADMIN_KEY) and hmac.compare_digest(supplied, ADMIN_KEY)

        if not (session_ok or key_ok):
            return jsonify({"error": "未登录或管理员密钥无效"}), 401

        return func(*args, **kwargs)

    return wrapper  # type: ignore[return-value]
'''

s = re.sub(
    r"def require_admin\(func: F\) -> F:[\s\S]*?return wrapper\s*# type: ignore\[return-value\]\n",
    new_require_admin,
    s,
    count=1
)

# 1.4 新增后台登录路由和受保护后台页面
admin_routes = '''
@app.get("/admin-login.html")
def admin_login_page():
    return app.send_static_file("admin-login.html")


@app.post("/api/admin/login")
def admin_login():
    data = request.get_json(silent=True) or {}
    admin_key = str(data.get("admin_key", "")).strip()

    if not ADMIN_KEY or not hmac.compare_digest(admin_key, ADMIN_KEY):
        return jsonify({"error": "管理员密钥错误"}), 401

    session["is_admin"] = True
    return jsonify({"message": "登录成功"})


@app.post("/api/admin/logout")
def admin_logout():
    session.clear()
    return jsonify({"message": "已退出后台"})


@app.get("/admin.html")
def admin_page():
    if session.get("is_admin") is not True:
        return redirect("/admin-login.html")

    return app.send_static_file("admin.html")


'''

if '@app.get("/admin-login.html")' not in s:
    s = s.replace('@app.route("/")', admin_routes + '@app.route("/")', 1)

app_path.write_text(s, encoding="utf-8")


# ========== 2. 新建 admin-login.html ==========
login_html = '''<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>后台登录</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
<main class="container">
  <section class="card" style="max-width: 520px; margin: 80px auto;">
    <h1 class="page-title">后台管理登录</h1>
    <p class="subtitle">请输入管理员密钥后进入后台管理页面。</p>

    <div class="field">
      <label>管理员密钥</label>
      <input id="adminKey" type="password" placeholder="请输入管理员密钥" autocomplete="current-password">
    </div>

    <div class="form-actions">
      <button onclick="loginAdmin()">登录</button>
      <a class="button secondary" href="/index.html">返回前台</a>
    </div>

    <div id="loginNotice"></div>
  </section>
</main>

<script>
async function loginAdmin() {
  const key = document.getElementById("adminKey").value;

  try {
    const res = await fetch("/api/admin/login", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      credentials: "same-origin",
      body: JSON.stringify({admin_key: key})
    });

    const data = await res.json();

    if (!res.ok) {
      throw new Error(data.error || "登录失败");
    }

    location.href = "/admin.html";
  } catch (e) {
    document.getElementById("loginNotice").innerHTML =
      `<div class="notice error">${e.message}</div>`;
  }
}

document.getElementById("adminKey").addEventListener("keydown", e => {
  if (e.key === "Enter") {
    loginAdmin();
  }
});
</script>
</body>
</html>
'''

login_path.write_text(login_html, encoding="utf-8")


# ========== 3. 修改 admin.html ==========
admin = admin_path.read_text(encoding="utf-8", errors="ignore")

# 3.1 删除顶部密钥输入框，换成重算 + 退出
admin = re.sub(
    r'''<section class="card">\s*
\s*<div class="toolbar">[\s\S]*?管理员密钥[\s\S]*?<div id="globalNotice"></div>\s*
\s*</section>''',
    '''<section class="card">
    <div class="toolbar">
      <button class="secondary" onclick="recalculate()">全量重算统计</button>
      <button class="danger" onclick="logoutAdmin()">退出后台</button>
    </div>
    <div id="globalNotice"></div>
  </section>''',
    admin,
    count=1
)

# 3.2 删除旧的 adminKey 初始化语句
admin = admin.replace('document.getElementById("adminKey").value = adminKey();', "")

# 3.3 删除旧 saveKey 函数
admin = re.sub(
    r'''function saveKey\(\)\s*\{[\s\S]*?\n\}''',
    "",
    admin,
    count=1
)

# 3.4 添加 logoutAdmin 函数
logout_func = '''
async function logoutAdmin() {
  try {
    await api("/admin/logout", {method: "POST"});
  } finally {
    location.href = "/admin-login.html";
  }
}
'''

if "function logoutAdmin" not in admin:
    admin = admin.replace("async function recalculate()", logout_func + "\nasync function recalculate()", 1)

admin_path.write_text(admin, encoding="utf-8")


# ========== 4. 从普通页面移除后台入口 ==========
for p in frontend_dir.glob("*.html"):
    if p.name in {"admin.html", "admin-login.html"}:
        continue

    html = p.read_text(encoding="utf-8", errors="ignore")
    html = html.replace('  <a href="/admin.html">后台管理</a>\n', "")
    html = html.replace('<a href="/admin.html">后台管理</a>', "")
    p.write_text(html, encoding="utf-8")

print("修改完成：")
print("1. app.py 已加入后台登录 session")
print("2. frontend/admin-login.html 已创建")
print("3. frontend/admin.html 已移除密钥输入框")
print("4. 普通页面已移除后台入口")
print("备份文件：app.before_admin_login.py / frontend/admin.before_admin_login.html")
