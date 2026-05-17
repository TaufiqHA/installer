# Issue: Duplicate Identifier 'CENTER' in MyApp_Setup.iss

## Deskripsi Bug
Saat melakukan kompilasi file `MyApp_Setup.iss`, muncul error:
`Duplicate identifier 'CENTER'` di dalam bagian `[Code]`.

**Penyebab:**
Di dalam Inno Setup (Pascal Script), nama `Center` (tidak peka huruf besar/kecil, sehingga `CENTER` sama dengan `Center`) adalah nama metode bawaan untuk komponen form (misalnya `WizardForm.Center`). Jika Anda mendefinisikan konstanta atau variabel dengan nama `CENTER`, hal ini akan menyebabkan konflik dengan identitas bawaan tersebut atau jika ada duplikasi definisi di tempat lain.

---

## Langkah Perbaikan untuk Developer

### 1. Lokasi File
Buka file berikut:
`/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

### 2. Identifikasi Masalah
Cari apakah ada baris yang mendefinisikan `CENTER` atau `Center` sebagai konstanta atau variabel.
Contoh baris yang mungkin menyebabkan masalah:
```pascal
[Code]
const
  CENTER = 1; // <-- KONFLIK DI SINI
```
Atau jika ada dua definisi fungsi/prosedur dengan nama yang sama.

### 3. Cara Memperbaiki
Hindari penggunaan nama yang sangat umum atau yang sudah digunakan oleh sistem (reserved keywords/built-in methods).

#### Langkah-langkah detail:
1.  **Ganti Nama Konstanta/Variabel:**
    Jika Anda menemukan baris seperti `CENTER = ...;`, ganti namanya menjadi sesuatu yang lebih spesifik, misalnya `clAppCenter` atau `TEXT_ALIGN_CENTER`.
    
    *Contoh Perubahan:*
    ```pascal
    // Sebelum
    const
      CENTER = 2;
    
    // Sesudah
    const
      ALIGN_CENTER_VAL = 2;
    ```
2.  **Periksa Penggunaan `taCenter`:**
    Pastikan Anda tidak salah menulis `taCenter` (untuk perataan teks) menjadi hanya `CENTER`. `taCenter` adalah nilai yang benar untuk properti `Alignment`.
3.  **Hapus Jika Tidak Diperlukan:**
    Jika baris tersebut tidak sengaja ditambahkan atau merupakan sisa kode lama, hapus saja baris tersebut.

### 4. Verifikasi
1.  Simpan file `MyApp_Setup.iss`.
2.  Buka Inno Setup Compiler.
3.  Tekan **Compile (F9)**.
4.  Pastikan error "Duplicate identifier 'CENTER'" sudah tidak muncul lagi.

---

## Catatan untuk Junior Dev / AI Model
Selalu gunakan awalan (prefix) yang unik untuk konstanta kustom Anda (misalnya `MYAPP_...` atau `clApp...`) untuk menghindari konflik dengan library bawaan Inno Setup. Jika Anda melihat `WizardForm.Center;` di dalam kode, itu adalah perintah untuk memposisikan jendela ke tengah layar, jangan gunakan nama yang sama untuk hal lain.
