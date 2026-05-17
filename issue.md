# Bug: Unknown identifier 'CENTER' in MyApp_Setup.iss

## Deskripsi Masalah
Saat mengkompilasi file Inno Setup (`MyApp_Setup.iss`), terjadi error pada baris 161 kolom 14:
`unknown identifier 'CENTER'`

Error ini terjadi karena pada Inno Setup (Pascal Script), object `WizardForm` tidak memiliki method atau properti `Center`. Untuk menengahkan jendela wizard di layar, kita harus mengubah properti `Position`.

## Lokasi File
`/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

1. Buka file `MyApp_Setup.iss`.
2. Cari baris **161**. Kodenya akan terlihat seperti ini:
   ```pascal
   WizardForm.Center;
   ```
3. Ubah atau ganti baris tersebut menjadi:
   ```pascal
   WizardForm.Position := poScreenCenter;
   ```
4. Simpan file `MyApp_Setup.iss`.
5. Coba lakukan kompilasi ulang (compile) pada Inno Setup untuk memastikan error sudah hilang.

## Contoh Perubahan (Diff)

**Sebelum:**
```pascal
  // Set Window Properties
  WizardForm.ClientWidth := 800;
  WizardForm.ClientHeight := 500;
  WizardForm.Color := clBgWindow;
  WizardForm.Center;
```

**Sesudah:**
```pascal
  // Set Window Properties
  WizardForm.ClientWidth := 800;
  WizardForm.ClientHeight := 500;
  WizardForm.Color := clBgWindow;
  WizardForm.Position := poScreenCenter;
```
