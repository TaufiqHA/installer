# Rencana Implementasi Fitur Update di Installer (MyApp_Setup.iss)

Dokumen ini berisi panduan langkah-demi-langkah untuk mengimplementasikan fungsionalitas pada tab **Update Script** di dalam Inno Setup, yang saat ini masih berupa *placeholder* kosong.

## Tujuan Utama
Mengganti teks placeholder `"Update script functionality goes here."` dengan elemen UI (Form) yang utuh, sehingga pengguna dapat memasukkan folder instalasi yang sudah ada, memasukkan URL versi terbaru, dan mengeklik tombol untuk menjalankan pembaruan (mengeksekusi `install.ps1` dengan flag `-UpdateMode`).

---

## Langkah 1: Persiapan Variabel UI
Di file `MyApp_Setup.iss` bagian `[Code]`, tambahkan deklarasi variabel global untuk komponen-komponen yang akan diletakkan di dalam `UpdateScriptPanel`.

**Tambahkan di bawah deklarasi variabel (sekitar baris `var ... VersionLabel: TLabel;`):**
```pascal
  // Variabel untuk Panel Update
  UpdateDirEdit: TNewEdit;
  UpdateUrlMemo: TNewMemo;
  UpdateBtn: TNewButton;
```

---

## Langkah 2: Membuat Prosedur Eksekusi Update
Karena fungsi `RunInstallScript` saat ini secara *hardcode* mengambil teks dari `InstallDirEdit` dan `DownloadUrlMemo` (yang berada di panel Fresh Install), kita perlu membuat fungsi serupa khusus untuk tab Update, atau membungkus logikanya. Agar aman dan mudah dipahami junior dev, kita buat *procedure* terpisah.

**Buat fungsi berikut di atas `procedure InitializeWizard;`:**
```pascal
procedure RunUpdateScript;
var
  ResultCode: Integer;
  Params: String;
  SafeUrl: String;
begin
  LogToConsole('Memulai proses update aplikasi...');
  
  SafeUrl := UpdateUrlMemo.Text;
  StringChange(SafeUrl, #13#10, ''); // Bersihkan newline
  
  // Ekstrak script
  ExtractTemporaryFile('install.ps1');
  
  // Susun parameter powershell (Tanpa EnvExtra, dengan -UpdateMode)
  Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
            ' -InstallDir "' + UpdateDirEdit.Text + '"' +
            ' -ZipUrl "' + SafeUrl + '"' +
            ' -UpdateMode';
            
  if Exec('powershell.exe', Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode = 0 then
      LogToConsole('Update Selesai!')
    else
      LogToConsole('Update Gagal dengan kode: ' + IntToStr(ResultCode));
  end
  else
    LogToConsole('Gagal menjalankan script update.');
end;

procedure UpdateBtnClick(Sender: TObject);
begin
  UpdateBtn.Enabled := False;
  try
    RunUpdateScript;
  finally
    UpdateBtn.Enabled := True;
  end;
end;

procedure UpdateBrowseBtnClick(Sender: TObject);
var
  Dir: String;
begin
  if BrowseForFolder('Pilih Folder Instalasi Sebelumnya', Dir, True) then
    UpdateDirEdit.Text := Dir;
end;
```

---

## Langkah 3: Membangun UI di `InitializeWizard`
Cari bagian pembuatan `UpdateScriptPanel` di dalam `procedure InitializeWizard`. **Hapus** kode pembuatan `WelcomeLabel` yang merupakan *placeholder*, lalu ganti dengan kode pembuatan form.

**Cari blok ini:**
```pascal
  WelcomeLabel := TLabel.Create(UpdateScriptPanel);
  // ... (hapus sampai pembuatan WelcomeLabel selesai)
```

**Ganti dengan desain Form Update (mirip Fresh Install):**
```pascal
  // --- Folder Instalasi (Update) ---
  DirLabel := TLabel.Create(UpdateScriptPanel);
  DirLabel.Parent := UpdateScriptPanel;
  DirLabel.Caption := 'Lokasi Folder Instalasi Saat Ini';
  DirLabel.Left := ScaleX(20);
  DirLabel.Top := ScaleY(20);
  DirLabel.Font.Color := clWhite;

  UpdateDirEdit := TNewEdit.Create(UpdateScriptPanel);
  UpdateDirEdit.Parent := UpdateScriptPanel;
  UpdateDirEdit.Left := ScaleX(20);
  UpdateDirEdit.Top := ScaleY(40);
  UpdateDirEdit.Width := ScaleX(320);
  UpdateDirEdit.Height := ScaleY(30);
  UpdateDirEdit.Color := clInputBg;
  UpdateDirEdit.Text := ExpandConstant('{autopf}\{#AppName}');

  BrowseBtn := TNewButton.Create(UpdateScriptPanel);
  BrowseBtn.Parent := UpdateScriptPanel;
  BrowseBtn.Left := UpdateDirEdit.Left + UpdateDirEdit.Width + ScaleX(10);
  BrowseBtn.Top := UpdateDirEdit.Top;
  BrowseBtn.Width := ScaleX(80);
  BrowseBtn.Height := UpdateDirEdit.Height;
  BrowseBtn.Caption := 'Browse';
  BrowseBtn.OnClick := @UpdateBrowseBtnClick;

  // --- URL ZIP Baru (Update) ---
  UrlLabel := TLabel.Create(UpdateScriptPanel);
  UrlLabel.Parent := UpdateScriptPanel;
  UrlLabel.Caption := 'URL Unduhan Script (.zip) Versi Terbaru';
  UrlLabel.Left := ScaleX(20);
  UrlLabel.Top := ScaleY(85);
  UrlLabel.Font.Color := clWhite;

  UpdateUrlMemo := TNewMemo.Create(UpdateScriptPanel);
  UpdateUrlMemo.Parent := UpdateScriptPanel;
  UpdateUrlMemo.Left := ScaleX(20);
  UpdateUrlMemo.Top := ScaleY(105);
  UpdateUrlMemo.Width := UpdateScriptPanel.Width - ScaleX(40);
  UpdateUrlMemo.Height := ScaleY(60);
  UpdateUrlMemo.Color := clInputBg;
  UpdateUrlMemo.Text := '{#ZipUrl}';

  // --- Tombol Update ---
  UpdateBtn := TNewButton.Create(UpdateScriptPanel);
  UpdateBtn.Parent := UpdateScriptPanel;
  UpdateBtn.Left := ScaleX(20);
  UpdateBtn.Top := UpdateScriptPanel.Height - ScaleY(70);
  UpdateBtn.Width := UpdateScriptPanel.Width - ScaleX(40);
  UpdateBtn.Height := ScaleY(45);
  UpdateBtn.Caption := 'Mulai Update Aplikasi';
  UpdateBtn.Font.Style := [fsBold];
  UpdateBtn.OnClick := @UpdateBtnClick;
```

---

## Cara Verifikasi Pekerjaan (Untuk QA / AI)
1. Lakukan *Compile* ulang script Inno Setup (Tekan `F9`).
2. Jalankan Installer.
3. Pindah ke tab **"Update Script"**. Pastikan form (Input Directory, Input URL, dan Tombol Update) muncul dengan tampilan yang proporsional.
4. Klik tombol **"Mulai Update Aplikasi"**. 
5. Perhatikan log di sebelah kiri (`Monitoring Console`), pastikan log menampilkan teks `Memulai proses update aplikasi...` lalu mengeksekusi powershell dengan lancar dan me-restart PM2.
