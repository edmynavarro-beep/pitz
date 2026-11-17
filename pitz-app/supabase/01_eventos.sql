-- Pitz · Supabase mínimo: guarda cada evento de la app y calcula indicadores.
-- Pegar completo en Supabase → SQL Editor → Run. Se puede ejecutar más de una vez.

create table if not exists public.eventos (
  id      uuid primary key default gen_random_uuid(),
  evento  text  not null check (char_length(evento) <= 60),
  datos   jsonb not null default '{}'::jsonb check (pg_column_size(datos) <= 4000),
  origen  text  check (char_length(origen) <= 120),
  creado  timestamptz not null default now()
);

-- Seguridad: la web (clave anon) SOLO puede insertar. Nadie puede leer, editar ni borrar desde internet.
alter table public.eventos enable row level security;
drop policy if exists "la app registra eventos" on public.eventos;
create policy "la app registra eventos" on public.eventos for insert to anon with check (true);
grant usage on schema public to anon;
grant insert on public.eventos to anon;

-- Indicadores de la demo (se ven en Table Editor → kpi_demo, o con: select * from kpi_demo;)
create or replace view public.kpi_demo with (security_invoker = true) as
select
  (select count(distinct datos->>'solicitud_id') from public.eventos where evento = 'solicitud_abierta')   as solicitudes_abiertas,
  (select count(distinct datos->>'orden_id')     from public.eventos where evento = 'oferta_aceptada')     as ofertas_aceptadas,
  (select count(distinct datos->>'orden_id')     from public.eventos where evento = 'orden_terminada')     as servicios_terminados,
  (select coalesce(sum(p), 0) from (select distinct on (datos->>'orden_id') (datos->>'precio_inicial')::numeric as p
     from public.eventos where evento = 'orden_terminada' order by datos->>'orden_id', creado) x)          as volumen_servicios_soles,
  (select coalesce(sum(m), 0) from (select distinct on (datos->>'orden_id') (datos->>'monto')::numeric as m
     from public.eventos where evento = 'comision_generada' order by datos->>'orden_id', creado) y)        as comision_pitz_soles,
  (select count(*) from public.eventos where evento = 'taller_registrado')                                  as talleres_registrados;

-- Para limpiar los datos de prueba antes de la exposición:  truncate public.eventos;
