/* Configuración pública de Pitz. Si dejas esto vacío, la app funciona igual (solo en el navegador).
   Para activar Supabase: pega aquí la "Project URL" y la clave "anon / publishable" (Supabase → Project Settings → API).
   Estas dos claves SON públicas por diseño; la seguridad la dan las reglas RLS de supabase/01_eventos.sql.
   NUNCA pegues aquí la clave "service_role" / "secret". */
window.PITZ_CONFIG = {
  SUPABASE_URL: "",        // ej.: "https://abcdefghijk.supabase.co"
  SUPABASE_ANON_KEY: ""    // ej.: "eyJhbGciOi..." (anon) o "sb_publishable_..."
};
