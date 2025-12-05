create table public.customers (
  id uuid not null default gen_random_uuid (),
  uid uuid not null,
  name text not null,
  constraint customers_pkey primary key (id),
  constraint customers_uid_key unique (uid),
  constraint customers_uid_fkey foreign KEY (uid) references auth.users (id)
) TABLESPACE pg_default;


create table public.movies (
  id uuid not null default gen_random_uuid (),
  title text not null,
  description text not null,
  price double precision not null,
  image text not null,
  seats_number integer null default 47,
  "createdAt" timestamp with time zone null default now(),
  constraint movies_pkey primary key (id),
  constraint movies_title_key unique (title),
  constraint movies_image_key unique (image)
) TABLESPACE pg_default;

create table public.timeshows (
  id uuid not null default gen_random_uuid (),
  mid uuid not null,
  time timestamp with time zone not null,
  constraint timeshows_pkey primary key (id),
  constraint timeshows_mid_time_key unique (mid, "time"),
  constraint timeshows_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.reservations (
  id uuid not null default gen_random_uuid (),
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  seat text not null,
  test text null,
  constraint reservations_pkey primary key (id),
  constraint reservations_mid_tid_seat_key unique (mid, tid, seat),
  constraint reservations_cid_fkey foreign KEY (cid) references customers (id) on delete CASCADE,
  constraint reservations_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE,
  constraint reservations_tid_fkey foreign KEY (tid) references timeshows (id) on delete CASCADE
) TABLESPACE pg_default;


create table public.tickets (
  id uuid not null default gen_random_uuid (),
  total_price numeric not null,
  seats text[] not null,
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  constraint tickets_pkey primary key (id),
  constraint tickets_cid_fkey foreign KEY (cid) references customers (id) on delete CASCADE,
  constraint tickets_mid_fkey foreign KEY (mid) references movies (id) on delete CASCADE,
  constraint tickets_tid_fkey foreign KEY (tid) references timeshows (id) on delete CASCADE,
  constraint tickets_total_price_check check ((total_price > (0)::numeric))
) TABLESPACE pg_default;



