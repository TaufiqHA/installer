# Issue: Unknown Identifier 'CENTER' in MyApp_Setup.iss

## Deskripsi Bug
Saat melakukan kompilasi file `MyApp_Setup.iss`, muncul error:
`Unknown identifier 'CENTER'` di dalam bagian `[Code]`.

**Penyebab:**
Error ini terjadi ketika compiler Inno Setup (Pascal Script) menemukan kata `CENTER` tetapi tidak tahu apa artinya. Penyebab paling umum adalah kesalahan penulisan (typo) saat mencoba mengatur perataan teks (alignment). Di Inno Setup, konstanta untuk rata tengah bukanlah `CENTER`, melainkan `taCenter`.

---

## Langkah Perbaikan untuk Developer

### 1. Lokasi File
Buka file berikut:
`/home/padi-kering/Documents/KERJA/installer/MyApp_Setup.iss`

### 2. Identifikasi Masalah
Cari baris kode di mana terjadi error. Biasanya error ini muncul saat mengatur properti `Alignment` pada komponen label teks.
Contoh kode yang **salah**:
```pascal
MyLabel.Alignment := CENTER; // <-- ERROR DI SINI
```

### 3. Cara Memperbaiki
Ganti kata `CENTER` menjadi `taCenter`. `taCenter` adalah konstanta bawaan Inno Setup untuk "Text Alignment Center".

#### Langkah-langkah detail:
1.  **Temukan kata `CENTER`:**
    Gunakan fitur **Find (Ctrl + F)** pada text editor dan cari kata `CENTER`.
2.  **Ganti dengan `taCenter`:**
    Ubah baris tersebut agar menggunakan konstanta yang benar.

    *Contoh Perbaikan:*
    ```pascal
    // Sebelum (SALAH)
    TabFreshLabel.Alignment := CENTER;
    
    // Sesudah (BENAR)
    TabFreshLabel.Alignment := taCenter;
    ```
    *Pastikan huruf "t" kecil dan "a" kecil, diikuti "Center" dengan "C" besar (meskipun Pascal tidak case-sensitive, ini adalah konvensi penulisan yang baik).*

### 4. Verifikasi
1.  Simpan file `MyApp_Setup.iss`.
2.  Buka Inno Setup Compiler.
3.  Tekan **Compile (F9)**.
4.  Pastikan error "Unknown identifier 'CENTER'" sudah tidak muncul lagi.

---

## Catatan untuk Junior Dev / AI Model
Inno Setup menggunakan konvensi penamaan Delphi/Pascal. Untuk perataan teks (alignment), nilai yang valid adalah:
- `taLeftJustify` (Rata Kiri)
- `taCenter` (Rata Tengah)
- `taRightJustify` (Rata Kanan)

Jadi, setiap kali Anda melihat error "Unknown identifier 'CENTER'" pada properti Alignment, langsung ganti dengan `taCenter`.
