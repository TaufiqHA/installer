# Bug: Instalasi Gagal dengan Kode -1073741510 dan Entry Point Tidak Ditemukan

## Deskripsi Masalah
Saat melakukan instalasi, Anda mengalami dua masalah sekaligus:
1. Muncul error: `Instalasi Gagal dengan kode: -1073741510`
2. Di dalam log (atau di layar), terdapat pesan bahwa *Entry point tidak ditemukan di folder installnya*.

**Penyebab Pertama (Kode -1073741510):**
Kode `-1073741510` (secara *hexadecimal* adalah `0xC000013A` atau `STATUS_CONTROL_C_EXIT`) muncul jika jendela Command Prompt (PowerShell) **ditutup secara paksa** (klik tanda X) sebelum Inno Setup selesai membacanya. Ini terjadi karena pada perbaikan sebelumnya, kita secara tidak sengaja meninggalkan *flag* `-NoExit` di parameter eksekusi. Akibatnya, jendela PowerShell tidak mau menutup sendiri secara otomatis setelah selesai/error, dan saat Anda menutupnya secara manual, Inno Setup mendeteksi adanya penutupan paksa.

**Penyebab Kedua (Entry Point Tidak Ditemukan):**
Script gagal menemukan file seperti `app.js` atau `index.js` karena file ZIP yang saat ini sedang diunduh (tercantum di *placeholder* input URL) adalah `https://nodejs.org/dist/v24.15.0/node-v24.15.0-win-x64.zip`. Itu adalah file biner/aplikasi dari bahasa pemrograman **Node.js itu sendiri**, **BUKAN** kode sumber/aplikasi buatan Anda. Jadi, setelah terekstrak, tidak ada file `app.js` di dalamnya (isinya adalah `node.exe`, `npm.cmd`, dll).

---

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

### 1. Modifikasi `MyApp_Setup.iss` (Menghapus `-NoExit`)
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

1. Buka file `MyApp_Setup.iss`.
2. Cari bagian _procedure_ `RunInstallScript`.
3. Hapus tulisan `-NoExit ` pada baris pembuatan `Params`.

**Diff Perubahan:**
```pascal
@@ -xxx,xxx @@ begin
   // EKSTRAK FILE SCRIPT SEBELUM MENJALANKAN (Karena kita bypass default UI Inno Setup)
   ExtractTemporaryFile('install.ps1');
   
-  Params := '-NoExit -ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
+  Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
             ' -InstallDir "' + InstallDirEdit.Text + '"' +
             ' -ZipUrl "' + SafeUrl + '"' +
```

### 2. Gunakan URL Aplikasi yang Benar (Bukan URL Node.js)
Saat menjalankan Installer (setelah di-compile), pastikan Anda mengganti isian **URL Unduhan Script (.zip)** dengan URL yang berisi *source code* aplikasi Express/Node.js milik Anda sendiri yang memiliki file `app.js` atau `index.js` di dalamnya.

Jika Anda hanya ingin mencoba agar instalasi lolos (berhasil):
Anda dapat mengosongkan pengecekan di `install.ps1` secara sementara, atau membuat file dummy ZIP yang berisi satu buah file `app.js`.

Namun, solusi terbaiknya adalah menggunakan file `.zip` dari repository aplikasi target Anda yang asli.

## Verifikasi
1. Terapkan perubahan pada `MyApp_Setup.iss` untuk menghapus `-NoExit`.
2. Lakukan *Compile* ulang (F9).
3. Jalankan installer. Saat instalasi gagal (misalnya karena entry point tidak ada), jendela hitam akan menutup sendiri secara otomatis.
4. Karena jendela tertutup secara normal oleh script (menggunakan `exit 1`), pesan yang akan muncul di aplikasi installer adalah `Instalasi Gagal dengan kode: 1` (bukan -1073741510).
5. Masukkan URL `.zip` aplikasi yang valid, maka instalasi akan berjalan sukses 100%.
