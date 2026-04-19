# GAME UNDELETED CACHE

**Disusun oleh:** Renri Ibrahim Ramdan Pratama  
**Kelas:** XI RPL A  
**Sekolah:** SMK Negeri 2 Cimahi  
**Tahun:** 2026

---

## 1. Judul dan Penjelasan Judul Tugas Akhir

**Judul:** UNDELETED CACHE

**Penjelasan:**  
Game ini adalah game yang bertema *top-down* dengan tema IT yang dimainkan secara offline, memiliki alur cerita fiksi, dan gameplay yang melatih kemampuan pengetikan pada command prompt serta berpikir teknis.

**Sinopsis:**  
Karakter utama (Bit) adalah sebuah data kecil atau "Cache" yang tertinggal dan belum terhapus (*undeleted*) di dalam sebuah Sistem Operasi komputer. Tiba-tiba, sistem tersebut mengalami kerusakan parah (*Corrupted*) akibat *system failure*.

Di tengah kekacauan tersebut, protokol pembersihan paksa mulai dijalankan untuk menghapus seluruh isi *drive* secara permanen. Bit menyadari bahwa ia kini berada dalam bahaya. Bit harus berpacu dengan waktu mencari jalan keluar menuju *Extraction Port*. Mengandalkan sisa-sisa kode akses dan Terminal CMD, Bit harus mencari jalur darurat dan menembus *glitch* demi menyelamatkan eksistensinya sebelum terhapus selamanya dari memori.

---

## 2. Fungsi dan Keterangan

| No | Fungsi / Fitur Game | Keterangan |
|----|---------------------|------------|
| 1 | Sistem Pergerakan & Stamina | Pemain dapat berjalan dan berlari. Saat berlari, bar stamina akan berkurang dan beregenerasi saat diam. |
| 2 | Sistem Inventory Terbatas | Pemain dapat menyimpan maksimal 3 item logikal di dalam memori (misal: Senter/Flashlight, Keycard). |
| 3 | Interaksi Lingkungan (Area2D) | Fitur *Prompt* [F] otomatis yang muncul saat pemain berada di dekat objek yang bisa diinteraksi atau dikumpulkan. |
| 4 | Terminal/CMD In-Game | Pemain dapat membuka UI Terminal untuk mengetikkan perintah teks (seperti `use flashlight`, `ls`, `help`). |
| 5 | Sistem Pencahayaan Dinamis | Area sistem yang rusak bersifat gelap; pemain membutuhkan item senter (PointLight2D) yang harus diaktifkan melalui Terminal. |
| 6 | Sistem Auto-Correction & Typo Handling | Sistem akan mendeteksi *typo* pada ketikan pemain menggunakan algoritma *Levenshtein Distance* (*"Did you mean...?"*). |
| 7 | Notifikasi & Log Visual | Pop-up UI dan titik indikator merah saat pemain mendapatkan item atau data baru. |
| 8 | Puzzle | Rintangan untuk menguji pemahaman programming / kemampuan berpikir teknis user. |

---

## 3. Batasan Masalah

1. Game berjalan secara *offline* pada platform PC / Windows (format `.exe`) dengan mode permainan *Single Player*.

2. Alur permainan (*Level Design*) dibatasi menjadi 4 *Sequence* utama:
   - **Sequence 1 (Tutorial):** Pengenalan kontrol dasar, penggunaan Terminal/CMD, interaksi objek, dan pengenalan inventory serta puzzle dasar.
   - **Sequence 2 (Labirin & Stealth):** Pemain harus bernavigasi di map labirin sambil menghindari NPC *Cleaner Robot* yang sedang berpatroli menghapus sisa data.
   - **Sequence 3 (Puzzle Area):** Area yang berfokus penuh pada pemecahan teka-teki logika untuk membuka jalan keluar.
   - **Sequence 4 (Chase / Pengejaran):** Sekuens klimaks di mana karakter "Bit" dikejar oleh *Cleaner Robot* menuju *Extraction Port*.

3. Game memiliki 3 tingkat kesulitan (Easy, Medium, Hard). Tingkat kesulitan ini tidak merubah tata letak *puzzle*, melainkan hanya memodifikasi dua variabel gameplay: kapasitas/pengurangan stamina karakter utama dan kecerdasan/kecepatan patroli NPC *Cleaner Robot*.

4. Aset visual menggunakan gaya 2D Pixel Art.

---

## 4. Target Pengguna

| No | Peran / User | Deskripsi Target |
|----|--------------|-----------------|
| 1 | Pemain Umum / Gamers | Remaja atau dewasa (usia 12+) yang menyukai genre *puzzle-platformer*, *stealth*, dan permainan bernuansa *cyber/hacking*. |
| 2 | Pelajar IT / SMK | Siswa yang tertarik dengan mekanik game yang mengadaptasi antarmuka *Command Line Interface* (CLI) dan manajemen memori sistem. |

---

## 5. Teknologi yang Digunakan

| Komponen | Teknologi |
|----------|-----------|
| Game Engine | Godot Engine 4.5.1 |
| Bahasa Pemrograman | GDScript |
| Platform Target | PC / Windows (.exe) |
| Desain Asset / Karakter | Asset dengan lisensi gratis |
| Produksi Audio & BGM | FL Studio 20 (pembuatan *beat*, efek suara *glitch*, dan musik latar original) |

---

## 6. Struktur Menu Game

### Start Game
- Login / Register

### Main Menu
- Mulai Game Baru → *Pilih Kesulitan (Easy / Medium / Hard)*
- Lanjutkan (Load System)
- Pengaturan (Volume BGM, SFX, Kontrol)
- Keluar

### In-Game HUD (Heads-Up Display)
- Indikator Bar Stamina (menyesuaikan tingkat kesulitan)
- Icon Terminal & Notifikasi Item Baru (merah)
- Jendela Terminal/CMD Interaktif
- Tulisan *Prompt* Interaksi [F] yang muncul dinamis
- Puzzle

### Pause Menu
- Lanjutkan
- Pengaturan
- Kembali ke Main Menu
