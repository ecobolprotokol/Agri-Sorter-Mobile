General Agri-Sorter Mobile

Smart Hands-Free Sorting

Versi spesifikasi: 1.0.0
Platform: Android / Android-based
Framework: Flutter
Mode operasi: 100% Offline
Metode Computer Vision: HSV + Geometri
Input tambahan: Firmness oleh operator
Output: Grade, jumlah per grade, total komoditas, detail hasil, dan laporan

---

1. Deskripsi Proyek

General Agri-Sorter Mobile adalah aplikasi mobile berbasis Flutter yang digunakan untuk membantu proses penyortiran komoditas pertanian secara cepat, objektif, dan offline.

Aplikasi menggunakan kamera smartphone yang ditempatkan pada tripod untuk melakukan analisis visual terhadap komoditas pertanian.

Analisis visual menggunakan:

- segmentasi objek;
- analisis warna HSV;
- analisis bentuk/geometri;
- parameter grading yang dapat dikalibrasi dari dataset.

Pemeriksaan fisik seperti firmness/kekerasan buah tetap dilakukan oleh operator dan menjadi input tambahan bagi sistem.

Sistem dirancang sebagai commodity-agnostic sorter, sehingga jenis komoditas dapat ditambahkan melalui UI tanpa mengubah source code utama.

---

2. Tujuan

2.1 Tujuan Utama

Membangun aplikasi sortir komoditas pertanian yang:

1. berjalan sepenuhnya offline;
2. menggunakan kamera smartphone;
3. melakukan analisis visual secara otomatis;
4. mendukung berbagai jenis komoditas;
5. memungkinkan profil komoditas dibuat melalui UI;
6. memungkinkan dataset diunggah melalui UI;
7. melakukan kalibrasi HSV dan geometri berdasarkan dataset;
8. menggabungkan hasil visual dengan pemeriksaan firmness operator;
9. memberikan hasil grading secara otomatis;
10. memberikan instruksi suara kepada operator;
11. menyimpan seluruh hasil sortir;
12. memberikan rekap jumlah setiap grade;
13. memberikan total jumlah komoditas;
14. memberikan detail setiap hasil pemeriksaan;
15. menyediakan export laporan.

---

3. Prinsip Sistem

Arsitektur inti:

Dataset
   ↓
Preprocessing
   ↓
Segmentation
   ↓
Feature Extraction
   ↓
HSV + Geometry Calibration
   ↓
Commodity Profile
   ↓
Live Camera
   ↓
Feature Extraction
   ↓
Grading Engine
   ↓
Firmness Input
   ↓
Final Grade
   ↓
Database
   ↓
Summary + Detail + Report
   ↓
Text-to-Speech

---

4. Batasan Sistem

4.1 Sistem tidak menggunakan cloud

Seluruh proses utama harus dapat berjalan tanpa koneksi internet:

- kamera;
- preprocessing;
- segmentasi;
- HSV analysis;
- geometry analysis;
- calibration;
- grading;
- database;
- text-to-speech;
- laporan.

Internet tidak boleh menjadi dependency untuk proses sortir.

4.2 Firmness tidak diukur kamera

Kamera hanya digunakan untuk karakteristik visual.

Firmness diperoleh dari operator melalui UI.

Visual Analysis
       +
Firmness Operator
       ↓
Final Grading

Aplikasi tidak boleh mengklaim bahwa kamera mengukur firmness secara langsung.

---

5. Konsep Komoditas Dinamis

Jenis komoditas tidak boleh di-hardcode dalam "GradingEngine".

Contoh komoditas:

Pepaya
Tomat
Jeruk
Cabai
Mangga

harus diperlakukan sebagai Commodity Profile.

Struktur:

Commodity
├── identity
├── variety
├── dataset
├── color parameters
├── geometry parameters
├── firmness parameters
├── grade rules
└── calibration metadata

Menambahkan komoditas baru dilakukan melalui UI.

---

6. Dataset Manager

Aplikasi harus menyediakan fitur untuk mengelola dataset secara offline.

6.1 Fungsi

- tambah dataset;
- import gambar;
- mengambil foto menggunakan kamera;
- memberi label;
- menghapus sampel;
- melihat preview;
- melihat jumlah sampel;
- menjalankan validasi dataset;
- menjalankan kalibrasi.

6.2 Label Dataset

Minimal:

Grade A
Grade B
Reject / Afkir

