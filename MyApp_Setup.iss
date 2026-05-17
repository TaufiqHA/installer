; ============================================================
;  MyApp_Setup.iss  —  Inno Setup Script
;  Kompilasi dengan Inno Setup 6.x  →  https://jrsoftware.org
; ============================================================

#define AppName      "MyApp"
#define AppVersion   "1.0.0"
#define AppPublisher "Your Company"
#define AppURL       "https://yourapp.com"
#define ZipUrl       "https://nodejs.org/dist/v24.15.0/node-v24.15.0-win-x64.zip"

[Setup]
AppId={{9d43a21a-b547-40f9-ac2b-04d3849c1c75}}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisherURL={#AppURL}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=.\dist
OutputBaseFilename=MyApp_Installer
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
MinVersion=10.0
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
InstallDirLabel=Lokasi Instalasi:
AppPortLabel=Port Aplikasi (default 3000):
MongoPortLabel=Port MongoDB (default 27017):

[Files]
Source: "scripts\install.ps1";  DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "scripts\update.ps1";   DestDir: "{app}"; DestName: "update.ps1"
; Source: "assets\*"; DestDir: "{app}\assets"; Flags: recursesubdirs

[Icons]
Name: "{group}\{#AppName}";           Filename: "{app}\update.ps1"
Name: "{group}\Update {#AppName}";    Filename: "powershell.exe"; \
      Parameters: "-ExecutionPolicy Bypass -File ""{app}\update.ps1"""; \
      WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"

; ── Script Pascal untuk custom wizard pages ─────────────────
[Code]

const
  ZipUrl = '{#ZipUrl}';  { preprocessor expand di sini sebelum Pascal di-compile }

var
  AppPortPage:   TInputQueryWizardPage;
  MongoPortPage: TInputQueryWizardPage;

{ Tambah halaman custom setelah halaman pilih direktori }
procedure InitializeWizard;
begin
  AppPortPage := CreateInputQueryPage(wpSelectDir,
    'Konfigurasi Port Aplikasi',
    'Tentukan port yang akan digunakan.',
    '');
  AppPortPage.Add('Port Aplikasi (Node.js):', False);
  AppPortPage.Values[0] := '3000';

  MongoPortPage := CreateInputQueryPage(AppPortPage.ID,
    'Konfigurasi MongoDB',
    'Tentukan port MongoDB.',
    '');
  MongoPortPage.Add('Port MongoDB:', False);
  MongoPortPage.Values[0] := '27017';
end;

{ Validasi input port }
function NextButtonClick(CurPageID: Integer): Boolean;
var
  p: Integer;
begin
  Result := True;
  if CurPageID = AppPortPage.ID then begin
    p := StrToIntDef(AppPortPage.Values[0], 0);
    if (p < 1024) or (p > 65535) then begin
      MsgBox('Port aplikasi harus antara 1024–65535.', mbError, MB_OK);
      Result := False;
    end;
  end;
  if CurPageID = MongoPortPage.ID then begin
    p := StrToIntDef(MongoPortPage.Values[0], 0);
    if (p < 1024) or (p > 65535) then begin
      MsgBox('Port MongoDB harus antara 1024–65535.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

{ Jalankan PowerShell install.ps1 setelah file dicopy }
procedure CurStepChanged(CurStep: TSetupStep);
var
  AppPort, MongoPort, InstallDir, Cmd: String;
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then begin
    AppPort   := AppPortPage.Values[0];
    MongoPort := MongoPortPage.Values[0];
    InstallDir := ExpandConstant('{app}');

    { Gunakan string concatenation — bukan Format() dengan array literal }
    Cmd := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"'
         + ' -InstallDir "' + InstallDir + '"'
         + ' -AppPort ' + AppPort
         + ' -MongoPort ' + MongoPort
         + ' -ZipUrl "' + ZipUrl + '"';

    if not Exec('powershell.exe', Cmd, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
      MsgBox('Instalasi gagal. Kode: ' + IntToStr(ResultCode), mbError, MB_OK)
    else if ResultCode <> 0 then
      MsgBox('Script instalasi keluar dengan kode error: ' + IntToStr(ResultCode), mbError, MB_OK);
  end;
end;