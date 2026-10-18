-- =========================================================
-- Brajah Detailers & Movers — Supabase schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- =========================================================

-- ---------- BOOKINGS ----------
-- Created when someone submits the instant quote calculator's
-- "Book This Service" form.
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  service_type text not null,           -- moving | cleaning | detailing | fumigation
  details jsonb not null default '{}',  -- raw calculator field values (bedrooms, package, etc.)
  price_low integer not null default 0,
  price_high integer not null default 0,
  full_name text not null,
  phone text not null,
  email text,
  preferred_date date,
  status text not null default 'new'    -- new | confirmed | completed | cancelled
);

-- ---------- CONTACT MESSAGES ----------
-- Created when someone submits the "Get in touch" contact form.
create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  full_name text not null,
  phone text not null,
  email text not null,
  service_interest text,
  message text,
  status text not null default 'unread' -- unread | read | replied
);

-- ---------- NEWSLETTER SUBSCRIBERS ----------
-- Created when someone submits the footer newsletter form.
create table if not exists public.newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  email text not null unique
);

-- =========================================================
-- ROW LEVEL SECURITY
-- Public visitors (the anon key used in the website) may only
-- INSERT new rows. They can never read, edit, or delete data —
-- that keeps every other customer's booking/contact info private.
-- You (the business owner) read everything from the Supabase
-- Table Editor while logged in, or via a future admin dashboard
-- using the service_role key on a secure backend.
-- =========================================================

alter table public.bookings enable row level security;
alter table public.contact_messages enable row level security;
alter table public.newsletter_subscribers enable row level security;

create policy "Public can submit bookings"
  on public.bookings for insert
  to anon
  with check (true);

create policy "Public can submit contact messages"
  on public.contact_messages for insert
  to anon
  with check (true);

create policy "Public can subscribe to newsletter"
  on public.newsletter_subscribers for insert
  to anon
  with check (true);

-- No select/update/delete policies are created for the `anon` role,
-- so the public site can never read back this data — only insert it.

-- Helpful indexes for when you view/query data later
create index if not exists bookings_created_at_idx on public.bookings (created_at desc);
create index if not exists bookings_status_idx on public.bookings (status);
create index if not exists contact_messages_created_at_idx on public.contact_messages (created_at desc);