Sistem harus memungkinkan penambahan label sesuai kebutuhan komoditas.

Contoh:

Pepaya
├── Matang
├── Setengah Matang
├── Mentah
└── Afkir

Label dataset dapat dipetakan ke grade akhir.

---

7. Dataset Structure

Dataset pengguna tidak disimpan sebagai Flutter asset permanen.

"assets/" hanya digunakan untuk:

assets/
└── default_profiles/

Dataset pengguna disimpan pada local storage aplikasi.

Contoh struktur logis:

local_data/
├── commodities/
│   ├── papaya_california/
│   │   ├── profile.json
│   │   └── dataset/
│   │       ├── sample_001.jpg
│   │       ├── sample_002.jpg
│   │       └── ...
│   │
│   └── tomato/
│       ├── profile.json
│       └── dataset/
│
└── reports/

Path aktual filesystem harus dikelola melalui abstraction layer storage.

---

8. Preprocessing

Setiap gambar/frame harus melalui preprocessing sebelum analisis.

Tahapan:

Input Image
    ↓
Resize
    ↓
Crop / ROI
    ↓
Noise Reduction
    ↓
Color Space Conversion
    ↓
Segmentation

Parameter preprocessing harus dapat dikonfigurasi melalui Commodity Profile jika diperlukan.

---

9. Segmentasi

Tujuan segmentasi adalah memisahkan objek komoditas dari background.

Output:

Original Image
       ↓
Object Mask
       ↓
Object Region

Segmentasi dapat menggunakan:

- HSV threshold;
- morphology;
- connected components;
- contour detection.

Tahapan morphology yang dapat digunakan:

Opening
Closing

untuk mengurangi noise dan memperbaiki mask.

---

10. HSV Analysis

Sistem menganalisis:

- Hue;
- Saturation;
- Value.

Fitur yang dapat dihitung:

hue_mean
hue_std
saturation_mean
saturation_std
value_mean
value_std

Selain nilai rata-rata, sistem dapat menyimpan distribusi:

P10
P25
P50
P75
P90

Jika diperlukan.

---

11. Persentase Kematangan

Untuk komoditas yang menggunakan perubahan warna sebagai indikator kematangan, sistem dapat menghitung:

ripe_percentage =
jumlah pixel matang / jumlah pixel objek × 100

Contoh:

Object pixels = 100.000
Ripe pixels   = 82.000

Ripe percentage = 82%

Nilai ini menjadi salah satu input Grading Engine.

---

12. Geometry Analysis

Sistem harus dapat mengekstrak fitur geometris dari object mask.

Minimal:

area
width
height
aspect_ratio
perimeter
circularity

Formula:

aspect_ratio = width / height

circularity = 4 × π × area / perimeter²

Fitur tambahan yang dapat ditambahkan:

solidity
extent
equivalent_diameter

---

13. Calibration Engine

Calibration Engine mengubah dataset berlabel menjadi parameter Commodity Profile.

Pipeline:

Labeled Dataset
      ↓
Feature Extraction
      ↓
Group by Label
      ↓
Statistical Analysis
      ↓
Parameter Generation
      ↓
Validation
      ↓
Commodity Profile

Kalibrasi harus dilakukan secara offline.

---

14. Kalibrasi HSV

Untuk setiap grade, sistem menghitung statistik HSV.

Contoh:

{
  "hue": {
    "mean": 42.5,
    "std": 8.2,
    "p10": 31.0,
    "p50": 43.0,
    "p90": 54.0
  }
}

Nilai tersebut merupakan contoh struktur data, bukan threshold universal.

Threshold aktual harus berasal dari dataset.

---

15. Kalibrasi Geometri

Sistem menghitung distribusi fitur bentuk untuk masing-masing grade.

Contoh:

{
  "aspect_ratio": {
    "mean": 1.42,
    "std": 0.12
  },
  "circularity": {
    "mean": 0.71,
    "std": 0.08
  }
}

---

16. Validation Dataset

Dataset harus dapat dipisahkan menjadi:

Training / Calibration Set
Validation Set

Untuk rule-based system, istilah calibration set lebih tepat daripada training set.

Tujuan validation:

- menguji threshold;
- menemukan overlap antar-grade;
- mengidentifikasi false classification;
- mengevaluasi parameter.

Sistem harus menghindari penggunaan sampel yang sama untuk kalibrasi dan evaluasi performa jika ingin menghasilkan metrik validasi yang bermakna.

---

17. Commodity Profile

