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
WizardResizable=yes
PrivilegesRequired=admin
MinVersion=10.0
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
; UI Customization
WizardSizePercent=100,100

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "scripts\install.ps1";  DestDir: "{tmp}"; Flags: deleteafterinstall
Source: "scripts\update.ps1";   DestDir: "{app}"; DestName: "update.ps1"

[Icons]
Name: "{group}\{#AppName}";           Filename: "{app}\update.ps1"
Name: "{group}\Update {#AppName}";    Filename: "powershell.exe"; \
      Parameters: "-ExecutionPolicy Bypass -File ""{app}\update.ps1"""; \
      WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"

[Code]
const
  // Colors (BGR format)
  clBgWindow     = $382F2C; // #2c2f38
  clBgConsole    = $30211E; // #1e2130
  clTeal         = $C4CD4E; // #4ecdc4
  clInputBg      = $F0E6C8; // #c8e6f0
  clBlueBtn      = $D57B3A; // #3a7bd5
  clWhite        = $FFFFFF;
  clBlack        = $000000;
  clDarkGray     = $333333;

var
  LeftPanel, RightPanel: TPanel;
  ConsoleMemo: TNewMemo;
  FreshInstallPanel, UpdateScriptPanel: TPanel;
  InstallDirEdit: TNewEdit;
  DownloadUrlMemo: TNewMemo;
  EnvMemo: TNewMemo;
  TabFreshBtn, TabUpdateBtn: TPanel;
  InstallBtn: TNewButton;
  VersionLabel: TLabel;

procedure LogToConsole(Msg: String);
begin
  ConsoleMemo.Lines.Add('> ' + Msg);
  // Scroll to bottom
  SendMessage(ConsoleMemo.Handle, $00B7, 0, 0); // EM_LINESCROLL
end;

procedure SwitchTab(TabName: String);
begin
  if TabName = 'Fresh' then
  begin
    FreshInstallPanel.Visible := True;
    UpdateScriptPanel.Visible := False;
    TabFreshBtn.Color := clTeal;
    TabUpdateBtn.Color := clBgWindow;
    TLabel(TabFreshBtn.Controls[0]).Font.Color := clBlack;
    TLabel(TabUpdateBtn.Controls[0]).Font.Color := clWhite;
  end
  else
  begin
    FreshInstallPanel.Visible := False;
    UpdateScriptPanel.Visible := True;
    TabFreshBtn.Color := clBgWindow;
    TabUpdateBtn.Color := clTeal;
    TLabel(TabFreshBtn.Controls[0]).Font.Color := clWhite;
    TLabel(TabUpdateBtn.Controls[0]).Font.Color := clBlack;
  end;
end;

procedure TabFreshBtnClick(Sender: TObject);
begin
  SwitchTab('Fresh');
end;

procedure TabUpdateBtnClick(Sender: TObject);
begin
  SwitchTab('Update');
end;

procedure BrowseBtnClick(Sender: TObject);
var
  Dir: String;
begin
  if BrowseForFolder('Pilih Folder Instalasi', Dir, True) then
    InstallDirEdit.Text := Dir;
end;

procedure RunInstallScript(UpdateMode: Boolean);
var
  ResultCode: Integer;
  Params: String;
