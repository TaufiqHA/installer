# Bug: npm error code ENOENT (package.json Tidak Ditemukan)

## Deskripsi Masalah
Saat proses instalasi mencapai tahap *npm install*, muncul error di log (atau di console PowerShell) seperti berikut:
```text
npm error code ENOENT
npm error syscall open
npm error path C:\Program Files\MyApp\package.json
npm error errno -4058
npm error enoent Could not read package.json: Error: ENOENT: no such file or directory
```
**Penyebab:**
Script mencoba menjalankan perintah `npm install` di dalam folder `$InstallDir` (misalnya `C:\Program Files\MyApp`), namun file `package.json` tidak ada di folder tersebut. 
Hal ini terjadi karena file ZIP yang diunduh (tergantung dari input URL `ZipUrl`) tidak berisi aplikasi Node.js yang sah (tidak memiliki `package.json`). Contohnya, jika menggunakan URL bawaan `node-v24.15.0-win-x64.zip`, itu adalah biner Node.js dan bukan aplikasi Anda. Akibatnya, `npm install` gagal karena tidak tahu apa yang harus di-install.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Untuk mencegah instalasi gagal (crash) secara keseluruhan hanya karena tidak ada `package.json`, kita perlu menambahkan pengecekan (validasi) file `package.json` sebelum menjalankan `npm install`.

### Modifikasi `scripts/install.ps1`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/scripts/install.ps1`

1. Buka file `scripts/install.ps1`.
2. Cari definisi fungsi `Run-NpmInstall`.
3. Tambahkan logika `Test-Path` di bagian paling awal fungsi tersebut untuk mengecek keberadaan `package.json`. Jika tidak ada, catat pesan log dan keluar dari fungsi tanpa menjalankan `npm install`.

**Diff Perubahan:**
```powershell
@@ -xxx,xxx @@ function Create-Env {
 
 # ── 5. npm install ──────────────────────────────────────────
 function Run-NpmInstall {
+    if (-not (Test-Path "$InstallDir\package.json")) {
+        Log "File package.json tidak ditemukan di $InstallDir. Melewati proses npm install."
+        return
+    }
+
     Log "Menjalankan npm install di $InstallDir ..."
     Push-Location $InstallDir
     try {
         & npm install --omit=dev 2>&1 | Tee-Object -FilePath "$InstallDir\npm-install.log"
         Ok "npm install selesai."
```

### Catatan Tambahan (Sangat Penting):
Error ini juga menjadi pertanda kuat bahwa Anda **memasukkan URL ZIP yang salah** saat melakukan instalasi. Pastikan kolom **URL Unduhan Script (.zip)** diisi dengan *link* `.zip` *source code* aplikasi Anda yang sesungguhnya (yang memiliki `package.json` dan `app.js` di dalamnya).

## Verifikasi
1. Terapkan perubahan pada `install.ps1` di atas.
2. Compile ulang installer Inno Setup (F9).
3. Jalankan installer. Jika file ZIP yang diunduh memang tidak memiliki `package.json`, Anda hanya akan melihat log "*File package.json tidak ditemukan... Melewati proses npm install*" dan proses instalasi tidak akan mengalami error *crash* atau *exit code 1* pada tahap tersebut.
