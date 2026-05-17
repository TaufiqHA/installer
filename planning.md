# Planning: Implementasi Custom UI Automation Setup Wizard

Dokumen ini berisi langkah-langkah detail untuk mengimplementasikan layout UI sesuai dengan `deskripsi UI.md` pada Inno Setup (`MyApp_Setup.iss`).

## Tujuan
Mengubah tampilan standar Inno Setup menjadi modern dark-mode dengan sidebar monitoring dan tab navigation.

---

## Tahap 1: Persiapan Global & Window Utama

Modifikasi `[Setup]` dan inisialisasi window di bagian `[Code]`.

1.  **Pengaturan `[Setup]`**:
    *   `WizardStyle=modern`
    *   `WizardResizable=yes`
2.  **Warna & Font Utama**:
    *   Background Window: `#2c2f38`
    *   Accent Color (Teal): `#4ecdc4`
    *   Font: Segoe UI (Standard Windows 11)
3.  **Menyembunyikan Komponen Default**:
    *   Sembunyikan `WizardForm.NextButton`, `WizardForm.BackButton`, `WizardForm.CancelButton` (kita akan buat tombol custom).
    *   Sembunyikan `WizardForm.Bevel1`, `WizardForm.MainPanel`, `WizardForm.PageNameLabel`, dll.

---

## Tahap 2: Struktur Layout (Dua Kolom)

Gunakan `TPanel` untuk membagi window menjadi dua bagian.

1.  **Sidebar (Kiri - 35%)**:
    *   Buat `LeftPanel: TPanel`.
    *   Warna: `#2c2f38`.
    *   Isi:
        *   `VersionLabel: TLabel` (Teks: "1.0.0", Warna: Putih).
        *   `ConsoleLabel: TLabel` (Teks: "Monitoring Console").
        *   `ConsoleMemo: TNewMemo`:
            *   Background: `#1e2130`.
            *   Text Color: `#4ecdc4`.
            *   Font: Monospace (Consolas).
            *   Read-only.

2.  **Main Content (Kanan - 65%)**:
    *   Buat `RightPanel: TPanel`.
    *   Warna: `#2c2f38`.
    *   Isi:
        *   **Tab Bar Area**: Dua tombol (`TNewButton` atau `TPanel` sebagai tombol) untuk "Fresh Install" dan "Update Script".
        *   **Content Container**: Panel untuk menampung form input.

---

## Tahap 3: Implementasi Tab "Fresh Install"

Komponen di dalam `Content Container` (disusun vertikal):

1.  **Lokasi Instalasi**:
    *   `Label`: "Lokasi Folder Instalasi Target".
    *   `EditField (TNewEdit)`: Background `#c8e6f0`, Text Dark.
    *   `BrowseButton (TNewButton)`: Background `#3a7bd5`, Teks "Browse".
2.  **URL Unduhan**:
    *   `Label`: "URL Unduhan Script (.zip)".
    *   `URLEdit (TNewMemo)`: Background `#c8e6f0`.
3.  **Konfigurasi .env**:
    *   `Label`: "Konfigurasi File .env".
    *   `EnvMemo (TNewMemo)`: Background `#c8e6f0`, Font Monospace.
4.  **Tombol Utama**:
    *   `InstallBtn (TNewButton)`: 
        *   Teks: "Mulai Fresh Install".
        *   Color: `#4ecdc4` (Teal).
        *   Full width.

---

## Tahap 4: Scripting & Logika (Pascal Script)

Langkah-langkah teknis di `procedure InitializeWizard`:

1.  **Ubah Ukuran Window**: `WizardForm.ClientWidth := 800; WizardForm.ClientHeight := 500;`
2.  **Fungsi `LogToConsole(Msg: String)`**:
    *   Buat prosedur untuk menambah teks ke `ConsoleMemo`.
    *   Contoh: `ConsoleMemo.Lines.Add('> ' + Msg);`
3.  **Fungsi `SwitchTab(TabName: String)`**:
    *   Menampilkan/menyembunyikan panel konten berdasarkan tab yang diklik.
    *   Mengubah warna tombol tab (aktif/non-aktif).
4.  **Handler `InstallBtnClick`**:
    *   Validasi input.
    *   Panggil `LogToConsole` untuk mensimulasikan proses.
    *   Jalankan `install.ps1` via `Exec`.

---

## Panduan Visual (CSS-like properties untuk Junior Dev)

| Elemen | Background | Text Color | Font |
| :--- | :--- | :--- | :--- |
| Window | `#2c2f38` | `#ffffff` | Segoe UI |
| Console | `#1e2130` | `#4ecdc4` | Consolas |
| Input Fields | `#c8e6f0` | `#000000` | Segoe UI |
| Main Button | `#4ecdc4` | `#000000` | Segoe UI Bold |
| Browse Button | `#3a7bd5` | `#ffffff` | Segoe UI |

---

## Tips untuk Implementasi Cepat
1.  Gunakan `WizardForm.Color := $382F2C;` (Inno Setup menggunakan format BGR, bukan RGB).
2.  Gunakan `TNewStaticText` untuk label agar lebih fleksibel dengan warna background.
3.  Atur `Parent` semua komponen baru ke `WizardForm` atau panel yang sesuai.
4.  Nonaktifkan `WizardForm.InnerPage` dan `WizardForm.OuterPage` agar kita punya "canvas" kosong.