Contoh struktur:

{
  "id": "papaya_california",
  "name": "Pepaya",
  "variety": "California",
  "version": 1,
  "method": "hsv_geometry",

  "features": {
    "color": {},
    "geometry": {}
  },

  "grades": {
    "A": {},
    "B": {},
    "REJECT": {}
  },

  "firmness": {},

  "calibration": {
    "sample_count": 120,
    "calibrated_at": "2026-09-19"
  }
}

Profile harus mempunyai versioning.

Contoh:

papaya_california
version 1
version 2
version 3

Hal ini memungkinkan pengguna mengetahui parameter mana yang digunakan pada suatu sesi sortir.

---

18. Grading Engine

Grading Engine menerima:

Vision Features
+
Commodity Profile
+
Firmness Input

Output:

GradingResult

Contoh:

{
  "grade": "A",
  "confidence": 0.91,
  "ripe_percentage": 87.4,
  "firmness": "FIRM"
}

---

19. Grading Rules

Grading harus dapat menggunakan kombinasi beberapa fitur.

Contoh konsep:

Visual Score
    =
Color Score × Color Weight
+
Geometry Score × Geometry Weight

Final Score
    =
Visual Score
+
Firmness Score

Bobot harus berasal dari Commodity Profile.

Contoh:

{
  "color_weight": 0.6,
  "geometry_weight": 0.4
}

Nilai dan formula aktual harus dapat dikonfigurasi.

---

20. Firmness

Firmness minimal memiliki:

FIRM
MEDIUM
SOFT

atau:

1 = Firm
2 = Medium
3 = Soft

UI harus memungkinkan konfigurasi sesuai karakteristik komoditas.

Contoh:

┌──────────────────────────┐
│ Pemeriksaan Firmness     │
├──────────────────────────┤
│                          │
│  [ FIRM ]                │
│                          │
│  [ MEDIUM ]              │
│                          │
│  [ SOFT ]                │
│                          │
└──────────────────────────┘

---

21. Hands-Free Workflow

Workflow sortir:

START SESSION
      ↓
Camera Ready
      ↓
Object Detected
      ↓
Capture
      ↓
Visual Analysis
      ↓
Voice:
"Periksa firmness"
      ↓
Operator checks fruit
      ↓
Firmness Input
      ↓
Grading
      ↓
Voice:
"Grade A"
      ↓
Operator places fruit
      ↓
Save Result
      ↓
Next Object

Operator tidak harus menyentuh layar selama proses kamera berjalan, kecuali pada tahap input firmness jika belum menggunakan mekanisme input alternatif.

---

22. Text-to-Speech

Sistem harus memberikan feedback suara.

Contoh:

"Periksa firmness"

"Grade A"

"Grade B"

"Afkir"

"Objek tidak terdeteksi"

"Silakan ulangi"

TTS harus bekerja offline jika engine/platform yang digunakan mendukung paket bahasa offline.

---

23. Sorting Session

Setiap proses sortir harus berada dalam sebuah Sorting Session.

Contoh:

Session #00021
Tanggal: 19-09-2026
Mulai: 08:00
Selesai: 09:20

Session menyimpan:

session_id
started_at
finished_at
operator
location
commodity/profile
total_items

---

24. Multi-Commodity Session

Satu session dapat berisi lebih dari satu komoditas jika workflow pengguna membutuhkannya.

Contoh:

Session #00021

Pepaya
├── Grade A: 125
├── Grade B: 55
└── Afkir: 20

Tomat
├── Grade A: 180
├── Grade B: 90
└── Afkir: 30

Jika satu sesi hanya diperbolehkan untuk satu komoditas, struktur database tetap harus mendukung relasi tersebut agar dapat dikembangkan kemudian.

---

25. Sorting Result

Setiap buah/objek menghasilkan satu "SortingResult".

Minimal:

result_id
session_id
commodity_id
profile_version
grade
confidence
firmness
timestamp
image_path

---

26. Vision Features

Jika debugging atau audit diperlukan, simpan fitur visual:

ripe_percentage
hue_mean
hue_std
saturation_mean
saturation_std
value_mean
value_std
area
width
height
aspect_ratio
perimeter
circularity

Tidak semua fitur wajib ditampilkan kepada operator.

---

27. Reason / Explanation

Setiap hasil harus memiliki alasan grading yang dapat dibaca manusia.

Contoh:

Grade A

