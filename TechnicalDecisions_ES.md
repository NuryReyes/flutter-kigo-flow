
# Kigo Flutter — Decisiones Técnicas

Este documento explica las decisiones arquitectónicas y técnicas tomadas durante esta evaluación, los trade-offs considerados y lo que cambiaría en un contexto de producción.

---

## Arquitectura: Feature-First + Patrón Repository

### Decisión
El proyecto está organizado por funcionalidad (`auth/`, `home/`) en lugar de por capa (`screens/`, `stores/`, `models/`). Cada feature posee sus propias pantallas, stores de estado, modelos y repositorio.

### Por qué
- **Escalabilidad:** Agregar una nueva funcionalidad significa agregar una nueva carpeta, no dispersar archivos a través de múltiples directorios de nivel superior
- **Amigable para equipos:** Múltiples desarrolladores pueden trabajar en diferentes features con conflictos de merge mínimos
- **Responsabilidad clara:** Todo el código relacionado con autenticación vive en `features/auth/`, lo que significa que es fácil de encontrar, fácil de eliminar o refactorizar de forma aislada

### Trade-offs
- Para apps muy pequeñas, la organización por capas puede sentirse más simple inicialmente. Feature-first genera beneficios una vez que tienes 4+ funcionalidades
- Requiere disciplina para mantener las utilidades compartidas en `core/` o `shared/` en lugar de filtrarlas hacia las carpetas de features

---

## Gestión de Estado: MobX

### Decisión
MobX con `flutter_mobx` y generación de código mediante `mobx_codegen`.

### Por qué
- **Reactivo y minimal:** Los observables, acciones y valores computados se mapean naturalmente al estado de UI (p. ej. `canSubmit` computado a partir de `phoneNumber` + `privacyAccepted`)
- **Separación de responsabilidades:** Los stores contienen toda la lógica de negocio; los widgets son puramente declarativos mediante `Observer`
- **Predecible:** Todas las mutaciones de estado deben estar envueltas en `@action`, haciendo el flujo de datos fácil de rastrear y depurar
- **Buena experiencia de desarrollo:** La generación de código con `build_runner` elimina el boilerplate de implementar `Store` manualmente

### Alternativas consideradas
- **Riverpod:** Excelente paquete, pero agrega más conceptos (providers, ref, notifiers) con una curva de aprendizaje inicial más pronunciada. Mejor opción para proyectos que ya lo utilizan
- **BLoC:** Muy explícito y testeable, pero alto boilerplate para un proyecto de evaluación. Mejor para equipos que necesitan disciplina estricta orientada a eventos
- **setState/ValueNotifier:** Adecuado para estado local, pero no escala bien entre pantallas ni maneja estado asíncrono de forma limpia

### Qué cambiaría para producción
- Agregar pruebas unitarias para cada `Store` — los stores son clases Dart puras sin dependencia de Flutter, lo que los hace trivialmente testeables
- Considerar dividir stores grandes en stores más pequeños y enfocados a medida que crecen las funcionalidades
- Evaluar si algunos stores deberían estar scoped a una ruta en lugar de registrados globalmente mediante get_it

---

## Navegación: go_router

### Decisión
`go_router` con un `ShellRoute` envolviendo la navegación inferior de 5 pestañas.

### Por qué
- **Declarativo:** Las definiciones de rutas son una única fuente de verdad, no dispersadas en llamadas `Navigator.push`
- **Listo para deep links:** go_router maneja deep links y navegación basada en URL de forma nativa. Esencial para una app de movilidad/estacionamiento que puede necesitar abrir directamente a un escaneo QR o a una sesión de estacionamiento específica
- **ShellRoute:** Permite navegación inferior persistente entre cambios de pestañas sin reconstruir el widget shell en cada navegación
- **Extras tipados:** Pasar el número de teléfono de Login → OTP mediante `extra` mantiene las pantallas desacopladas mientras comparten estado

### Qué cambiaría para producción
- Agregar clases de rutas tipadas (el `TypedGoRoute` de go_router) para parámetros de navegación completamente type-safe
- Implementar guards de rutas para rutas autenticadas y redirigir a `/login` si no existe una sesión válida
- Agregar animaciones de transición según el spec de diseño

---

## Inyección de Dependencias: get_it

### Decisión
`get_it` como service locator, con todos los registros centralizados en `core/di/injection.dart`.

