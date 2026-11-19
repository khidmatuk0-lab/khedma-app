-- إعدادات أرباح منصة خدمة (تجريبي)
-- شغّل هذا الملف في Supabase SQL Editor بعد إنشاء حساب المالك.
-- استبدل OWNER_USER_UUID بمعرّف حسابك من Authentication > Users.
create table if not exists public.platform_commission_settings (
  category text primary key check (category in ('transport','market','property','home_services','shipping','jobs','food')),
  rate_percent numeric(5,2) not null default 5 check (rate_percent >= 0 and rate_percent <= 30),
  minimum_fee numeric(10,2) not null default 5 check (minimum_fee >= 0),
  updated_at timestamptz not null default now()
);
insert into public.platform_commission_settings(category,rate_percent,minimum_fee) values
('transport',5,5),('market',5,5),('property',5,5),('home_services',5,5),('shipping',5,5),('jobs',0,0),('food',5,5)
on conflict(category) do nothing;
alter table public.platform_commission_settings enable row level security;
drop policy if exists "Public can read commission settings" on public.platform_commission_settings;
create policy "Public can read commission settings" on public.platform_commission_settings for select using (true);
drop policy if exists "Only admins manage commission settings" on public.platform_commission_settings;
create policy "Only admins manage commission settings" on public.platform_commission_settings for all to authenticated
using (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'))
with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

-- ترقية حساب المالك الذي ظهر في لوحة Authentication > Users:
update public.profiles set role='admin' where id='5c3e7351-6747-4d3a-9aaf-014fff9655aa';
