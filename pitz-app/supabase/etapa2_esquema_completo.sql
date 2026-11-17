-- Pitz · esquema para Supabase (Etapa 2, opcional). Ejecutar en SQL Editor.
create extension if not exists "pgcrypto";
create type rol as enum ('conductor','mecanico','admin');
create table perfiles(id uuid primary key references auth.users on delete cascade, rol rol not null, nombre text not null, celular text, distrito text, veh jsonb, bloqueado boolean default false, creado timestamptz default now());
create table talleres(id uuid primary key default gen_random_uuid(), owner_id uuid references perfiles(id), nombre text not null, distrito text, direccion text, lat float8, lng float8, zonas text[], esp text[], anios int, escaner bool, noche bool, domingo bool, domicilio bool, disponible bool default true, verificado bool default false, primera_usada bool default false, fotos text[]);
create table solicitudes(id uuid primary key default gen_random_uuid(), conductor_id uuid references perfiles(id), tipo text, causa text, grav text, texto text, distrito text, puede bool, min int, max int, foto text, estado text default 'abierta', vence timestamptz, creada timestamptz default now());
create table ofertas(id uuid primary key default gen_random_uuid(), sol_id uuid references solicitudes(id) on delete cascade, taller_id uuid references talleres(id), precio int not null, llegada int, msg text, estado text default 'enviada', creada timestamptz default now(), unique(sol_id,taller_id));
create table ordenes(id uuid primary key default gen_random_uuid(), sol_id uuid references solicitudes(id), oferta_id uuid references ofertas(id), conductor_id uuid references perfiles(id), taller_id uuid references talleres(id), precio int not null, modalidad text, estado text default 'coordinando', confirm_c bool default false, ruta jsonb, recepcion jsonb, desglose jsonb, pago jsonb, pago_en_revision bool default false, salida timestamptz, cancelada_en timestamptz, cancelada_por text, terminada_en timestamptz, creada timestamptz default now());
create table mensajes(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id) on delete cascade, de uuid, texto text, creada timestamptz default now());
create table ajustes(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id) on delete cascade, motivo text, monto int, foto text, modo text, estado text default 'pendiente', creada timestamptz default now(), decidido timestamptz);
create table evidencias(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id) on delete cascade, ajuste_id uuid, tipo text, url text, etapa text, creada timestamptz default now());
create table resenas(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id), taller_id uuid references talleres(id), conductor_id uuid references perfiles(id), cal int check (cal between 1 and 5), txt text, creada timestamptz default now());
create table ubicaciones(orden_id uuid primary key references ordenes(id) on delete cascade, lat float8, lng float8, actualizada timestamptz default now());
create table comisiones(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id), taller_id uuid references talleres(id), monto numeric(8,2), sin bool default false, estado text default 'pendiente', nivel int default 0, comprobante text, generada timestamptz default now(), vence timestamptz);
create table penalizaciones(id uuid primary key default gen_random_uuid(), orden_id uuid references ordenes(id), conductor_id uuid references perfiles(id), taller_id uuid references talleres(id), pct int default 10, monto numeric(8,2), estado text default 'pendiente', comp text default 'pagada_por_pitz', comprobante text, creada timestamptz default now());
create table precios(id serial primary key, tipo text, min int, max int);
-- RLS (mínimo): cada quien ve lo suyo. Los datos de contacto solo existen tras aceptar (tabla ordenes).
alter table perfiles enable row level security; alter table talleres enable row level security; alter table solicitudes enable row level security; alter table ofertas enable row level security; alter table ordenes enable row level security; alter table mensajes enable row level security; alter table ajustes enable row level security; alter table evidencias enable row level security; alter table resenas enable row level security; alter table ubicaciones enable row level security; alter table comisiones enable row level security; alter table penalizaciones enable row level security;
create policy "perfil propio" on perfiles for all using (id = auth.uid());
create policy "talleres visibles" on talleres for select using (verificado);
create policy "taller propio" on talleres for all using (owner_id = auth.uid());
create policy "mis solicitudes" on solicitudes for all using (conductor_id = auth.uid());
create policy "talleres ven abiertas" on solicitudes for select using (estado='abierta' and exists(select 1 from talleres t where t.owner_id=auth.uid() and t.verificado));
create policy "ofertas del taller" on ofertas for all using (exists(select 1 from talleres t where t.id=taller_id and t.owner_id=auth.uid()));
create policy "ofertas de mi solicitud" on ofertas for select using (exists(select 1 from solicitudes s where s.id=sol_id and s.conductor_id=auth.uid()));
create policy "mis ordenes" on ordenes for all using (conductor_id=auth.uid() or exists(select 1 from talleres t where t.id=taller_id and t.owner_id=auth.uid()));
create policy "chat de mi orden" on mensajes for all using (exists(select 1 from ordenes o where o.id=orden_id and (o.conductor_id=auth.uid() or exists(select 1 from talleres t where t.id=o.taller_id and t.owner_id=auth.uid()))));
create policy "ajustes de mi orden" on ajustes for all using (exists(select 1 from ordenes o where o.id=orden_id and (o.conductor_id=auth.uid() or exists(select 1 from talleres t where t.id=o.taller_id and t.owner_id=auth.uid()))));
create policy "evidencias de mi orden" on evidencias for all using (exists(select 1 from ordenes o where o.id=orden_id and (o.conductor_id=auth.uid() or exists(select 1 from talleres t where t.id=o.taller_id and t.owner_id=auth.uid()))));
create policy "reseñas públicas" on resenas for select using (true);
create policy "reseña propia" on resenas for insert with check (conductor_id=auth.uid());
create policy "ubicación de mi orden" on ubicaciones for all using (exists(select 1 from ordenes o where o.id=orden_id and (o.conductor_id=auth.uid() or exists(select 1 from talleres t where t.id=o.taller_id and t.owner_id=auth.uid()))));
create policy "mis comisiones" on comisiones for select using (exists(select 1 from talleres t where t.id=taller_id and t.owner_id=auth.uid()));
create policy "mis penalizaciones" on penalizaciones for select using (conductor_id=auth.uid());
-- Realtime: alter publication supabase_realtime add table ofertas, ordenes, mensajes, ajustes, ubicaciones;
-- Comisiones (avisos día 1, 2 y bloqueo día 3): pg_cron o Edge Function programada cada hora.