begin
  LogToConsole('Memulai proses instalasi...');
  
  Params := '-ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}') + '\install.ps1"' +
            ' -InstallDir "' + InstallDirEdit.Text + '"' +
            ' -ZipUrl "' + DownloadUrlMemo.Text + '"' +
            ' -EnvExtra "' + EnvMemo.Text + '"';
            
  if UpdateMode then
    Params := Params + ' -UpdateMode';

  if Exec('powershell.exe', Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode = 0 then
      LogToConsole('Instalasi Selesai!')
    else
      LogToConsole('Instalasi Gagal dengan kode: ' + IntToStr(ResultCode));
  end
  else
    LogToConsole('Gagal menjalankan script instalasi.');
end;

procedure InstallBtnClick(Sender: TObject);
begin
  InstallBtn.Enabled := False;
  try
    RunInstallScript(False);
  finally
    InstallBtn.Enabled := True;
  end;
end;

procedure InitializeWizard;
var
  WelcomeLabel, ConsoleLabel: TLabel;
  BrowseBtn: TNewButton;
  DirLabel, UrlLabel, EnvLabel: TLabel;
  TabFreshLabel, TabUpdateLabel: TLabel;
begin
  // Set Window Properties
  WizardForm.ClientWidth := 800;
  WizardForm.ClientHeight := 500;
  WizardForm.Color := clBgWindow;
  WizardForm.Center;
  
  // Hide Default UI
  WizardForm.NextButton.Visible := False;
  WizardForm.BackButton.Visible := False;
  WizardForm.CancelButton.Visible := False;
  WizardForm.Bevel1.Visible := False;
  WizardForm.MainPanel.Visible := False;
  WizardForm.InnerPage.Visible := False;
  WizardForm.OuterPage.Visible := False;

  // --- Sidebar (Left Panel) ---
  LeftPanel := TPanel.Create(WizardForm);
  LeftPanel.Parent := WizardForm;
  LeftPanel.Width := ScaleX(280);
  LeftPanel.Height := WizardForm.ClientHeight;
  LeftPanel.Align := alLeft;
  LeftPanel.Color := clBgWindow;
  LeftPanel.BorderStyle := bsNone;
  LeftPanel.BevelOuter := bvNone;

  VersionLabel := TLabel.Create(LeftPanel);
  VersionLabel.Parent := LeftPanel;
  VersionLabel.Caption := '{#AppVersion}';
  VersionLabel.Left := ScaleX(20);
  VersionLabel.Top := ScaleY(10);
  VersionLabel.Font.Color := clWhite;
  VersionLabel.Font.Size := 9;

  ConsoleLabel := TLabel.Create(LeftPanel);
  ConsoleLabel.Parent := LeftPanel;
  ConsoleLabel.Caption := 'Monitoring Console';
  ConsoleLabel.Left := ScaleX(20);
  ConsoleLabel.Top := ScaleY(40);
  ConsoleLabel.Font.Color := clWhite;
  ConsoleLabel.Font.Style := [fsBold];

  ConsoleMemo := TNewMemo.Create(LeftPanel);
  ConsoleMemo.Parent := LeftPanel;
  ConsoleMemo.Left := ScaleX(20);
  ConsoleMemo.Top := ScaleY(65);
  ConsoleMemo.Width := LeftPanel.Width - ScaleX(40);
  ConsoleMemo.Height := LeftPanel.Height - ScaleY(100);
  ConsoleMemo.Color := clBgConsole;
  ConsoleMemo.Font.Color := clTeal;
  ConsoleMemo.Font.Name := 'Consolas';
  ConsoleMemo.Font.Size := 9;
  ConsoleMemo.ReadOnly := True;
  ConsoleMemo.ScrollBars := ssVertical;

  // --- Main Content (Right Panel) ---
  RightPanel := TPanel.Create(WizardForm);
  RightPanel.Parent := WizardForm;
  RightPanel.Width := WizardForm.ClientWidth - LeftPanel.Width;
  RightPanel.Height := WizardForm.ClientHeight;
  RightPanel.Align := alClient;
  RightPanel.Color := clBgWindow;
  RightPanel.BorderStyle := bsNone;
  RightPanel.BevelOuter := bvNone;

  // Tab Bar
  TabFreshBtn := TPanel.Create(RightPanel);
  TabFreshBtn.Parent := RightPanel;
  TabFreshBtn.Left := ScaleX(0);
  TabFreshBtn.Top := ScaleY(0);
  TabFreshBtn.Width := RightPanel.Width div 2;
  TabFreshBtn.Height := ScaleY(40);
  TabFreshBtn.Color := clTeal;
  TabFreshBtn.BevelOuter := bvNone;
  TabFreshBtn.OnClick := @TabFreshBtnClick;
  TabFreshBtn.Cursor := crHand;

  TabFreshLabel := TLabel.Create(TabFreshBtn);
  TabFreshLabel.Parent := TabFreshBtn;
  TabFreshLabel.Caption := 'Fresh Install';
  TabFreshLabel.Alignment := taCenter;
  TabFreshLabel.AutoSize := False;
  TabFreshLabel.Width := TabFreshBtn.Width;
  TabFreshLabel.Top := ScaleY(12);
  TabFreshLabel.Font.Style := [fsBold];
  TabFreshLabel.OnClick := @TabFreshBtnClick;

  TabUpdateBtn := TPanel.Create(RightPanel);
  TabUpdateBtn.Parent := RightPanel;
  TabUpdateBtn.Left := TabFreshBtn.Width;
  TabUpdateBtn.Top := ScaleY(0);
  TabUpdateBtn.Width := RightPanel.Width - TabFreshBtn.Width;
  TabUpdateBtn.Height := ScaleY(40);
  TabUpdateBtn.Color := clBgWindow;
  TabUpdateBtn.BevelOuter := bvNone;
  TabUpdateBtn.OnClick := @TabUpdateBtnClick;
  TabUpdateBtn.Cursor := crHand;

  TabUpdateLabel := TLabel.Create(TabUpdateBtn);
  TabUpdateLabel.Parent := TabUpdateBtn;
  TabUpdateLabel.Caption := 'Update Script';
  TabUpdateLabel.Alignment := taCenter;
  TabUpdateLabel.AutoSize := False;
  TabUpdateLabel.Width := TabUpdateBtn.Width;
  TabUpdateLabel.Top := ScaleY(12);
  TabUpdateLabel.Font.Color := clWhite;
  TabUpdateLabel.OnClick := @TabUpdateBtnClick;

  // Content Panels
  FreshInstallPanel := TPanel.Create(RightPanel);
  FreshInstallPanel.Parent := RightPanel;
  FreshInstallPanel.Top := TabFreshBtn.Height;
  FreshInstallPanel.Width := RightPanel.Width;
  FreshInstallPanel.Height := RightPanel.Height - TabFreshBtn.Height;
  FreshInstallPanel.Color := clBgWindow;
  FreshInstallPanel.BevelOuter := bvNone;

  // Installation Directory
  DirLabel := TLabel.Create(FreshInstallPanel);
  DirLabel.Parent := FreshInstallPanel;
  DirLabel.Caption := 'Lokasi Folder Instalasi Target';
  DirLabel.Left := ScaleX(20);
  DirLabel.Top := ScaleY(20);
  DirLabel.Font.Color := clWhite;

  InstallDirEdit := TNewEdit.Create(FreshInstallPanel);
  InstallDirEdit.Parent := FreshInstallPanel;
  InstallDirEdit.Left := ScaleX(20);
  InstallDirEdit.Top := ScaleY(40);
  InstallDirEdit.Width := ScaleX(320);
  InstallDirEdit.Height := ScaleY(30);
  InstallDirEdit.Color := clInputBg;
  InstallDirEdit.Text := ExpandConstant('{autopf}\{#AppName}');

  BrowseBtn := TNewButton.Create(FreshInstallPanel);
  BrowseBtn.Parent := FreshInstallPanel;
  BrowseBtn.Left := InstallDirEdit.Left + InstallDirEdit.Width + ScaleX(10);
  BrowseBtn.Top := InstallDirEdit.Top;
  BrowseBtn.Width := ScaleX(80);
  BrowseBtn.Height := InstallDirEdit.Height;
  BrowseBtn.Caption := 'Browse';
  BrowseBtn.OnClick := @BrowseBtnClick;

  // Download URL
  UrlLabel := TLabel.Create(FreshInstallPanel);
  UrlLabel.Parent := FreshInstallPanel;
  UrlLabel.Caption := 'URL Unduhan Script (.zip)';
  UrlLabel.Left := ScaleX(20);
  UrlLabel.Top := ScaleY(85);
  UrlLabel.Font.Color := clWhite;

  DownloadUrlMemo := TNewMemo.Create(FreshInstallPanel);
  DownloadUrlMemo.Parent := FreshInstallPanel;
  DownloadUrlMemo.Left := ScaleX(20);
  DownloadUrlMemo.Top := ScaleY(105);
  DownloadUrlMemo.Width := FreshInstallPanel.Width - ScaleX(40);
  DownloadUrlMemo.Height := ScaleY(60);
  DownloadUrlMemo.Color := clInputBg;
  DownloadUrlMemo.Text := '{#ZipUrl}';

  // .env Config
  EnvLabel := TLabel.Create(FreshInstallPanel);
  EnvLabel.Parent := FreshInstallPanel;
  EnvLabel.Caption := 'Konfigurasi File .env';
  EnvLabel.Left := ScaleX(20);
  EnvLabel.Top := ScaleY(180);
  EnvLabel.Font.Color := clWhite;

  EnvMemo := TNewMemo.Create(FreshInstallPanel);
  EnvMemo.Parent := FreshInstallPanel;
  EnvMemo.Left := ScaleX(20);
  EnvMemo.Top := ScaleY(200);
  EnvMemo.Width := FreshInstallPanel.Width - ScaleX(40);
  EnvMemo.Height := ScaleY(120);
  EnvMemo.Color := clInputBg;
  EnvMemo.Font.Name := 'Consolas';
  EnvMemo.Text := 'PORT=3000' + #13#10 + 'DATABASE_URL=mongodb://localhost:27017/mydb' + #13#10 + 'API_KEY=your_secret_key';

  // Main Install Button
  InstallBtn := TNewButton.Create(FreshInstallPanel);
  InstallBtn.Parent := FreshInstallPanel;
  InstallBtn.Left := ScaleX(20);
  InstallBtn.Top := FreshInstallPanel.Height - ScaleY(70);
  InstallBtn.Width := FreshInstallPanel.Width - ScaleX(40);
  InstallBtn.Height := ScaleY(45);
  InstallBtn.Caption := 'Mulai Fresh Install';
  InstallBtn.Font.Style := [fsBold];
  InstallBtn.OnClick := @InstallBtnClick;

  // Update Panel (Empty for now as per instructions, or just a placeholder)
  UpdateScriptPanel := TPanel.Create(RightPanel);
  UpdateScriptPanel.Parent := RightPanel;
  UpdateScriptPanel.Top := TabFreshBtn.Height;
  UpdateScriptPanel.Width := RightPanel.Width;
  UpdateScriptPanel.Height := RightPanel.Height - TabFreshBtn.Height;
  UpdateScriptPanel.Color := clBgWindow;
  UpdateScriptPanel.BevelOuter := bvNone;
  UpdateScriptPanel.Visible := False;
  
  WelcomeLabel := TLabel.Create(UpdateScriptPanel);
  WelcomeLabel.Parent := UpdateScriptPanel;
  WelcomeLabel.Caption := 'Update script functionality goes here.';
  WelcomeLabel.Left := ScaleX(20);
  WelcomeLabel.Top := ScaleY(20);
  WelcomeLabel.Font.Color := clWhite;

  LogToConsole('Wizard diinisialisasi.');
  LogToConsole('Menunggu input user...');
end;