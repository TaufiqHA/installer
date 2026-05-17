# Bug: Entry Point (app.js/index.js/server.js) Tidak Ditemukan

## Deskripsi Masalah
Saat proses instalasi mencapai tahap *Setup PM2*, instalasi gagal dan muncul log error berikut:
`[ERROR] Entry point (app.js/index.js/server.js) tidak ditemukan di C:\Program Files\MyApp`

**Penyebab:**
Masalah ini sangat umum terjadi akibat **struktur file ZIP** yang diunduh. Biasanya, saat kita mengompres (ZIP) sebuah aplikasi, kita mengompres foldernya, bukan langsung file-file di dalamnya. Akibatnya, saat `Expand-Archive` mengekstrak ZIP tersebut ke `$InstallDir`, file-file aplikasi masuk ke dalam sebuah subfolder (misalnya: `C:\Program Files\MyApp\nama-folder-app\app.js`), bukan langsung di *root* folder instalasi.
Karena script mencari entry point dan menjalankan `npm install` langsung di root `$InstallDir`, file-file tersebut tidak ditemukan.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Untuk mengatasi masalah ini secara otomatis, kita perlu menambahkan logika untuk **memindahkan (flatten)** isi subfolder ke root direktori `$InstallDir` jika hasil ekstrak ternyata terbungkus oleh satu folder utama tunggal.

### Modifikasi `scripts/install.ps1`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/scripts/install.ps1`

1. Buka file `install.ps1`.
2. Cari fungsi `Download-App`.
3. Tepat setelah perintah `Expand-Archive ...` yang sukses (di bawah `Ok "Extract selesai."`), tambahkan blok kode pendeteksi folder pembungkus dan pindahkan isinya keluar.

**Diff Perubahan:**
```powershell
@@ -xxx,xxx @@ function Download-App {
     Log "Mengextract ke $InstallDir ..."
     try {
         Expand-Archive -Path $zipPath -DestinationPath $InstallDir -Force
         Ok "Extract selesai."
+
+        # Periksa apakah hasil ekstrak terbungkus di dalam satu subfolder tunggal
+        $subdirs = Get-ChildItem -Path $InstallDir -Directory
+        $files = Get-ChildItem -Path $InstallDir -File
+        if ($subdirs.Count -eq 1 -and $files.Count -eq 0) {
+            $wrapper = $subdirs[0].FullName
+            Log "Mendeteksi folder pembungkus ($($subdirs[0].Name)), memindahkan isi ke root..."
+            Move-Item -Path "$wrapper\*" -Destination $InstallDir -Force
+            Remove-Item -Path $wrapper -Force
+        }
+
     } catch {
         Err "Gagal extract ZIP: $_"
     }
```

## Alternatif Lain / Tambahan (Opsional)
Jika aplikasi memang memiliki nama entry point yang berbeda (misalnya `bin/www` atau `src/main.js`), Anda juga dapat memperbarui daftar pencarian di fungsi `Setup-PM2` di dalam file `install.ps1` seperti ini:

```powershell
# Di dalam fungsi Setup-PM2
foreach ($candidate in @("app.js", "index.js", "server.js", "main.js", "bin/www", "src/index.js")) {
    ...
}
```

## Verifikasi
1. Terapkan perubahan pada `install.ps1` di atas lalu simpan.
2. Compile ulang `MyApp_Setup.iss`.
3. Jalankan installer kembali. Anda seharusnya melihat log *"Mendeteksi folder pembungkus..."* jika ZIP yang diunduh memang terbungkus folder, dan instalasi PM2 akan sukses karena file `app.js`/`index.js` sudah berpindah ke letak yang benar (di root folder).
