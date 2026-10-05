# BannerPrint Pro V3

Versi awal aplikasi Next.js + Supabase untuk percetakan.

## Isi
- Database PostgreSQL/Supabase
- Master produk & harga dari daftar yang diberikan
- Master bahan
- Struktur roll bahan dan mutasi stok
- Customer
- Penjualan & item penjualan
- Produksi/pemakaian bahan
- Outlet & role user
- Dashboard, kasir, laporan
- `.env.example`

## Menjalankan
1. Buat project Supabase.
2. Jalankan `supabase-schema.sql` di SQL Editor Supabase.
3. Salin `.env.example` menjadi `.env.local` dan isi URL + anon key.
4. `npm install`
5. `npm run dev`

Catatan: kode V3 ini adalah fondasi database online. Untuk produksi, policy RLS dan fungsi transaksi stok perlu dikunci lebih lanjut berdasarkan role/outlet sebelum dipakai operasional.
