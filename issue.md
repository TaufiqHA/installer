# Bug: Unknown identifier 'OUTERPAGE' in MyApp_Setup.iss

## Deskripsi Masalah
Saat mengkompilasi file Inno Setup (`MyApp_Setup.iss`), terjadi error pada baris 170 kolom 14:
`unknown identifier 'OUTERPAGE'`

Error ini terjadi karena pada Inno Setup (Pascal Script), object `WizardForm` tidak memiliki properti bernama `OuterPage`. Untuk menyembunyikan halaman luar (outer) bawaan dari wizard, nama properti yang benar adalah `OuterNotebook`.

## Lokasi File
`/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

## Langkah-langkah Penyelesaian (Untuk Junior Dev / AI Model)

1. Buka file `MyApp_Setup.iss`.
2. Cari baris **170**. Kodenya akan terlihat seperti ini:
   ```pascal
   WizardForm.OuterPage.Visible := False;
   ```
3. Ubah kata `OuterPage` menjadi `OuterNotebook`, sehingga kodenya menjadi:
   ```pascal
   WizardForm.OuterNotebook.Visible := False;
   ```
4. Simpan file `MyApp_Setup.iss`.
5. Coba lakukan kompilasi ulang (compile) pada Inno Setup untuk memastikan error sudah hilang.

## Contoh Perubahan (Diff)

**Sebelum:**
```pascal
  // Hide Default UI
  WizardForm.NextButton.Visible := False;
  WizardForm.BackButton.Visible := False;
  WizardForm.CancelButton.Visible := False;
  WizardForm.Bevel1.Visible := False;
  WizardForm.MainPanel.Visible := False;
  WizardForm.InnerPage.Visible := False;
  WizardForm.OuterPage.Visible := False;
```

**Sesudah:**
```pascal
  // Hide Default UI
  WizardForm.NextButton.Visible := False;
  WizardForm.BackButton.Visible := False;
  WizardForm.CancelButton.Visible := False;
  WizardForm.Bevel1.Visible := False;
  WizardForm.MainPanel.Visible := False;
  WizardForm.InnerPage.Visible := False;
  WizardForm.OuterNotebook.Visible := False;
```