✓ Kematangan sesuai
✓ Bentuk sesuai
✓ Firmness sesuai

Contoh Afkir:

Afkir

✗ Kematangan di bawah threshold
✓ Bentuk sesuai
✗ Firmness terlalu lunak

Tujuannya adalah audit dan debugging.

---

28. Summary Hasil Sortir

Sistem harus menghitung minimal:

Total komoditas
Total Grade A
Total Grade B
Total Afkir
Persentase Grade A
Persentase Grade B
Persentase Afkir

Contoh:

Total: 500

Grade A: 305
Grade B: 145
Afkir: 50

Formula:

percentage =
grade_count / total_count × 100

---

29. Grouping

Hasil harus dikelompokkan berdasarkan:

Session
    ↓
Commodity
    ↓
Grade
    ↓
Individual Result

Contoh:

Session #00021
│
├── Pepaya
│   ├── Grade A
│   ├── Grade B
│   └── Afkir
│
└── Tomat
    ├── Grade A
    ├── Grade B
    └── Afkir

---

30. Grade Detail

Ketika operator membuka satu grade, sistem menampilkan:

Commodity
Grade
Count
Percentage
Average Confidence
Average Ripe Percentage
Firmness Distribution

Contoh:

Pepaya
Grade A

Jumlah              125
Persentase           62.5%
Avg Confidence       91.2%
Avg Maturity         87.4%

Firmness
Firm                  78
Medium                47
Soft                   0

---

31. Individual Result Detail

Setiap hasil dapat dibuka untuk melihat:

Sample #001

Grade: A
Confidence: 91.2%

Maturity: 87.4%
Hue Mean: ...
Saturation Mean: ...
Value Mean: ...

Area: ...
Aspect Ratio: ...
Circularity: ...

Firmness: Firm

Reason:
- Color sesuai
- Shape sesuai
- Firmness sesuai

Jika gambar disimpan, pengguna dapat melihat gambar hasil analisis.

---

32. Database

Database lokal direkomendasikan menggunakan SQLite melalui abstraction/repository layer.

Tabel utama:

commodities
commodity_profiles
datasets
dataset_samples
sorting_sessions
sorting_results
vision_features
grade_summaries

Relasi:

commodities
     │
     ├── commodity_profiles
     │
     └── datasets
             │
             └── dataset_samples

sorting_sessions
     │
     └── sorting_results
              │
              └── vision_features

---

33. Data Integrity

Setiap "SortingResult" harus menyimpan:

commodity_id
profile_version
timestamp

Tujuannya agar hasil lama tetap dapat ditelusuri meskipun profil grading diperbarui.

Contoh:

Pepaya
Profile v1 → digunakan Session #001
Profile v2 → digunakan Session #002

Jangan mengubah interpretasi hasil lama hanya karena profile terbaru berubah.

---

34. History

Menu History menampilkan seluruh session:

19 Sep 2026
Pepaya
500 buah
Grade A: 305
Grade B: 145
Afkir: 50

18 Sep 2026
Tomat
800 buah
...

Filter:

Tanggal
Komoditas
Grade
Operator
Session

---

35. Export

Sistem harus mendukung export hasil.

Minimal:

CSV
JSON

Format laporan dapat dikembangkan menjadi PDF.

Contoh CSV:

session_id,commodity,grade,count,percentage
00021,Pepaya,Grade A,125,62.5
00021,Pepaya,Grade B,55,27.5
00021,Pepaya,Afkir,20,10

---

36. Report

Laporan harus mempunyai struktur:

GENERAL AGRI-SORTER

Sorting Report

Session:
Tanggal:
Operator:
Komoditas:

SUMMARY
────────────────────
Total:
Grade A:
Grade B:
Afkir:

DETAIL PER KOMODITAS
────────────────────

Pepaya
Grade A:
Grade B:
Afkir:

Tomat
Grade A:
Grade B:
Afkir:

CALIBRATION
────────────────────
Profile:
Version:
Dataset:

---

37. UI/UX Navigation

Navigasi utama:

Dashboard
│
├── Mulai Sortir
│
├── Komoditas
│
├── Dataset
│
├── Kalibrasi
│
├── Riwayat
│
└── Pengaturan

---

38. Dashboard

Dashboard menampilkan:

Total session hari ini
Total komoditas hari ini
Total Grade A
Total Grade B
Total Afkir
Komoditas aktif

---

39. Commodity Management

Fitur:

