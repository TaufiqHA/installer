# Bug: Instalasi Gagal dengan Kode -196608

## Deskripsi Masalah
Saat installer berjalan dan mengeksekusi script instalasi, muncul pesan error:
`Instalasi Gagal dengan kode: -196608`

**Penyebab:**
Error `-196608` (atau `0xFFFD0000`) pada Inno Setup umumnya menandakan gagalnya eksekusi *command-line* akibat *arguments* yang cacat/malformed. Masalah ini terjadi karena komponen `EnvMemo` mengizinkan input teks multi-baris (multiline). Saat Inno Setup meneruskan `EnvMemo.Text` yang berisi karakter baris baru (`#13#10` / CRLF) secara langsung ke dalam parameter `Exec('powershell.exe', ...)`, format command-line menjadi rusak dan gagal diproses oleh Windows.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Untuk memperbaiki bug ini, kita perlu mengubah (replace) karakter baris baru menjadi sebuah *placeholder* (misalnya `[NL]`) di dalam Inno Setup sebelum dieksekusi. Kemudian, pada script PowerShell, kita kembalikan `[NL]` tersebut menjadi baris baru.

### 1. Modifikasi `MyApp_Setup.iss`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

1. Cari _procedure_ `RunInstallScript` di bagian `[Code]`.
2. Tambahkan variabel lokal `SafeEnv: String;`.
3. Copy isi `EnvMemo.Text` ke `SafeEnv`, lalu ubah karakter `#13#10` menjadi `[NL]`.
4. Gunakan `SafeEnv` pada penyusunan `Params`.

**Diff Perubahan:**
```pascal
@@ -xxx,xxx @@ procedure RunInstallScript(UpdateMode: Boolean);
 var
   ResultCode: Integer;
   Params: String;
+  SafeEnv: String;
 begin
   LogToConsole('Memulai proses instalasi...');
   
+  SafeEnv := EnvMemo.Text;
+  StringChange(SafeEnv, #13#10, '[NL]');
+
   Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
             ' -InstallDir "' + InstallDirEdit.Text + '"' +
             ' -ZipUrl "' + DownloadUrlMemo.Text + '"' +
-            ' -EnvExtra "' + EnvMemo.Text + '"';
+            ' -EnvExtra "' + SafeEnv + '"';
```

### 2. Modifikasi `scripts/install.ps1`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/scripts/install.ps1`

1. Cari bagian blok kode `if ($EnvExtra -ne "")` di dalam fungsi yang menangani pembuatan file `.env` (biasanya bernama `Create-Env`).
2. Gunakan *regex replace* untuk mengubah `[NL]` kembali menjadi karakter newline (`` `n ``).

**Diff Perubahan:**
```powershell
@@ -xxx,xxx @@ function Create-Env {
     # ...
     if ($EnvExtra -ne "") {
-        $content += "`n# Extra config`n$EnvExtra"
+        $CleanEnvExtra = $EnvExtra -replace '\[NL\]', "`n"
+        $content += "`n# Extra config`n$CleanEnvExtra"
     }
     # ...
```

## Verifikasi
1. Simpan kedua file yang telah diubah.
2. Lakukan *Compile* ulang (F9) pada Inno Setup.
3. Jalankan installer, lalu pada bagian input *Environment Variables*, isikan konfigurasi menggunakan lebih dari satu baris (multiline).
4. Klik Install. Proses harus berjalan sukses (tidak memunculkan error `-196608`) dan pada folder tujuan instalasi, file `.env` harus terbuat dengan format baris baru yang benar sesuai input.
