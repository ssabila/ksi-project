import { useEffect, useMemo, useState } from "react";

const API_URL = import.meta.env.VITE_API_URL || "/api";
const scoreFields = [["uts", "UTS"], ["uas", "UAS"], ["tugas", "Tugas"], ["praktikum", "Praktikum"]];
const emptyScores = { mahasiswa_id: "", uts: "", uas: "", tugas: "", praktikum: "" };

async function apiRequest(path, options = {}, token = "") {
  const headers = { ...(options.body instanceof FormData ? {} : { "Content-Type": "application/json" }), ...(options.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;
  const response = await fetch(`${API_URL}${path}`, { ...options, headers });
  const data = response.status === 204 ? null : await response.json();
  if (!response.ok) throw new Error(data?.error || "Permintaan gagal diproses");
  return data;
}

function App() {
  const [session, setSession] = useState(() => JSON.parse(localStorage.getItem("sdms_session") || "null"));
  const [view, setView] = useState(() => pathToView(window.location.pathname));
  const [status, setStatus] = useState("checking");
  const [message, setMessage] = useState("");

  useEffect(() => { fetch(`${API_URL}/health`).then((response) => setStatus(response.ok ? "online" : "offline")).catch(() => setStatus("offline")); }, []);
  useEffect(() => { const onPopState = () => setView(pathToView(window.location.pathname)); window.addEventListener("popstate", onPopState); return () => window.removeEventListener("popstate", onPopState); }, []);
  useEffect(() => { if (session?.user?.role === "admin" && !["overview", "students", "audit"].includes(view)) { window.history.replaceState({}, "", "/"); setView("overview"); } }, [session, view]);
  if (!session) return <AuthScreen onLogin={(data) => { localStorage.setItem("sdms_session", JSON.stringify(data)); setSession(data); }} />;

  const navigate = (path) => { window.history.pushState({}, "", path); setView(pathToView(path)); };
  const logout = () => { localStorage.removeItem("sdms_session"); setSession(null); navigate("/"); };
  return <Dashboard session={session} view={view} navigate={navigate} status={status} message={message} setMessage={setMessage} onLogout={logout} />;
}

function pathToView(pathname) {
  if (pathname.startsWith("/mahasiswa")) return "students";
  if (pathname.startsWith("/nilai")) return "scores";
  if (pathname.startsWith("/dokumen")) return "files";
  if (pathname.startsWith("/audit")) return "audit";
  return "overview";
}

function AuthScreen({ onLogin }) {
  const [mode, setMode] = useState("login");
  const [form, setForm] = useState({ username: "admin", password: "Admin123!" });
  const [error, setError] = useState("");
  const submit = async (event) => {
    event.preventDefault(); setError("");
    try {
      if (mode === "register") { await apiRequest("/auth/register", { method: "POST", body: JSON.stringify(form) }); setMode("login"); setError("Akun berhasil dibuat. Silakan masuk."); return; }
      onLogin(await apiRequest("/auth/login", { method: "POST", body: JSON.stringify(form) }));
    } catch (requestError) { setError(requestError.message === "Failed to fetch" ? "Backend tidak dapat dihubungi. Buka https://localhost:5000/api/health terlebih dahulu dan izinkan sertifikat lokal, lalu coba login lagi." : requestError.message); }
  };
  return <main className="auth-page"><div className="auth-art"><span className="brand-mark">S</span><p className="eyebrow">STUDENT DATA MANAGEMENT SYSTEM</p><h1>Data penting.<br /><em>Perlindungan berlapis.</em></h1><p>Ruang kerja aman untuk nilai, dokumen, dan jejak aktivitas akademik.</p></div><form className="auth-card" onSubmit={submit}><p className="section-kicker">{mode === "login" ? "Selamat datang kembali" : "Mulai sebagai mahasiswa"}</p><h2>{mode === "login" ? "Masuk ke SDMS" : "Buat akun"}</h2><label className="field"><span>Username</span><input value={form.username} onChange={(event) => setForm({ ...form, username: event.target.value })} required /></label><label className="field"><span>Password</span><input type="password" value={form.password} onChange={(event) => setForm({ ...form, password: event.target.value })} required /></label>{error && <p className="message error">{error}</p>}<button className="primary-button" type="submit">{mode === "login" ? "Masuk" : "Daftar"}<span>↗</span></button><button className="text-button" type="button" onClick={() => { setMode(mode === "login" ? "register" : "login"); setError(""); }}>{mode === "login" ? "Belum punya akun? Daftar" : "Sudah punya akun? Masuk"}</button>{mode === "login" && <small className="demo-note">Demo: admin / Admin123!, dosen / Dosen123!, mahasiswa / Mahasiswa123!</small>}</form></main>;
}

function Dashboard({ session, view, navigate, status, message, setMessage, onLogout }) {
  const { user, access_token: token } = session;
  const isStaff = user.role === "admin" || user.role === "dosen";
  const navigation = [{ id: "overview", path: "/", label: "Ringkasan" }, ...(isStaff ? [{ id: "students", path: "/mahasiswa", label: "Mahasiswa" }] : []), ...(user.role !== "admin" ? [{ id: "scores", path: "/nilai", label: "Nilai" }, { id: "files", path: "/dokumen", label: "Dokumen" }] : []), ...(user.role === "admin" ? [{ id: "audit", path: "/audit", label: "Audit log" }] : [])];
    const canInputScores = user.role === "dosen";
    return <main className="app-shell"><aside className="sidebar"><a className="brand" href="/" onClick={(event) => { event.preventDefault(); navigate("/"); }}><span className="brand-mark">S</span><span>SDMS</span></a><p className="nav-label">Workspace</p><nav>{navigation.map((item) => <button className={view === item.id ? "active" : ""} key={item.id} onClick={() => { navigate(item.path); setMessage(""); }}><span className="nav-index">0{navigation.indexOf(item) + 1}</span>{item.label}</button>)}</nav><div className="sidebar-bottom"><span className={`state-dot ${status}`} /> API {status === "online" ? "terhubung" : "terputus"}<button className="logout" onClick={onLogout}>Keluar <span>↗</span></button></div></aside><section className="content"><header className="content-header"><div><p className="eyebrow">SECURE ACADEMIC WORKSPACE</p><h1>{navigation.find((item) => item.id === view)?.label}</h1></div><div className="user-chip"><span className="avatar">{user.username[0].toUpperCase()}</span><span><strong>{user.username}</strong><small>{user.role}</small></span></div></header>{message && <p className="toast success">{message}</p>}{view === "overview" && <Overview user={user} token={token} isStaff={isStaff} navigate={navigate} />}{view === "students" && <Students token={token} navigate={navigate} canInputScores={canInputScores} setMessage={setMessage} />}{view === "scores" && <Scores user={user} token={token} canInputScores={canInputScores} setMessage={setMessage} />}{view === "files" && <Files user={user} token={token} setMessage={setMessage} />}{view === "audit" && <Audit token={token} />}</section></main>;
}

function Overview({ user, token, isStaff, navigate }) {
  const [records, setRecords] = useState([]); const [files, setFiles] = useState([]);
  useEffect(() => { Promise.all([apiRequest(`/nilai/${user.id}`, {}, token).catch(() => []), apiRequest("/files", {}, token).catch(() => [])]).then(([scores, documents]) => { setRecords(scores); setFiles(documents); }); }, [user.id, token]);
  const average = records.length ? Math.round((records[0].uts + records[0].uas + records[0].tugas + records[0].praktikum) / 4) : "-";
  return <><div className="welcome"><div><span className="section-kicker">Selamat datang, {user.username}</span><h2>{isStaff ? "Pantau keamanan dan data akademik." : "Semua data akademikmu, tertata."}</h2></div><span className="shield">✦</span></div><div className="stat-grid"><Stat label="Nilai tersimpan" value={records.length} /><Stat label="Rata-rata terbaru" value={average} /><Stat label="Dokumen aman" value={files.length} /></div><div className="quick-panel"><div><p className="section-kicker">Lapisan aktif</p><h3>Perlindungan sistem berjalan.</h3><p>Password di-hash dengan bcrypt, nilai disimpan AES-GCM, dan dokumen memakai enkripsi hybrid AES + RSA.</p></div><button className="outline-button" onClick={() => navigate("/dokumen")}>Kelola dokumen <span>↗</span></button></div></>;
}
function Stat({ label, value }) { return <div className="stat"><small>{label}</small><strong>{value}</strong></div>; }

function Students({ token, navigate, canInputScores, setMessage }) {
  const [students, setStudents] = useState([]);
  useEffect(() => { apiRequest("/mahasiswa", {}, token).then(setStudents).catch((error) => setMessage(error.message)); }, [token, setMessage]);
  return <section className="panel students-panel"><div className="panel-heading"><div><p className="section-kicker">Direktori akademik</p><h2>Daftar mahasiswa</h2></div><span className="record-count">{students.length} mahasiswa</span></div><p className="panel-description">Daftar ini dapat dilihat dosen dan admin. Dosen dapat memilih mahasiswa untuk input nilai.</p><div className="student-list">{students.map((student) => <button className="student-row" key={student.id} onClick={() => canInputScores && navigate(`/nilai?mahasiswa=${student.id}`)} disabled={!canInputScores}><span className="avatar">{student.username[0].toUpperCase()}</span><span><strong>{student.username}</strong><small>ID mahasiswa: {student.id}</small></span><span className="student-action">{canInputScores ? "Input nilai ↗" : "Terdaftar"}</span></button>)}</div>{!students.length && <div className="empty-state"><span>∅</span><p>Belum ada data mahasiswa. Jalankan `backend/dummy_mahasiswa.sql`.</p></div>}</section>;
}

function Scores({ user, token, canInputScores, setMessage }) {
  const initialStudentId = new URLSearchParams(window.location.search).get("mahasiswa") || String(user.id);
  const [studentId, setStudentId] = useState(initialStudentId); const [records, setRecords] = useState([]); const [form, setForm] = useState({ ...emptyScores, mahasiswa_id: initialStudentId }); const [loading, setLoading] = useState(false);
  const load = async (event) => { event?.preventDefault(); try { setRecords(await apiRequest(`/nilai/${studentId}`, {}, token)); } catch (error) { setMessage(error.message); } };
  useEffect(() => { load(); }, []);
  const submit = async (event) => { event.preventDefault(); setLoading(true); try { await apiRequest("/nilai", { method: "POST", body: JSON.stringify(Object.fromEntries(Object.entries(form).map(([key, value]) => [key, Number(value)]))) }, token); setMessage("Nilai tersimpan dalam bentuk ciphertext AES-GCM."); setForm({ ...form, uts: "", uas: "", tugas: "", praktikum: "" }); await load(); } catch (error) { setMessage(error.message); } finally { setLoading(false); } };
  return <div className="split-view">{canInputScores && <form className="panel" onSubmit={submit}><div className="panel-heading"><div><p className="section-kicker">Enkripsi AES-GCM</p><h2>Input nilai</h2></div></div><label className="field"><span>ID Mahasiswa</span><input type="number" min="1" value={form.mahasiswa_id} onChange={(event) => setForm({ ...form, mahasiswa_id: event.target.value })} required /></label><div className="score-grid">{scoreFields.map(([name, label]) => <label className="field" key={name}><span>{label}</span><input type="number" min="0" max="100" value={form[name]} onChange={(event) => setForm({ ...form, [name]: event.target.value })} required /></label>)}</div><button className="primary-button" disabled={loading}>{loading ? "Menyimpan..." : "Simpan nilai"}<span>↗</span></button></form>}<section className="panel"><div className="panel-heading"><div><p className="section-kicker">{canInputScores ? "Data terdekripsi saat response" : "Mode lihat saja"}</p><h2>Riwayat nilai</h2></div><span className="record-count">{records.length} catatan</span></div><form className="lookup" onSubmit={load}><input type="number" value={studentId} onChange={(event) => setStudentId(event.target.value)} disabled={!canInputScores && user.role === "mahasiswa"} /><button type="submit">Lihat</button></form>{records.length ? <div className="records">{records.map((record) => <article className="record" key={record.id}><div className="record-topline"><strong>Mahasiswa #{record.mahasiswa_id}</strong><span>{new Date(record.created_at).toLocaleDateString("id-ID")}</span></div><div className="score-row">{scoreFields.map(([name, label]) => <span key={name}><small>{label}</small><b>{record[name]}</b></span>)}<span className="average"><small>Rata-rata</small><b>{Math.round((record.uts + record.uas + record.tugas + record.praktikum) / 4)}</b></span></div></article>)}</div> : <div className="empty-state"><span>∅</span><p>Belum ada data nilai.</p></div>}</section></div>;
}

function Files({ user, token, setMessage }) {
  const [files, setFiles] = useState([]);
  const [selected, setSelected] = useState(null);
  const canUpload = user.role === "mahasiswa";
  const load = () => apiRequest("/files", {}, token).then(setFiles).catch((error) => setMessage(error.message));
  useEffect(() => { load(); }, []);
  const download = async (file) => {
    try {
      const downloadPath = file.download_url.replace(/^\/api/, "");
      const response = await fetch(`${API_URL}${downloadPath}`, { headers: { Authorization: `Bearer ${token}` } });
      if (!response.ok) {
        let message = "Download ditolak";
        try { message = (await response.json()).error || message; } catch { /* Response is a file or empty. */ }
        throw new Error(message);
      }
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = file.original_name;
      anchor.style.display = "none";
      document.body.appendChild(anchor);
      anchor.click();
      anchor.remove();
      window.setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch (error) {
      setMessage(error.message === "Failed to fetch"
        ? "Download gagal terhubung ke backend. Buka https://localhost:5000/api/health dan izinkan sertifikat lokal, lalu coba lagi."
        : error.message);
    }
  };
  const upload = async (event) => { event.preventDefault(); if (!selected) return; const body = new FormData(); body.append("mahasiswa_id", user.id); body.append("file", selected); try { await apiRequest("/files", { method: "POST", body }, token); setSelected(null); event.target.reset(); setMessage("Dokumen berhasil dienkripsi dan disimpan."); load(); } catch (error) { setMessage(error.message); } };
  return <div className="file-layout">{canUpload ? <form className="panel upload-panel" onSubmit={upload}><p className="section-kicker">Upload mahasiswa</p><h2>Amankan dokumen</h2><p>Upload dokumen milikmu. Isi file dienkripsi AES-GCM dan kunci AES dibungkus RSA.</p><label className="file-drop"><input type="file" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.txt" onChange={(event) => setSelected(event.target.files[0])} /><strong>{selected ? selected.name : "Pilih file untuk diunggah"}</strong><small>Maksimal 10 MB · PDF, DOCX, JPG, PNG, TXT</small></label><button className="primary-button" disabled={!selected}>Upload terenkripsi <span>↗</span></button></form> : <section className="panel permission-panel"><p className="section-kicker">Mode monitoring</p><h2>Dokumen mahasiswa</h2><p>Role <strong>{user.role}</strong> dapat melihat dan mengunduh dokumen untuk verifikasi. Upload dilakukan oleh mahasiswa pemilik dokumen.</p><div className="permission-note"><span>✓</span><span>File tersimpan sebagai ciphertext<br /><small>Download akan didekripsi hanya setelah akses diizinkan.</small></span></div></section>}<section className="panel"><div className="panel-heading"><div><p className="section-kicker">RSA key envelope</p><h2>Dokumen tersimpan</h2></div><span className="record-count">{files.length} file</span></div>{files.length ? <div className="file-list">{files.map((file) => <div className="file-item" key={file.id}><span className="file-icon">⌁</span><span><strong>{file.original_name}</strong><small>Mahasiswa #{file.mahasiswa_id} · {new Date(file.created_at).toLocaleDateString("id-ID")}</small></span><button title="Download dan dekripsi" onClick={() => download(file)}>↓</button></div>)}</div> : <div className="empty-state"><span>∅</span><p>Belum ada dokumen.</p></div>}</section></div>;
}

function Audit({ token }) { const [logs, setLogs] = useState([]); useEffect(() => { apiRequest("/audit", {}, token).then(setLogs); }, [token]); return <section className="panel audit-panel"><div className="panel-heading"><div><p className="section-kicker">Immutable activity trail</p><h2>Audit log</h2></div><span className="record-count">100 terbaru</span></div><div className="audit-list">{logs.map((log) => <div className="audit-row" key={log.id}><span className={`audit-status ${log.status.toLowerCase()}`}>{log.status}</span><strong>{log.action}</strong><span>{log.object || "-"}</span><small>{new Date(log.timestamp).toLocaleString("id-ID")}</small></div>)}</div></section>; }

export default App;
