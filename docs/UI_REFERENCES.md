# Referencias visuales de 2.2.56

Implementación nativa en Flutter, manteniendo teclado, mando de Android TV, ratón y táctil. No se han instalado dependencias React ni ejecutado generadores shadcn sobre este proyecto. Las referencias de 21st.dev sirven de guía visual; su código completo requiere acceso a la cuenta del sitio y no se ha copiado.

- [Apple Liquid Glass Switcher — dennysdionigi](https://21st.dev/@dennysdionigi/components/apple-liquid-glass-switcher): cápsula, lente desplazable, arrastre y reflejos. `LiquidSwitcher` usa un filtro de fondo real, selección animada y foco accesible; se reutiliza en navegación y tipo de fuente.
- [Finance Bento — romanvasnev](https://21st.dev/@romanvasnev/components/finance-bento): tarjetas estáticas translúcidas, borde fino y esquinas continuas. Las rejillas conservan construcción diferida, sin un filtro de desenfoque independiente por canal.
- [Interactive Bento Gallery — anurag-mishra22](https://21st.dev/@anurag-mishra22/components/interactive-bento-gallery): composición asimétrica adaptable, fotografías y respuesta al foco/ratón. La interacción se adapta a elegir liga, canal y calidad; no se usa arrastre para no interferir con el mando y el desplazamiento táctil.
- [iOS Spinner — yadwinder](https://21st.dev/@yadwinder/components/ios-spinner): indicador circular de radios, implementado con `CupertinoActivityIndicator`, respetando movimiento reducido.

## Imágenes incluidas

- Fondo genérico de fútbol: [Unsplash, photo-1522778119026-d647f0596c20](https://images.unsplash.com/photo-1522778119026-d647f0596c20). No representa un estadio o evento oficial de ninguna liga.
- Fondo genérico de baloncesto: [Unsplash, photo-1504450758481-7338eba7524a](https://images.unsplash.com/photo-1504450758481-7338eba7524a).
- Logotipo LALIGA blanco: [sala de prensa oficial](https://www.laliga.com/en-BR/pressroom/logos-and-corporate-dossier/logos), [PNG original](https://assets.laliga.com/assets/logos/LALIGA_RGB_h_monocromatico_negativo/LALIGA_RGB_h_monocromatico_negativo.png). Identifica la competición; no implica afiliación. Las demás competiciones usan su nombre como rótulo.

Las imágenes están empaquetadas para evitar descargas de fondos durante la navegación. Los canales y sus variantes se obtienen exclusivamente de la fuente configurada por el usuario; no se inventa programación, valoración ni disponibilidad.

## Comprobaciones

`test/league_favorites_test.dart` verifica agrupación y calidad, separación por perfil, persistencia, reproducción guardada y cambio con pulsación larga y mando. `tool/glass_preview_test.dart --update-goldens` permite generar capturas locales de canales, diálogos y galería en `build/qa/`.
