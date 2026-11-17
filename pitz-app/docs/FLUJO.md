# Pitz · Flujo y lógica aplicada (v3)

## 1. Estados
- **Solicitud:** borrador (Pitzi ya diagnosticó) → abierta (15 min) → aceptada | vencida | cancelada
- **Oferta:** enviada → aceptada | rechazada (las demás al aceptar una) | retirada
- **Orden:** coordinando → en_camino → recibido (encuentro) → en_revision (servicio en curso) → terminado | cancelada

## 2. Flujo paso a paso (quién hace qué)
| # | Conductor | Mecánico | Qué hace el sistema |
|---|---|---|---|
| 1 | Describe la falla a Pitzi | — | Pitzi clasifica por reglas: causa, semáforo, ¿puede mover el auto?, rango de precio de la tabla (nunca inventa) |
| 2 | Toca **Pedir ofertas** | — | La solicitud queda abierta 15 min y se envía a talleres verificados y disponibles cuya zona incluye el distrito |
| 3 | — | Ve solo tipo de falla, auto y **distrito** (sin dirección ni teléfono) y toca **Hacer oferta** (precio + minutos) | Muestra en vivo el 5 % de comisión; avisa si supera el rango |
| 4 | Ve las ofertas (ordenables por precio, cercanía, calificación). El orden jamás depende de la comisión | — | — |
| 5 | Toca **Aceptar** (1 toque, sin confirmación) | Recibe “¡Te aceptaron!” | Rechaza las otras ofertas; crea la orden. Modalidad automática: si el auto NO se puede mover y el taller atiende a domicilio → **domicilio**; si no → **taller**. Recién ahora se ven dirección y teléfono |
| 6a | (Taller) Va al taller: el mapa arranca solo | Ve al cliente en camino | Pide ubicación nativa del navegador (opcional) |
| 6b | (Domicilio) Espera | Toca **Salí hacia el cliente** | Arranca el recorrido en el mapa con tiempo estimado |
| 7 | (Taller) toca **Ya llegué** | (Domicilio) toca **Ya llegué** | Orden pasa a “encuentro” |
| 8 | Toca **Sí, ya estamos juntos** (1 toque en la ventana) | Toca **Ya me encontré con el cliente** | Se abre “Servicio en curso” |
| 9 | Ve la recepción (sin aprobar nada) | Registra 4 fotos, km, combustible y daños previos | Queda como constancia. La orden pasa directo a revisión |
| 10 | — | Diagnóstico (fotos), desglose repuesto + mano de obra = precio inicial | Debe sumar exactamente el precio inicial |
| 11 | Si hay ajuste: **Aceptar/Rechazar** (1 toque en una hoja) | Registra ajuste con motivo, monto y **foto obligatoria** | Sin aprobación el mecánico no puede terminar. Los ajustes **no suman a la comisión** |
| 12 | Recibe “¡Servicio terminado! Este fue el precio total… gracias” | Toca **Terminar servicio** | Se genera la comisión: 5 % del **precio inicial** (primera orden de cada mecánico: S/ 0) |
| 13 | Una sola pantalla: monto que pagó, cómo (Efectivo/Yape/Plin) y estrellas | Ve “Tu servicio total fue S/ X” + **deuda pendiente** del 5 % con vence en 48 h + botón Pagar | Si el monto declarado ≠ total → “en revisión” |
| 14 | Garantía 7 días: “Reportar un problema” | Paga comisión por Yape/Plin con captura | El equipo valida la captura (en la demo se valida sola a los 6 s) |

## 3. Reglas de negocio
- **Pago del servicio:** conductor ↔ mecánico directo. Pitz no custodia dinero.
- **Comisión:** 5 % del precio inicial aprobado; pago en 48 h. Día 1 aviso, día 2 aviso, día 3 cuenta en pausa (no ve solicitudes nuevas hasta pagar).
- **Cancelación con penalización:** solo si es a domicilio, el mecánico ya salió, se movió y pasaron **más de 5 min**. El conductor paga 10 % del precio; Pitz compensa de inmediato al mecánico y se lo cobra al conductor, que no puede pedir ofertas hasta pagar. Antes de 5 min es gratis.
- **Retención:** sin dirección ni teléfono hasta aceptar; chat dentro de la app que detecta números; garantía de 7 días.
- **Pitzi nunca recomienda un taller.**

## 4. Por qué el mecánico puede no ver clientes
1. El conductor está en **otro navegador o dispositivo** (en esta versión los datos viven en el navegador). Prueba en dos pestañas del mismo navegador, con http/https.
2. El conductor pidió ofertas en un **distrito que el mecánico no atiende** (se ven solo las zonas de su ficha).
3. El conductor **no tocó “Pedir ofertas”** (queda en borrador) o la búsqueda **venció** (15 min).
4. El mecánico ya ofertó a esa solicitud, está bloqueado por comisión vencida, o su taller aún no está verificado.

**Solución para probar solo:** en la pestaña de solicitudes del mecánico pulsa **Simular un cliente cercano** (o ⚙ Demo). El cliente simulado acepta tu oferta a los ~5 s, confirma el encuentro, acepta ajustes, paga y deja 5 estrellas.
