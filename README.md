# MyApp Windows Installer — Panduan Lengkap

## Struktur File

```
project/
├── MyApp_Setup.iss       ← Inno Setup script (kompilasi jadi .exe)
├── scripts/
│   ├── install.ps1       ← Logika instalasi utama
│   └── update.ps1        ← Script updater (dibundel ke app folder)
├── assets/
│   └── app.ico           ← Icon installer (opsional)
└── dist/
    └── MyApp_Installer.exe  ← Output hasil kompilasi
```

---

## Tools yang Dibutuhkan (di mesin developer)

| Tool | Link | Keterangan |
|------|------|------------|
| **Inno Setup 6.x** | https://jrsoftware.org/isdl.php | Gratis, untuk kompilasi .iss → .exe |
| Text editor | VS Code / Notepad++ | Edit script .iss dan .ps1 |

---

## Langkah Membuat Installer

### 1. Sesuaikan konfigurasi di `MyApp_Setup.iss`

Buka file `MyApp_Setup.iss`, ubah bagian ini:

```pascal
#define AppName      "MyApp"           ← nama aplikasi Anda
#define AppVersion   "1.0.0"
#define AppPublisher "Your Company"
#define ZipUrl       "https://example.com/app.zip"  ← URL ZIP script Anda
```

Juga ganti `AppId` dengan GUID baru (bisa generate di https://www.guidgenerator.com):
```pascal
AppId={{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}}
```

### 2. Sesuaikan `scripts/install.ps1`

Pastikan `$ZipUrl` default dan nama PM2 app (`myapp`) sesuai kebutuhan Anda.

### 3. Kompilasi

- Buka **Inno Setup Compiler**
- File → Open → pilih `MyApp_Setup.iss`
- Klik tombol **Compile** (atau tekan `F9`)
- Output: `dist/MyApp_Installer.exe`

---

## Cara Penggunaan Installer (di mesin end-user)

### Install

1. Klik kanan `MyApp_Installer.exe` → **Run as Administrator**
2. Ikuti wizard:
   - Pilih **lokasi instalasi** (default: `C:\Program Files\MyApp`)
   - Masukkan **Port Aplikasi** (default: 3000)
   - Masukkan **Port MongoDB** (default: 27017)
3. Klik Install — proses otomatis:
   - ✅ Cek & install Node.js
   - ✅ Cek & install MongoDB
   - ✅ Download & extract script ZIP
   - ✅ Buat file `.env`
   - ✅ `npm install`
   - ✅ Install PM2 & jalankan aplikasi
4. Setelah selesai, akses di `http://localhost:PORT`

### Update

**Cara 1:** Via Start Menu → `Update MyApp`

**Cara 2:** Buka folder instalasi, klik kanan `update.ps1` → **Run with PowerShell**

**Cara 3:** Command line:
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Program Files\MyApp\update.ps1"
```

Proses update:
- ✅ Download ZIP terbaru
- ✅ `npm install`
- ✅ `pm2 restart`

---

## Kustomisasi Lanjutan

### Mengubah URL ZIP saat update
Edit baris pertama `update.ps1` di folder instalasi:
```powershell
param(
    [string]$ZipUrl = "https://YOUR-NEW-URL/app.zip"
)
```

### Menambah variabel .env
Di `install.ps1`, tambahkan di bagian `Create-Env`:
```powershell
$content = @"
PORT=$AppPort
MONGO_URI=mongodb://localhost:$MongoPort/myapp
JWT_SECRET=changeme
NODE_ENV=production
"@
```

### Bundel Node.js offline (tanpa internet)
Unduh Node.js MSI ke folder `assets/`, lalu di `install.ps1`:
```powershell
# Ganti winget dengan:
Start-Process -Wait -FilePath "{tmp}\node-installer.msi" -ArgumentList "/quiet"
```
Dan di `.iss` tambahkan:
```pascal
Source: "assets\node-installer.msi"; DestDir: "{tmp}"
```

---

## FAQ

**Q: User tidak punya internet saat install?**
A: Bundel Node.js MSI + MongoDB MSI + file ZIP ke dalam installer. Ubah script untuk install dari file lokal `{tmp}` bukan download.

**Q: PM2 tidak jalan otomatis setelah restart Windows?**
A: Jalankan sekali manual: `pm2 startup` → copy paste perintah yang muncul → `pm2 save`

**Q: Port sudah dipakai?**
A: Installer akan menanyakan port saat wizard — user bisa ganti ke port lain.
