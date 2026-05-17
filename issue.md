# Bug: npm error code ENOENT (Error Terjadi Lagi di folder `testing`)

## Deskripsi Masalah
Anda mengalami error `npm error code ENOENT` (file `package.json` tidak ditemukan) dengan path target `C:\Program Files\testing\package.json`. Padahal, pada perbaikan sebelumnya, kita sudah menambahkan pengecekan (validasi) `package.json` agar `npm install` tidak dijalankan jika filenya tidak ada.

**Penyebab:**
Jika error ini masih muncul, kemungkinan besar Anda sedang menjalankan atau menguji script **`update.ps1`** (misalnya lewat shortcut Update di Start Menu, atau menjalankan langsung file `update.ps1` di folder instalasi).
Pada perbaikan-perbaikan sebelumnya, kita **hanya** menambal script utama yaitu `scripts/install.ps1`. File script `scripts/update.ps1` yang berdiri sendiri (standalone updater) belum mendapatkan perbaikan logika untuk mengatasi struktur folder ZIP (wrapper folder) maupun pengecekan `package.json`. Akibatnya, saat `update.ps1` dijalankan, ia akan mengekstrak file lalu langsung memaksa `npm install` tanpa mempedulikan apakah `package.json` benar-benar ada, sehingga menyebabkan *crash* `ENOENT`.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Kita perlu menyamakan logika (sinkronisasi) perbaikan dari `install.ps1` ke dalam `update.ps1`. Yaitu dengan menambahkan deteksi *wrapper folder* dan memvalidasi `package.json` sebelum `npm install`.

### Modifikasi `scripts/update.ps1`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/scripts/update.ps1`

1. Buka file `scripts/update.ps1`.
2. Di bagian `# ── 2. Extract (overwrite)`, tambahkan logika pendeteksi *wrapper folder* (sama seperti di `install.ps1`).
3. Di bagian `# ── 3. npm install`, tambahkan validasi `Test-Path` sebelum menjalankan `npm install`.

**Diff Perubahan:**
```powershell
@@ -xxx,xxx @@ Log "Mengextract ke $InstallDir ..."
 try {
     Expand-Archive -Path $zipPath -DestinationPath $InstallDir -Force
     Ok "Extract selesai."
+
+    # Periksa apakah hasil ekstrak terbungkus di dalam satu subfolder tunggal
+    $subdirs = Get-ChildItem -Path $InstallDir -Directory
+    $files = Get-ChildItem -Path $InstallDir -File
+    if ($subdirs.Count -eq 1 -and $files.Count -eq 0) {
+        $wrapper = $subdirs[0].FullName
+        Log "Mendeteksi folder pembungkus ($($subdirs[0].Name)), memindahkan isi ke root..."
+        Move-Item -Path "$wrapper\*" -Destination $InstallDir -Force
+        Remove-Item -Path $wrapper -Force
+    }
 } catch {
     Err "Gagal extract: $_"
 }
 Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
 
 # ── 3. npm install ───────────────────────────────────────────
+if (-not (Test-Path "$InstallDir\package.json")) {
+    Log "File package.json tidak ditemukan di $InstallDir. Melewati proses npm install."
+} else {
     Log "Menjalankan npm install ..."
     Push-Location $InstallDir
     try {
         & npm install --omit=dev 2>&1 | Tee-Object -FilePath "$InstallDir\npm-update.log"
         Ok "npm install selesai."
     } catch {
         Err "npm install gagal: $_"
     } finally {
         Pop-Location
     }
+}
```

## Verifikasi
1. Terapkan perubahan di atas pada `scripts/update.ps1`.
2. Jika Anda masih menggunakan URL Node.js bawaan (`node-v24...zip`) untuk pengetesan, pastikan untuk menggantinya dengan URL *source code* aplikasi Anda sendiri yang memiliki `package.json` yang sah.
3. Coba jalankan ulang shortcut Update aplikasi atau script `update.ps1`. Jika file ZIP tidak memiliki `package.json`, ia akan memunculkan log info "*Melewati proses npm install*" secara aman dan tidak lagi mengalami *crash ENOENT*.
