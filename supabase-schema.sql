
-- BANNERPRINT PRO V3 - SUPABASE DATABASE
create extension if not exists pgcrypto;

create table if not exists outlets (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'cashier' check (role in ('owner','admin','cashier','warehouse')),
  outlet_id uuid references outlets(id),
  created_at timestamptz default now()
);

create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  address text,
  created_at timestamptz default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Lainnya',
  unit text not null default 'Unit',
  selling_price numeric(14,2) not null default 0,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists materials (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  width_cm numeric(10,2),
  cost_per_meter numeric(14,2) default 0,
  minimum_meter numeric(12,2) default 0,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists material_rolls (
  id uuid primary key default gen_random_uuid(),
  material_id uuid not null references materials(id),
  outlet_id uuid not null references outlets(id),
  roll_no text,
  received_meter numeric(12,2) not null default 0,
  remaining_meter numeric(12,2) not null default 0,
  cost_per_meter numeric(14,2) default 0,
  received_at timestamptz default now()
);

create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  material_id uuid not null references materials(id),
  roll_id uuid references material_rolls(id),
  outlet_id uuid not null references outlets(id),
  type text not null check (type in ('IN','OUT','ADJUSTMENT')),
  meter numeric(12,2) not null,
  reference_no text,
  notes text,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

create table if not exists sales (
  id uuid primary key default gen_random_uuid(),
  invoice_no text unique not null,
  outlet_id uuid not null references outlets(id),
  customer_id uuid references customers(id),
  cashier_id uuid references profiles(id),
  status text not null default 'PAID' check (status in ('DRAFT','PAID','CREDIT','CANCELLED')),
  subtotal numeric(14,2) default 0,
  discount numeric(14,2) default 0,
  total numeric(14,2) default 0,
  paid numeric(14,2) default 0,
  change_amount numeric(14,2) default 0,
  payment_method text default 'CASH',
  created_at timestamptz default now()
);

create table if not exists sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references sales(id) on delete cascade,
  product_id uuid references products(id),
  product_name text not null,
  unit text,
  qty numeric(12,2) not null,
  unit_price numeric(14,2) not null,
  width_meter numeric(10,2),
  length_meter numeric(10,2),
  area_m2 numeric(12,2),
  total numeric(14,2) not null
);

create table if not exists production_usage (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid references sales(id),
  material_id uuid not null references materials(id),
  outlet_id uuid not null references outlets(id),
  width_meter numeric(10,2),
  length_meter numeric(10,2),
  qty numeric(12,2) default 1,
  waste_percent numeric(6,2) default 0,
  used_meter numeric(12,2) not null,
  created_at timestamptz default now()
);

-- Seed outlet
insert into outlets(name,address)
select 'Outlet Utama',''
where not exists (select 1 from outlets);

-- Seed product prices from the provided price list
insert into products(name,category,unit,selling_price) values
('Flexy 280Gr','Outdoor','Meter',18000),
('Flexy 340Gr','Outdoor','Meter',25000),
('Flexy 440Gr','Outdoor','Meter',45000),
('Backlite 510Gr','Outdoor','Meter',65000),
('X Banner Flexy 280Gr','Paket Printing + Alat','Set',65000),
('X Banner Flexy 340Gr','Paket Printing + Alat','Set',85000),
('X Banner Albatros','Paket Printing + Alat','Set',130000),
('Roll Up Banner Flexy 340Gr','Paket Printing + Alat','Set',200000),
('Roll Up Banner Albatros','Paket Printing + Alat','Set',270000),
('Sticker Vinyl','Indoor','Meter',65000),
('Albatros','Indoor','Meter',70000),
('Sticker OneWay','Indoor','Meter',85000),
('Laminating Meteran','Laminating','Meter',25000),
('Laminating A3+','Laminating','Lembar',3000),
('Cutting Meteran','Jasa Cutting','Meter',30000),
('Cutting A3+','Jasa Cutting','Lembar',3000),
('Stempel Flash','Stempel','Buah',65000),
('ID Card - 1 Set Tali & Tempat','ID Card','Set',35000),
('ID Card - Hanya ID Card','ID Card','Buah',8000),
('Kartu Nama - 1 Sisi (Box isi 100)','Kartu Nama','Box',25000),
('Kartu Nama - 2 Sisi (Box isi 100)','Kartu Nama','Box',50000),
('Nota/Kwitansi 1 Warna 2 Ply','Print Offset','Rim',350000),
('Nota/Kwitansi 2 Warna 2 Ply','Print Offset','Rim',500000),
('Nota/Kwitansi 3 Warna 2 Ply','Print Offset','Rim',550000),
('Cetak Buku Yasin Isi 248','Print Offset','Buku',25000),
('Cetak Buku Yasin Isi 448','Print Offset','Buku',70000)
on conflict do nothing;

