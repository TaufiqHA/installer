# Deskripsi UI — Automation Setup Wizard

## Gambaran Umum

**Nama Aplikasi:** Automation Setup Wizard  
**Versi:** 1.0.0  
**Platform:** Windows Desktop (Windows 11)  
**Tipe Window:** Floating dialog / wizard window dengan chrome khas Windows 11 (rounded corners, title bar dengan kontrol Maximize, Minimize, Close)

---

## Layout Keseluruhan

Window terbagi menjadi **dua kolom utama**:

```
┌─────────────────────────────────────────────────────────┐
│  Title Bar: [🔷 Automation Setup Wizard]   [⛶][─][✕]   │
├──────────────────┬──────────────────────────────────────┤
│                  │  Tab Bar: [Fresh Install] [Update Script] │
│  Sidebar Kiri    ├──────────────────────────────────────┤
│  (Monitoring     │  Panel Konten Kanan                  │
│   Console)       │  - Input fields                      │
│                  │  - .env editor                       │
│                  │  - Tombol aksi                       │
│  Version: 1.0.0  │                                      │
└──────────────────┴──────────────────────────────────────┘
```

### Proporsi Kolom
- **Kolom Kiri (Sidebar):** ~35% lebar window — menampung label versi dan Monitoring Console
- **Kolom Kanan (Main Content):** ~65% lebar window — menampung tab navigation dan form input

---

## Palet Warna

| Elemen | Warna | Keterangan |
|---|---|---|
| Background window | `#2c2f38` (abu-abu gelap, biru keabuan) | Dark mode, nuansa glassmorphism |
| Tab aktif ("Fresh Install") | `#4ecdc4` / Teal terang | Kontras tinggi di atas background gelap |
| Tab non-aktif ("Update Script") | Transparan / outline tipis | Teks putih |
| Input field | `#c8e6f0` / Biru muda pucat | Latar putih kebiruan, kontras dengan background gelap |
| Tombol "Browse" | `#3a7bd5` (Biru solid) | Tombol sekunder |
| Tombol "Mulai Fresh Install" | `#4ecdc4` / Teal (sama dengan tab aktif) | Tombol primer, full-width |
| Monitoring Console background | `#1e2130` (Biru sangat gelap / navy) | Lebih gelap dari background utama |
| Teks Monitoring Console | `#4ecdc4` / Teal muda | Monospace, mirip terminal output |
| Teks label form | `#ffffff` / Putih | Di atas background gelap |
| Title bar | Sama dengan background window | Tidak ada warna kontras khusus |
| Icon aplikasi | Biru (`#3a7bd5`) | Kotak dengan icon checklist/automation |

---

## Komponen UI — Detail per Bagian

### 1. Title Bar
- **Isi:** Icon aplikasi (biru, kotak kecil) + teks "Automation Setup Wizard" (bold, putih)
- **Kontrol window:** Tiga tombol di kanan atas — Maximize (`⛶`), Minimize (`─`), Close (`✕`) — ukuran standar Windows 11
- **Style:** Tidak ada gradien, flat dan bersih

---

### 2. Sidebar Kiri

#### Label Versi
- Teks kecil: `1.0.0`
- Warna: Putih/abu terang
- Posisi: Pojok kiri atas sidebar, rata kiri

#### Monitoring Console
- **Label:** "Monitoring Console" — teks putih, di atas kotak console
- **Kotak console:**
  - Background: `#1e2130` (navy gelap)
  - Border: Tipis, mungkin `#2e3450` atau tidak ada border eksplisit
  - Padding: ~12–16px
  - Rounded corners: Kecil (~4–6px)
- **Konten teks (log output):**
  - Font: Monospace (mirip Consolas atau Courier)
  - Ukuran: Kecil (~11–12px)
  - Warna: `#4ecdc4` (teal muda) — semua baris sama warnanya
  - Baris yang tampil:
    ```
    > Memulai validasi lingkungan sistem...
    > Memeriksa runtime Node.js...
    > [OK] Node.js Terdeteksi: v18.16.0
    > Memeriksa status database MongoDB...
    > [OK] MongoDB siap digunakan.
    > Mengunduh paket arsip script.zip...
    ```
  - Setiap baris diawali `>` sebagai prefix terminal

---

### 3. Tab Navigation (Kanan Atas)

