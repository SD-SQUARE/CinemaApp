-- Customers table hold auth id in and deatils about customer 
create table if not exists customers(
  id uuid primary key default gen_random_uuid(),
  uid uuid not null unique,
  name text not null,
  foreign key (uid) references auth.users(id)
); 


-- Movies table hold movie details
create table if not exists movies(
  id uuid primary key,
  title text not null unique,
  description text not null,
  price float not null,
  image text not null unique,
  seats_number int default 47
);


-- time show table contain show times for each movie
create table if not exists timeshows(
  id uuid primary key,
  mid uuid not null,
  time timestamptz not null unique,
  foreign key (mid) references movies(id) on delete cascade,
  unique (mid, time)
);

-- reservation table hold details about each user reservation seat to which movie and time
create table if not exists reservations(
  id uuid primary key,
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  seat text not null,
  foreign key (cid) references customers(id) on delete cascade,
  foreign key (mid) references movies(id) on delete cascade,
  foreign key (tid) references timeshows(id) on delete cascade,
  unique (
    mid,
    tid,
    seat
  )
);


-- ticket table hold details about checked out reservations

create table if not exists tickets(
  id uuid primary key,
  total_price numeric  not null check (total_price > 0),
  seats text[] not null,
  cid uuid not null,
  mid uuid not null,
  tid uuid not null,
  foreign key (cid) references customers(id) on delete cascade,
  foreign key (mid) references movies(id) on delete cascade,
  foreign key (tid) references timeshows(id) on delete cascade
);



-- Config Realtime for tables
alter publication supabase_realtime add table
  customers,
  movies,
  timeshows,
  reservations,
  tickets;


-- ADD RLS Policy 

-- Customers RLS

alter table customers enable row level security;

create policy "Users can see their own customer row"
on customers
for select
using (uid = auth.uid());


-- Movies RLS

alter table movies enable row level security;
create policy "Public can view movies" on movies
for select using (true);

-- Timeshows RLS

alter table timeshows enable row level security;
create policy "Public can view timeshows" on timeshows
for select using (true);


-- Reservation RLS 

alter table reservations enable row level security;

-- Everyone can read all reservations (needed to show booked seats)
create policy "Anyone can read reservations"
on reservations
for select using (true);

-- Only owners can insert reservations (book seat)
create policy "Customer can book their own reservation"
on reservations
for insert
with check (
  cid in (
    select id from customers where uid = auth.uid()
  )
);

-- Ticket RLS
alter table tickets enable row level security;

create policy "Customer can read own tickets"
on tickets
for select
using (
  cid in (
    select id from customers where uid = auth.uid()
  )
);

create policy "Customer can insert own tickets"
on tickets
for insert
with check (
  cid in (
    select id from customers where uid = auth.uid()
  )
);

-- Allow authenticated users to insert their own row
create policy "Users can insert their own customer row"
on customers
for insert
with check (uid = auth.uid());



-- statistcs Function

create or replace function get_tickets_summary()
returns jsonb
language plpgsql
as $$
declare
  v_total_tickets int;
  v_total_price numeric;
  v_ticket_list jsonb;
begin
  -- 1. Total number of tickets
  select count(*) into v_total_tickets from tickets;

  -- 2. Total price sum
  select coalesce(sum(total_price), 0) into v_total_price from tickets;

  -- 3. Ticket list with details
  select jsonb_agg(
    jsonb_build_object(
      'ticket_id', t.id,
      'customer_name', c.name,
      'movie_name', m.title,
      'show_time', ts.time,
      'price', m.price,
      'total_price', t.total_price
    )
  )
  into v_ticket_list
  from tickets t
  join customers c on t.cid = c.id
  join movies m on t.mid = m.id
  join timeshows ts on t.tid = ts.id;

  -- 4. Return final JSON object
  return jsonb_build_object(
    'total_tickets', v_total_tickets,
    'total_price', v_total_price,
    'tickets', coalesce(v_ticket_list, '[]'::jsonb)
  );
end;
$$;


-- delete ticket function

create or replace function cancel_ticket(
  p_ticket_id uuid
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_cid uuid;
  v_tid uuid;
  v_showtime timestamptz;
begin
  -- Fetch ticket info
  select cid, tid
  into v_cid, v_tid
  from tickets
  where id = p_ticket_id;

  if v_cid is null then
    return jsonb_build_object('ok', false, 'reason', 'ticket_not_found');
  end if;

  -- Validate ticket owner
  if v_cid not in (select id from customers where uid = auth.uid()) then
    return jsonb_build_object('ok', false, 'reason', 'not_owner');
  end if;

  -- Fetch showtime datetime
  select time into v_showtime
  from timeshows
  where id = v_tid;

  -- Check expiration
  if now() >= v_showtime then
    return jsonb_build_object('ok', false, 'reason', 'expired');
  end if;

  -- Delete reservations linked to this ticket
  delete from reservations
  where cid = v_cid
    and mid = (select mid from tickets where id = p_ticket_id)
    and tid = v_tid
    and seat = any (select seats from tickets where id = p_ticket_id);

  -- Delete the ticket
  delete from tickets
  where id = p_ticket_id;

  return jsonb_build_object('ok', true, 'ticket_id', p_ticket_id);
end;
$$;


-- delete movies function

create or replace function delete_movie(
  p_mid uuid
)
returns jsonb
language plpgsql
security definer
as $$
begin
  -- Delete the movie, CASCADE will remove timeshows + reservations + tickets
  delete from movies where id = p_mid;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'movie_not_found');
  end if;

  return jsonb_build_object('ok', true, 'movie_id', p_mid);
end;
$$;


-- Drop all tables 

drop table tickets;
drop table reservations;
drop table timeshows;
drop table customers;
drop table movies;