insert into products(name,category,unit,selling_price) values
('HVS 100 - Print 1 Sisi','Print Kertas A3+','Lembar',4500),
('Art Paper 120 - Print 1 Sisi','Print Kertas A3+','Lembar',5000),
('Art Paper 150 - Print 1 Sisi','Print Kertas A3+','Lembar',5000),
('Art Carton 230 - Print 1 Sisi','Print Kertas A3+','Lembar',5000),
('Art Carton 260 - Print 1 Sisi','Print Kertas A3+','Lembar',5000),
('Kartu Tic - Print 1 Sisi','Print Kertas A3+','Lembar',8000),
('Sticker Chromo - Print 1 Sisi','Print Kertas A3+','Lembar',7000),
('Sticker Vinyl - Print 1 Sisi','Print Kertas A3+','Lembar',10000),
('Sticker Transparan - Print 1 Sisi','Print Kertas A3+','Lembar',12000),
('HVS 100 - Print 2 Sisi','Print Kertas A3+','Lembar',5500),
('Art Paper 120 - Print 2 Sisi','Print Kertas A3+','Lembar',6000),
('Art Paper 150 - Print 2 Sisi','Print Kertas A3+','Lembar',6500),
('Art Carton 230 - Print 2 Sisi','Print Kertas A3+','Lembar',7000),
('Art Carton 260 - Print 2 Sisi','Print Kertas A3+','Lembar',7500),
('Kartu Tic - Print 2 Sisi','Print Kertas A3+','Lembar',8000)
on conflict do nothing;

-- Seed material master
insert into materials(name,width_cm,cost_per_meter,minimum_meter)
select * from (values
('Flexy 280Gr',320,18000,10),
('Flexy 340Gr',320,25000,10),
('Flexy 440Gr',320,45000,5),
('Backlite 510Gr',320,65000,5),
('Sticker Vinyl',150,65000,5),
('Albatros',150,70000,5),
('Sticker OneWay',150,85000,5)
) v(name,width_cm,cost_per_meter,minimum_meter)
where not exists (select 1 from materials m where m.name=v.name);

-- RLS: production-grade starting point. Adjust policies after user roles are set.
alter table outlets enable row level security;
alter table profiles enable row level security;
alter table customers enable row level security;
alter table products enable row level security;
alter table materials enable row level security;
alter table material_rolls enable row level security;
alter table stock_movements enable row level security;
alter table sales enable row level security;
alter table sale_items enable row level security;
alter table production_usage enable row level security;

create policy "authenticated read products" on products for select to authenticated using (true);
create policy "authenticated read materials" on materials for select to authenticated using (true);
create policy "authenticated read customers" on customers for select to authenticated using (true);
create policy "authenticated read outlets" on outlets for select to authenticated using (true);
create policy "authenticated write customers" on customers for all to authenticated using (true) with check (true);
create policy "authenticated write sales" on sales for all to authenticated using (true) with check (true);
create policy "authenticated write sale_items" on sale_items for all to authenticated using (true) with check (true);
create policy "authenticated write stock" on stock_movements for all to authenticated using (true) with check (true);
create policy "authenticated write rolls" on material_rolls for all to authenticated using (true) with check (true);
create policy "authenticated write usage" on production_usage for all to authenticated using (true) with check (true);
