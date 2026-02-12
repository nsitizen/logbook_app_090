## Refleksi Penerapan Single Responsibility Principle (SRP)

Penerapan prinsip Single Responsibility Principle (SRP) sangat membantu saya
saat menambahkan fitur History Logger pada aplikasi Counter ini.

Dengan memisahkan tanggung jawab antara Controller dan View, seluruh logika
pencatatan riwayat aktivitas (seperti menambah, mengurangi, dan reset nilai)
dapat difokuskan sepenuhnya di dalam CounterController. Hal ini membuat proses
pengembangan fitur History Logger menjadi lebih terstruktur dan mudah dikelola.

Saat fitur riwayat ditambahkan, saya tidak perlu mengubah logika tampilan secara
berlebihan, karena View hanya bertugas menampilkan data yang sudah disediakan
oleh Controller. Selain itu, manipulasi struktur data List untuk membatasi hanya
5 aktivitas terakhir juga dapat dilakukan secara terpusat tanpa mempengaruhi
bagian UI.

Dengan SRP, kode menjadi lebih mudah dipahami, diuji, dan dikembangkan kembali
jika di masa depan ingin menambahkan fitur seperti undo/redo atau penyimpanan
riwayat ke database.
