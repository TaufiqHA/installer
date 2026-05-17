# Bug: Instalasi Gagal dengan Kode 1

## Deskripsi Masalah
Saat proses instalasi berjalan, installer menampilkan pesan:
`Instalasi Gagal dengan kode: 1`

**Penyebab:**
Kode exit `1` bukanlah pesan error spesifik dari Inno Setup, melainkan berasal dari script PowerShell (`scripts/install.ps1`). Di dalam script tersebut, fungsi `Err` dirancang untuk menghentikan eksekusi dengan perintah `exit 1` apabila terjadi kegagalan (misalnya gagal download ZIP, gagal install Node.js/MongoDB via winget, atau `npm install` gagal).
Masalah utamanya adalah jendela *Command Prompt* (PowerShell) langsung tertutup begitu error terjadi, sehingga kita tidak bisa melihat pesan error aslinya.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Untuk mengetahui error yang sebenarnya (dan kemudian memperbaikinya), kita perlu menambahkan fitur pencatatan log (Transcript) pada script `install.ps1`.

### Modifikasi `scripts/install.ps1`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/scripts/install.ps1`

1. Buka file `install.ps1`.
2. Pada bagian paling atas, tepat setelah blok `param(...)`, tambahkan perintah `Start-Transcript` untuk mencatat semua proses ke dalam file teks.
3. Pada bagian paling bawah script, tambahkan `Stop-Transcript`.

**Diff Perubahan:**
```powershell
@@ -13,6 +13,9 @@ param(
     [switch]$UpdateMode  = $false
 )
 
+# Tambahkan ini untuk mencatat log ke folder TEMP Windows
+Start-Transcript -Path "$env:TEMP\MyApp_Install_Log.txt" -Append
+
 # ── Helpers ─────────────────────────────────────────────────
 function Log($msg) { Write-Host "[INFO]  $msg" }
 function Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }
@@ -183,4 +186,7 @@ if ($UpdateMode) {
     Install-App
 }
 
+# Hentikan pencatatan log
+Stop-Transcript
+
 Log "Semua proses selesai."
```

## Verifikasi & Debugging Lanjutan
1. Simpan file `install.ps1`.
2. Jika perlu, Anda juga dapat mengubah file `MyApp_Setup.iss` dengan menambahkan `-NoExit` pada baris argumen powershell (hanya untuk sementara saat testing) agar jendela hitam tidak langsung tertutup:
   ```pascal
   Params := '-NoExit -ExecutionPolicy Bypass -File "' + ...
   ```
3. Lakukan kompilasi ulang Inno Setup (tekan F9) dan jalankan installer kembali.
4. Ketika instalasi gagal dengan kode 1, buka file log di lokasi berikut (copas ke File Explorer):
   `%TEMP%\MyApp_Install_Log.txt`
5. Baca baris terakhir yang mengandung teks `[ERROR]`. Dari situ, Anda akan mengetahui penyebab pasti kegagalannya (misal: "Gagal download update", "winget tidak ditemukan", dsb) dan dapat memperbaiki sumber masalah yang spesifik.