- Dua tab: **"Fresh Install"** dan **"Update Script"**
- Desain tab: Pill / rounded rectangle
- **Tab aktif ("Fresh Install"):**
  - Background: `#4ecdc4` (teal solid)
  - Teks: Hitam atau putih gelap — kontras tinggi
  - Tidak ada border
- **Tab non-aktif ("Update Script"):**
  - Background: Transparan atau abu gelap
  - Teks: Putih
  - Border: Tipis teal atau abu
- Posisi: Full-width kolom kanan, rata atas panel konten

---

### 4. Form Input — Panel "Fresh Install"

Semua elemen form tersusun vertikal (stacked), dengan label di atas field.

#### a. Lokasi Folder Instalasi Target
- **Label:** "Lokasi Folder Instalasi Target" — teks putih kecil
- **Input field:**
  - Background: `#c8e6f0` (biru muda pucat / light blue)
  - Nilai default: `C:\Program Files\MyAutomationApp`
  - Teks: Gelap (hitam/charcoal)
  - Border: Tidak ada atau tipis
  - Rounded corners: ~4px
  - Tinggi: ~40px
  - Lebar: ~75% dari panel kanan
- **Tombol "Browse":**
  - Posisi: Rata kanan, sejajar dengan input field
  - Background: `#3a7bd5` (biru solid)
  - Teks: "Browse" — putih, bold
  - Lebar: ~15% dari panel kanan
  - Rounded corners: ~4px

#### b. URL Unduhan Script (.zip)
- **Label:** "URL Unduhan Script (.zip)" — teks putih kecil
- **Input field (textarea):**
  - Background: `#c8e6f0` (sama dengan field pertama)
  - Placeholder: `https://example.com/your-script.zip`
  - Teks placeholder: Abu-abu muda
  - Tinggi: ~60–70px (lebih tinggi dari field biasa)
  - Lebar: Full-width panel kanan
  - Resize handle: Ada di pojok kanan bawah (textarea)

#### c. Konfigurasi File .env
- **Label:** "Konfigurasi File .env" — teks putih kecil
- **Textarea:**
  - Background: `#c8e6f0` (sama)
  - Isi (pre-filled):
    ```
    PORT=3000
    DATABASE_URL=mongodb://localhost:27017/mydb
    API_KEY=your_secret_key
    ```
  - Font: Monospace
  - Tinggi: ~120px
  - Lebar: Full-width panel kanan
  - Resize handle: Ada

---

### 5. Tombol Aksi Utama

- **Teks:** "Mulai Fresh Install"
- **Posisi:** Bawah panel form, full-width (mengisi seluruh lebar kolom kanan)
- **Background:** `#4ecdc4` (teal, sama dengan tab aktif)
- **Teks:** Hitam atau putih gelap, bold, centered
- **Tinggi:** ~45–50px
- **Rounded corners:** ~6px

---

## Tipografi

| Elemen | Jenis Font | Ukuran | Weight |
|---|---|---|---|
| Title bar | Sans-serif (Segoe UI / system) | ~14px | Bold |
| Label form | Sans-serif | ~12px | Regular |
| Input teks | Sans-serif | ~13px | Regular |
| Console output | Monospace | ~11–12px | Regular |
| Tombol | Sans-serif | ~13–14px | SemiBold |
| Tab label | Sans-serif | ~13px | Medium/Bold |

---

## Nuansa Visual & Atmosfer

- **Tema:** Dark mode dengan aksen teal — mencerminkan tooling/developer tool
- **Gaya:** Modern flat dengan sedikit sentuhan glassmorphism pada background window (warna abu-biru yang kaya)
- **Background OS (wallpaper):** Windows 11 default — gradient biru-ungu dengan bentuk fluida/3D khas Windows 11
- **Kesan keseluruhan:** Profesional, utilitarian, bersih — cocok untuk developer/IT tool, bukan consumer app

---

## Catatan Aksesibilitas & UX

- Log console berjalan real-time (simulating installation steps)
- Dua tab memungkinkan user memilih antara instalasi baru atau update script yang sudah ada
- Field `.env` yang bisa diedit langsung memberi fleksibilitas konfigurasi sebelum install
- Tombol "Browse" memudahkan pemilihan folder tanpa mengetik path manual
