# Issue: Duplicate Identifier 'clWhite' in MyApp_Setup.iss

## Deskripsi Bug
Saat melakukan kompilasi file `MyApp_Setup.iss`, muncul error:
`Duplicate identifier 'clWhite'` pada bagian konstanta di dalam blok `[Code]`.

**Penyebab:**
Inno Setup (Pascal Script) sudah memiliki konstanta standar bernama `clWhite`. Mendefinisikan ulang konstanta dengan nama yang sama persis menyebabkan konflik identitas (duplicate identifier).

---

## Langkah Perbaikan untuk Developer

### 1. Lokasi File
Buka file berikut:
`/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

### 2. Identifikasi Masalah
Cari baris yang mendefinisikan `clWhite` di dalam blok `[Code]`.
Tampilan kodenya saat ini:
```pascal
[Code]
const
  ...
  clWhite        = $FFFFFF; // <-- ERROR DI SINI
  clBlack        = $000000;
  ...
```

### 3. Cara Memperbaiki
Karena `clWhite` adalah warna standar yang sudah dikenal oleh Inno Setup, cara termudah dan teraman adalah **menghapus** baris deklarasi tersebut agar compiler menggunakan nilai bawaan sistem.

#### Langkah-langkah detail:
1.  **Hapus Baris Deklarasi:**
    Cari baris `clWhite = $FFFFFF;` dan hapus baris tersebut sepenuhnya.
2.  **Hapus Baris clBlack (Opsional tapi Disarankan):**
    Biasanya `clBlack` juga akan menyebabkan error yang sama jika didefinisikan ulang. Disarankan untuk menghapusnya juga.
3.  **Gunakan Nama Unik (Alternatif):**
    Jika Anda ingin tetap mendefinisikan warna putih kustom Anda sendiri, ganti namanya menjadi `clAppWhite`:
    *   Ganti `clWhite = $FFFFFF;` menjadi `clAppWhite = $FFFFFF;`.
    *   Lakukan *Find & Replace* semua penggunaan `clWhite` di seluruh file menjadi `clAppWhite`.

### 4. Verifikasi
1.  Simpan file `MyApp_Setup.iss`.
2.  Jalankan Inno Setup Compiler.
3.  Tekan **Compile (F9)**.
4.  Pastikan error "Duplicate identifier 'clWhite'" sudah hilang.

---

## Catatan untuk Junior Dev / AI Model
Jika Anda menggunakan editor seperti VS Code, cukup cari teks `clWhite` di bagian `const` dan hapus barisnya. Inno Setup akan otomatis mengerti bahwa `clWhite` merujuk pada warna putih standar.