Tambah Komoditas
Edit Komoditas
Hapus Komoditas
Duplikasi Profile
Import Profile
Export Profile

Contoh:

Pepaya California
Profile v3

[ Dataset ]
[ Kalibrasi ]
[ Test ]
[ Edit ]
[ Export ]

---

40. Dataset UI

Dataset page:

Dataset Pepaya California

Total Sample: 120

Grade A       40
Grade B       40
Afkir         40

[ + Tambah Foto ]
[ Import Dataset ]
[ Kelola Label ]
[ Kalibrasi ]

---

41. Calibration UI

Tahapan:

Pilih Dataset
      ↓
Validasi Dataset
      ↓
Extract Features
      ↓
Kalibrasi HSV
      ↓
Kalibrasi Geometri
      ↓
Test Validation
      ↓
Preview Parameter
      ↓
Simpan Profile

---

42. Test Mode

Sebelum profile diterapkan, pengguna dapat menjalankan test.

TEST PROFILE

Input:
Sample baru

Result:
Predicted: Grade A

Confidence: 91%

Features:
Maturity: 87%
Shape: Compatible

Test mode harus menggunakan data yang berbeda dari calibration set jika digunakan untuk evaluasi performa.

---

43. Confidence

Sistem dapat menghasilkan confidence sebagai ukuran internal kecocokan terhadap profile.

Confidence bukan berarti probabilitas statistik yang terkalibrasi kecuali metode perhitungannya memang menjamin interpretasi tersebut.

Jika metode belum terkalibrasi secara probabilistik, UI sebaiknya menggunakan istilah:

Match Score

daripada memberikan interpretasi probabilitas.

---

44. Uncertain Result

Jika objek berada di area overlap antar-grade, sistem tidak boleh memaksakan klasifikasi tanpa batas.

Tambahkan status:

UNCERTAIN

Workflow:

Vision
  ↓
Uncertain
  ↓
Operator Review
  ↓
Manual Grade

Hal ini penting untuk mengurangi kesalahan grading pada objek yang berada dekat threshold.

---

45. Camera Requirements

Mode kamera:

Tripod / Fixed Camera

Kondisi pengambilan gambar sebaiknya dikontrol:

- jarak kamera;
- sudut kamera;
- background;
- pencahayaan;
- posisi buah;
- resolusi.

Profile dapat menyimpan parameter setup jika diperlukan.

---

46. Pencahayaan

Karena HSV sensitif terhadap kondisi pencahayaan, sistem harus menyediakan:

Calibration Environment

Parameter profile harus dikaitkan dengan kondisi kalibrasi.

Contoh metadata:

{
  "lighting": {
    "type": "indoor",
    "description": "LED fixed lighting"
  }
}

Perubahan besar pada pencahayaan dapat menyebabkan threshold yang dikalibrasi tidak lagi cocok.

---

47. Performance Target

Target awal:

Mode              Offline
Processing        On-device
UI                 Responsive
Camera             Continuous

Target waktu processing per objek harus ditentukan melalui pengujian perangkat nyata.

Jangan menetapkan angka performa sebagai fakta sebelum benchmark dilakukan.

---

48. Privacy

Semua foto dataset dan hasil sortir harus disimpan secara lokal secara default.

Tidak ada upload otomatis.

Jika fitur export/share ditambahkan, tindakan tersebut harus dilakukan secara eksplisit oleh pengguna.

---

49. Error Handling

Sistem harus menangani:

Camera unavailable
No object detected
Multiple objects detected
Segmentation failed
Invalid dataset
Insufficient dataset
Calibration failed
Profile missing
Storage error
TTS unavailable

Contoh:

"Objek tidak dapat dipisahkan dari background."

"Tambahkan sampel dataset sebelum melakukan kalibrasi."

"Objek berada di area tidak pasti. Silakan lakukan pemeriksaan manual."

---

50. Minimum Dataset Requirement

Sistem harus memungkinkan konfigurasi jumlah minimum sampel.

Contoh default:

Minimum sample / grade: 20

Nilai tersebut adalah parameter awal, bukan batas ilmiah universal.

Jika jumlah sampel kurang:

Dataset belum mencukupi untuk kalibrasi.
Tambahkan sampel.

---

51. Arsitektur Repository

