# Bug: Instalasi Gagal dengan Kode -196608 (Error Masih Sama)

## Deskripsi Masalah
Jika error `-196608` masih muncul meskipun kita sudah mengganti karakter baris baru (newline) pada `EnvMemo`, itu berarti ada dua penyebab lain yang membuat command-line PowerShell menjadi *malformed* atau gagal dieksekusi oleh `Exec()` di Inno Setup:

1. **File `install.ps1` Belum Diekstrak:** Karena installer ini menggunakan Custom UI (bypass halaman bawaan Inno Setup), proses instalasi standar Inno Setup (di mana file pada bagian `[Files]` diekstrak) belum terjadi saat tombol Install diklik. Akibatnya, powershell mencoba menjalankan file `-File "{tmp}\install.ps1"` yang sebenarnya belum ada.
2. **Karakter Quote (`"`) atau Newline pada input lain:** `DownloadUrlMemo` adalah multiline teks. Jika ada newline tidak sengaja (CRLF), itu akan memutus command. Selain itu, jika `EnvMemo` berisi tanda kutip ganda (`"`), command arguments akan rusak.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

### 1. Modifikasi `MyApp_Setup.iss`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

Kita perlu menambahkan `ExtractTemporaryFile` untuk mengekstrak script PowerShell sebelum dijalankan, membersihkan newline pada `DownloadUrlMemo`, dan melakukan *escape* pada tanda kutip ganda (quote).

1. Cari _procedure_ `RunInstallScript` di bagian `[Code]`.
2. Tambahkan variabel lokal `SafeUrl: String;`.
3. Tepat sebelum memanggil `Exec`, tambahkan perintah untuk mengekstrak file `install.ps1`.
4. Sanitasi `SafeUrl` dan *escape* kutip ganda pada `SafeEnv`.

**Diff Perubahan:**
```pascal
@@ -xxx,xxx @@ procedure RunInstallScript(UpdateMode: Boolean);
 var
   ResultCode: Integer;
   Params: String;
   SafeEnv: String;
+  SafeUrl: String;
 begin
   LogToConsole('Memulai proses instalasi...');
   
   SafeEnv := EnvMemo.Text;
   StringChange(SafeEnv, #13#10, '[NL]');
+  StringChange(SafeEnv, '"', '\"'); // Escape double quotes agar tidak merusak parameter cmd
+
+  SafeUrl := DownloadUrlMemo.Text;
+  StringChange(SafeUrl, #13#10, ''); // Hapus accidental newline pada URL Memo
+
+  // EKSTRAK FILE SCRIPT SEBELUM MENJALANKAN (Karena kita bypass default UI Inno Setup)
+  ExtractTemporaryFile('install.ps1');
   
   Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
             ' -InstallDir "' + InstallDirEdit.Text + '"' +
-            ' -ZipUrl "' + DownloadUrlMemo.Text + '"' +
+            ' -ZipUrl "' + SafeUrl + '"' +
             ' -EnvExtra "' + SafeEnv + '"';
```

## Verifikasi
1. Simpan file `MyApp_Setup.iss`.
2. Lakukan *Compile* ulang (F9).
3. Pastikan pada bagian `[Files]` script `install.ps1` masih ada:
   `Source: "scripts\install.ps1"; DestDir: "{tmp}"; Flags: deleteafterinstall`
4. Jalankan installer dan klik Install. Error `-196608` seharusnya hilang karena file script-nya sudah ada di temporary folder dan format command-line sudah sepenuhnya aman dari karakter newline/quote nyasar.
