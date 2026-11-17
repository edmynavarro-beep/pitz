# Pitz · tu pit stop de confianza

App web (MVP funcional) que conecta conductores de Lima con mecánicos verificados. Es un solo archivo, `index.html`, sin instalar nada. Lo que hace y su lógica completa están en [`docs/FLUJO.md`](docs/FLUJO.md).

## Qué hay en esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La app completa (conductor + mecánico) |
| `config.js` | Aquí se pegan los 2 datos de Supabase (opcional) |
| `supabase/01_eventos.sql` | Crea la tabla `eventos` y los indicadores. Se pega una vez en Supabase |
| `supabase/etapa2_esquema_completo.sql` | Modelo completo para una versión futura con usuarios reales (no hace falta ahora) |
| `docs/FLUJO.md` | Estados, flujo paso a paso y reglas de negocio |
| `.nojekyll` | Evita que GitHub Pages procese los archivos |

## 1. Publicar la app (GitHub Pages, gratis, ~5 minutos)

1. En github.com: **New repository** → nombre `pitz` → **Public** → Create.
2. **Add file → Upload files** → arrastra **el contenido** de esta carpeta (`index.html`, `config.js`, `docs`, `supabase`, `README.md`, `.nojekyll`) → **Commit changes**.
3. **Settings → Pages** → *Build and deployment* → Source: **Deploy from a branch** → Branch: `main` / `/(root)` → **Save**.
4. En 1–2 minutos aparece el link: `https://TU-USUARIO.github.io/pitz/`. Ese es el link de tu app.

Cada vez que subas un archivo nuevo al repositorio, la página se actualiza sola.

Alternativas igual de simples: **Vercel** o **Netlify** → *Import* el repositorio → Framework: *Other*, sin comando de build, carpeta de salida: la raíz.

## 2. Conectarlo con el landing de Lovable

Lovable crea sus propios repositorios y **no puede importar uno que ya existe** (su sincronización con GitHub siempre crea un repositorio nuevo). Por eso la forma correcta de conectarlos es por enlace:

1. En el landing de Lovable agrega un botón **"Probar la app"** que apunte al link del paso 1 (`https://TU-USUARIO.github.io/pitz/`).
2. Publica el landing en Lovable como siempre (**Publish**).

Así el landing queda en Lovable y la app funcional en GitHub, y se ven como un solo producto. Para presentar dos roles a la vez, usa estos enlaces:
`…/pitz/#as=conductor` y `…/pitz/#as=mecanico`.

## 3. Activar Supabase (para que los datos queden en una base real)

Qué hace: cada evento importante de la app (taller registrado, solicitud abierta, oferta aceptada, servicio terminado, comisión del 5 %, penalización, pago en revisión, reclamo) se guarda en la tabla `eventos` de Supabase. Sirve para mostrar datos reales y el ingreso de Pitz calculado en vivo.

1. Entra a supabase.com → **New project** (plan gratis). Anota la contraseña de la base de datos.
2. **SQL Editor → New query** → pega todo `supabase/01_eventos.sql` → **Run**.
3. **Project Settings → API**: copia **Project URL** y la clave **anon / publishable**.
4. Abre `config.js` en GitHub (lápiz ✏️), pega los dos datos entre las comillas y **Commit changes**.
5. Abre la app → **⚙ Demo → n8n → Probar** (o haz una solicitud). En Supabase → **Table Editor → eventos** verás la fila nueva.
6. En **Table Editor → kpi_demo** ves los indicadores: solicitudes, ofertas aceptadas, servicios terminados, volumen de servicios y comisión de Pitz (5 %).

**Seguridad:** la clave `anon` es pública por diseño. Las reglas del SQL dejan que la web solo **inserte** eventos; desde internet nadie puede leer, editar ni borrar. Nunca pegues la clave `service_role`/`secret` en `config.js`.

Antes de exponer, borra los datos de prueba: SQL Editor → `truncate public.eventos;`

## Límites (para decirlos con honestidad)

- Las cuentas y el flujo de cada usuario siguen viviendo en el navegador de su dispositivo; Supabase registra los eventos, no reemplaza todavía a esa base. Dos celulares distintos aún no se ven entre sí. El modelo completo para eso está listo en `supabase/etapa2_esquema_completo.sql`.
- Pitzi usa reglas de negocio y una tabla de precios, no IA generativa. El mapa usa OpenStreetMap (necesita internet).
- Yape/Plin y el QR son de ejemplo; el pago real de la comisión lo valida el equipo.
- Claves demo: `luis@demo.pe` / `julio@demo.pe` / `carlos@demo.pe`, contraseña `demo1234`.