general-agri-sorter/
│
├── README.md
├── LICENSE
├── CHANGELOG.md
├── pubspec.yaml
│
├── android/
│
├── assets/
│   └── default_profiles/
│
├── lib/
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── app.dart
│   │   ├── routes.dart
│   │   └── theme.dart
│   │
│   ├── core/
│   │   ├── database/
│   │   ├── storage/
│   │   ├── services/
│   │   ├── constants/
│   │   └── errors/
│   │
│   ├── features/
│   │   ├── dashboard/
│   │   ├── commodity/
│   │   ├── dataset/
│   │   ├── calibration/
│   │   ├── vision/
│   │   ├── grading/
│   │   ├── sorting/
│   │   ├── history/
│   │   └── reports/
│   │
│   └── shared/
│       └── widgets/
│
├── test/
│   ├── vision/
│   ├── calibration/
│   ├── grading/
│   ├── dataset/
│   └── sorting/
│
├── integration_test/
│
└── docs/
    ├── architecture.md
    ├── dataset.md
    ├── calibration.md
    ├── grading.md
    ├── database.md
    └── testing.md

---

52. Modul Utama

Dataset

Dataset → Sample Management

Vision

Image → Features

Calibration

Features + Labels → Profile

Grading

Features + Profile + Firmness → Grade

Sorting

Grade → Session Result

Reporting

Session Results → Summary + Detail + Export

---

53. Core Data Flow

                  DATASET
                     │
                     ▼
             FEATURE EXTRACTION
                     │
                     ▼
               CALIBRATION
                     │
                     ▼
             COMMODITY PROFILE
                     │
                     │
                     ▼
CAMERA ──────→ FEATURE EXTRACTION
                     │
                     ▼
               GRADING ENGINE
                     ▲
                     │
              FIRMNESS INPUT
                     │
                     ▼
                SORT RESULT
                     │
             ┌───────┴────────┐
             ▼                ▼
          DATABASE           TTS
             │
             ▼
          SESSION
             │
      ┌──────┼───────┐
      ▼      ▼       ▼
   SUMMARY DETAIL  REPORT

---

54. Prinsip Pengembangan

1. Offline-first
2. Data-driven
3. Commodity-agnostic
4. Modular
5. Testable
6. Versioned profile
7. Auditable result
8. Human-in-the-loop
9. Tidak mengubah hasil historis
10. Dataset dan profile dipisahkan dari source code

---

55. MVP

Versi MVP harus mencakup:

[x] Tambah komoditas
[x] Dataset upload melalui UI
[x] Label dataset
[x] Kamera
[x] Segmentasi sederhana
[x] HSV extraction
[x] Geometry extraction
[x] Calibration
[x] Commodity Profile
[x] Grading Engine
[x] Firmness input
[x] Text-to-Speech
[x] Sorting Session
[x] Jumlah Grade A/B/Afkir
[x] Total komoditas
[x] Detail hasil
[x] History
[x] CSV export

Fitur berikut dapat ditambahkan setelah MVP:

[ ] PDF report
[ ] Backup/restore
[ ] Profile import/export
[ ] Multiple camera profiles
[ ] Advanced lighting calibration
[ ] ML model
[ ] Barcode/QR batch
[ ] External sensor integration

---

56. Definisi Selesai MVP

MVP dianggap berhasil apabila operator dapat melakukan workflow berikut tanpa internet:

1. Membuka aplikasi
2. Membuat komoditas
3. Mengunggah dataset
4. Memberikan label
5. Melakukan kalibrasi
6. Menyimpan Commodity Profile
7. Memulai Sorting Session
8. Kamera mendeteksi objek
9. Sistem menganalisis HSV + geometri
10. Operator memasukkan firmness
11. Sistem menentukan grade
12. Sistem memberikan instruksi suara
13. Operator memindahkan komoditas
14. Hasil tersimpan
15. Session selesai
16. Sistem menghitung total
17. Sistem mengelompokkan berdasarkan grade
18. Sistem menampilkan detail
19. Sistem dapat melakukan export

---

57. Prinsip Utama Produk

DATASET
   ↓
CALIBRATE
   ↓
PROFILE
   ↓
SORT
   ↓
RECORD
   ↓
GROUP
   ↓
REPORT

General Agri-Sorter Mobile bukan hanya aplikasi kamera untuk menentukan grade.

Sistem merupakan pipeline lengkap:

«Dataset Management → Computer Vision → Calibration → Grading → Human Verification → Sorting Session → Aggregation → Reporting»

Dengan pendekatan ini, penambahan komoditas baru dilakukan melalui data dan konfigurasi, bukan perubahan source code inti.
