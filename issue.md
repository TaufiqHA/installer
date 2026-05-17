# Issue: Duplicate Identifier 'clTeal' in MyApp_Setup.iss

## Deskripsi Bug
Saat melakukan kompilasi file `MyApp_Setup.iss`, muncul error:
`Duplicate identifier 'clTeal'` pada **Line 51, Column 3**.

**Penyebab:**
Inno Setup (Pascal Script) sudah memiliki konstanta bawaan bernama `clTeal`. Mendefinisikan ulang konstanta dengan nama yang sama di bagian `[Code]` menyebabkan konflik.

---

## Langkah Perbaikan untuk Developer

### 1. Lokasi File
Buka file berikut:
`C:\path\to\project\installer\MyApp_Setup.iss`

### 2. Temukan Baris Bermasalah
Cari baris ke-51 atau cari teks `clTeal` di dalam blok `[Code]`.
Tampilan kodenya saat ini:
```pascal
[Code]
const
  // Colors (BGR format)
  clBgWindow     = $382F2C; // #2c2f38
  clBgConsole    = $30211E; // #1e2130
  clTeal         = $C4CD4E; // #4ecdc4  <-- ERROR DI SINI
  clInputBg      = $F0E6C8; // #c8e6f0
```

### 3. Cara Memperbaiki
Ubah nama konstanta `clTeal` menjadi nama yang unik, misalnya `clCustomTeal`, atau hapus baris tersebut jika ingin menggunakan warna Teal bawaan Windows.

**Opsi Rekomendasi (Ubah Nama):**
Ganti `clTeal` menjadi `clAppTeal` pada baris 51, kemudian ganti semua penggunaan `clTeal` di seluruh file menjadi `clAppTeal`.

#### Langkah-langkah detail:
1.  **Ganti deklarasi:**
    Ubah baris 51 menjadi:
    ```pascal
    clAppTeal      = $C4CD4E; // #4ecdc4
    ```
2.  **Ganti penggunaan (Find & Replace):**
    Gunakan fitur **Replace (Ctrl + H)** pada text editor (VS Code / Inno Setup IDE):
    *   Find: `clTeal`
    *   Replace with: `clAppTeal`
    *   *Pastikan hanya mengganti di bagian [Code] agar tidak merubah hal yang tidak diinginkan.*

### 4. Verifikasi
1.  Simpan file `MyApp_Setup.iss`.
2.  Buka Inno Setup Compiler.
3.  Tekan **F9** untuk Compile.
4.  Pastikan tidak ada lagi error "Duplicate identifier".

---

## Catatan Tambahan
Jika Anda adalah model AI, Anda bisa menjalankan perintah `sed` atau script replace sederhana untuk mengganti string `clTeal` menjadi `clAppTeal` di dalam file tersebut.