### Por qué
- **Simple y pragmático:** No requiere generación de código y es fácil de entender
- **Implementaciones intercambiables:** Registrar contra interfaces abstractas (p. ej. `AuthRepository`) significa que cualquier implementación concreta puede intercambiarse en una línea — este es el habilitador clave de la capa de datos simulada
- **Lazy singletons:** Los stores y repositorios solo se instancian cuando se accede a ellos por primera vez, manteniendo bajo el tiempo de inicio

### Trade-offs
- get_it es un service locator, no inyección de dependencias verdadera. Las dependencias se extraen en lugar de inyectarse. Esto puede hacer las pruebas unitarias ligeramente más difíciles que la inyección por constructor
- Sin seguridad en tiempo de compilación: los registros incorrectos fallan en runtime, no en build time. `injectable` (un wrapper de generación de código sobre get_it) resuelve esto pero agrega complejidad

### Qué cambiaría para producción
- Considerar `injectable` para DI verificada en tiempo de compilación
- Agregar registro basado en entorno (p. ej. `registerIf(env == 'dev', () => FakeAuthRepository())`) para usar automáticamente fakes en desarrollo e implementaciones reales en producción

---

## Capa de Datos Simulada: Patrón Repository

### Decisión
Interfaces abstractas de repositorio con implementaciones falsas. Todos los stores dependen de la interfaz abstracta; las implementaciones concretas se inyectan mediante get_it.

### Por qué
- **Testeabilidad:** Cualquier pantalla o store puede probarse con un repositorio falso que devuelve datos predecibles
- **Desarrollo independiente del backend:** Toda la UI puede construirse y demostrarse sin una API real
- **Costo de migración mínimo:** Cuando el backend real esté listo, solo cambia la implementación concreta del repositorio — los stores, pantallas y pruebas no se modifican

### Estructura
```
AuthRepository (abstracto)
  └── FakeAuthRepository   ← usado ahora
  └── RealAuthRepository   ← agregar cuando el backend esté listo

HomeRepository (abstracto)
  └── FakeHomeRepository   ← usado ahora
  └── RealHomeRepository   ← agregar cuando el backend esté listo
```

---

## Cámara / QR: mobile_scanner

### Decisión
`mobile_scanner ^6.0.0` para el visor de cámara en vivo y el escaneo de códigos QR.

### Por qué
- Mejor paquete de escaneo QR para Flutter con mantenimiento activo
- Soporta iOS y Android con una API consistente
- Maneja permisos de cámara, gestión del ciclo de vida y control de linterna
- Desarrollo activo y responsivo a las actualizaciones del SDK de Flutter

### Limitación conocida
- La vista previa de cámara no se renderiza en el Simulador de iOS — esta es una limitación de hardware del simulador, no un problema de código. Toda la funcionalidad de escaneo QR debería funcionar correctamente en un dispositivo físico. Pero se necesitaría más pruebas con un dispositivo físico para asegurarse.

---

## Qué Cambiaría para Producción

| Área | Actual (Evaluación) | Producción |
|------|---------------------|------------|
| Autenticación | Se acepta cualquier código | Implementación OTP real (p. ej. Twilio, Firebase Auth) |
| Datos | Repositorios falsos | Clientes REST/GraphQL reales con manejo de errores, caché, reintento |
| Seguridad | Ninguna | Almacenamiento seguro de tokens (`flutter_secure_storage`), certificate pinning |
| Manejo de errores | Estados básicos de UI | Manejo centralizado de errores, reporte de crashes (Sentry / Firebase Crashlytics) |
| Analytics | Ninguno | Seguimiento de eventos (Amplitude, Firebase Analytics) |
| Pruebas | Ninguna | Pruebas unitarias para todos los stores, pruebas de widget para flujos clave, pruebas de integración |
| CI/CD | Ninguno | GitHub Actions: lint → test → build → distribuir (Firebase App Distribution) |
| Localización | Strings en español hardcodeados | `flutter_localizations` + archivos ARB |
| Accesibilidad | No abordada | Labels semánticos, targets de toque mínimos, ratios de contraste |
| Rendimiento | No optimizado | Caché de imágenes, lazy loading, widgets `const` en toda la app |

---

## Justificación de la Estructura de Carpetas

```
lib/
├── core/         # Infraestructura de la app: tema, router, DI
├── features/     # Una carpeta por funcionalidad del producto
└── shared/       # Widgets reutilizables no pertenecientes a ninguna feature
```

`core/` es para las cosas que configuran y conectan la app. `features/` es donde vive el trabajo del producto. `shared/` es para componentes de UI que múltiples features utilizan (botones, campos de texto, tarjetas). Esta separación previene el antipatrón común de una carpeta `widgets/` única y sobrecargada que se convierte en un vertedero.