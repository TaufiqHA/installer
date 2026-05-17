# Bug: Tab "Update Script" Hanya Berisi Placeholder

## Deskripsi Masalah
Saat installer dijalankan dan pengguna berpindah ke tab **"Update Script"**, tidak ada *form* isian apapun. Layar hanya menampilkan teks *placeholder* kosong: 
`Update script functionality goes here.`

**Penyebab:**
Bagian UI (User Interface) dan logika untuk tab Update Script memang belum diimplementasikan di dalam file `MyApp_Setup.iss`. Bagian tersebut saat ini hanya dideklarasikan menggunakan label teks statis (`WelcomeLabel`) tanpa adanya *input field* maupun tombol eksekusi update.

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

Untuk memperbaiki masalah ini, kita perlu membangun *Form Update* yang berisi input lokasi folder target, input URL versi terbaru, dan tombol eksekusi update, serta membuat fungsinya di Pascal Script.

### Modifikasi `MyApp_Setup.iss`
**Lokasi File:** `/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

**Langkah 1: Tambahkan Variabel UI**
Cari bagian deklarasi variabel (`var`) di bawah konstanta warna, lalu tambahkan variabel untuk panel update:
```pascal
  // Tambahkan ini di bawah deklarasi variabel (misal di bawah InstallBtn: TNewButton;)
  UpdateDirEdit: TNewEdit;
  UpdateUrlMemo: TNewMemo;
  UpdateBtn: TNewButton;
```

**Langkah 2: Tambahkan Prosedur Eksekusi Update**
Letakkan kode fungsi berikut di **atas** `procedure InitializeWizard;`:
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
  
  ExtractTemporaryFile('install.ps1'); // Kita tetap pakai install.ps1 yang ada mode updatenya
  
  Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
            ' -InstallDir "' + UpdateDirEdit.Text + '"' +
            ' -ZipUrl "' + SafeUrl + '"' +
            ' -UpdateMode';
            
  if Exec('powershell.exe', Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode = 0 then LogToConsole('Update Selesai!')
    else LogToConsole('Update Gagal dengan kode: ' + IntToStr(ResultCode));
  end else LogToConsole('Gagal menjalankan script update.');
end;

procedure UpdateBtnClick(Sender: TObject);
begin
  UpdateBtn.Enabled := False;
  try RunUpdateScript; finally UpdateBtn.Enabled := True; end;
end;

procedure UpdateBrowseBtnClick(Sender: TObject);
var Dir: String;
begin
  if BrowseForFolder('Pilih Folder Instalasi Sebelumnya', Dir, True) then
    UpdateDirEdit.Text := Dir;
end;
```

**Langkah 3: Bangun UI di dalam `InitializeWizard`**
Cari bagian di mana tab Update dibuat. Anda akan menemukan kode pembuatan `WelcomeLabel`. **Hapus** kode pembuatan `WelcomeLabel` tersebut dan ganti dengan *form* di bawah ini:
```pascal
  // HAPUS KODE INI:
  // WelcomeLabel := TLabel.Create(UpdateScriptPanel);
  // WelcomeLabel.Caption := 'Update script functionality goes here.';
  // ... dan seterusnya

  // GANTI DENGAN KODE INI:
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

## Verifikasi
1. Terapkan perubahan, lalu simpan file `MyApp_Setup.iss`.
2. Tekan **F9** untuk *Compile* Inno Setup.
3. Jalankan installer dan beralih ke tab **Update Script**. Form input dan tombol eksekusi harus sudah menggantikan tulisan placeholder.
4. Uji tombol "Mulai Update Aplikasi" dan pastikan script dipanggil dengan mode update di panel console sebelah kiri.
