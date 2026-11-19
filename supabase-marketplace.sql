create table if not exists public.listings (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 category text not null check (category in ('transport','market','property','home_services','shipping','jobs','food')),
 title text not null, description text not null, governorate text not null,
 price numeric, contact_phone text not null,
 status text not null default 'active' check (status in ('active','paused','removed')),
 created_at timestamptz not null default now()
);
create index if not exists listings_category_gov_status_idx on public.listings(category,governorate,status,created_at desc);
alter table public.listings enable row level security;
drop policy if exists "Anyone can read active listings" on public.listings;
create policy "Anyone can read active listings" on public.listings for select using (status='active' or auth.uid()=owner_id);
drop policy if exists "Users can create own listings" on public.listings;
create policy "Users can create own listings" on public.listings for insert to authenticated with check (auth.uid()=owner_id);
drop policy if exists "Owners can update own listings" on public.listings;
create policy "Owners can update own listings" on public.listings for update to authenticated using (auth.uid()=owner_id) with check (auth.uid()=owner_id);
drop policy if exists "Owners can delete own listings" on public.listings;
create policy "Owners can delete own listings" on public.listings for delete to authenticated using (auth.uid()=owner_id);