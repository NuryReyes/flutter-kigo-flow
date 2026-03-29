# Kigo — Evaluación Técnica Flutter

Aplicación móvil construida a partir de diseños de Figma. Kigo es una aplicación de estacionamiento y movilidad.

---

## Pantallas a implementar

| Nombre de pantalla | Descripción |
|--------|--------|
| Splash | Fondo naranja, logos de Kigo + Parkimovil |
| Login | Ingreso de teléfono, toggle de política de privacidad |
| OTP | Ingreso de OTP de 5 dígitos, avance automático |
| Inicio QR | Cámara en vivo, tarjeta de saldo, botones de funciones |

---

## Funcionalidades

- **Flujo de autenticación por celular** — Ingreso de número → Verificación OTP → Inicio QR
- **Escáner QR** — Visor de cámara real mediante `mobile_scanner`, toggle de linterna
- **Tarjeta de saldo** — Tarjeta de estacionamiento activa con visualización de saldo
- **Selector de país** — Dropdown para cambiar país
- **Accesos rápidos** — Botones de acceso rápido a Parquímetro y Estatus
- **Navegación inferior de 5 pestañas** — Mapa, Control, QR, Servicios, Perfil
- **Manejo completo de estados de UI** — Estados de carga, éxito, vacío, error y reintento en toda la app
- **Capa de datos simulada** — Repositorios falsos intercambiables con un backend real mediante inyección de dependencias

---

## Stack Tecnológico

| Preocupación | Elección | Razón |
|---------|--------|--------|
| Gestión de estado | MobX | Reactivo, mínimo boilerplate, escala bien |
| Navegación | go_router | Declarativo, listo para deep links, shell routes para nav inferior |
| Inyección de dependencias | get_it | Service locator simple, fácil de intercambiar implementaciones |
| Arquitectura | Feature-first + Patrón Repository | Escala por funcionalidad, clara separación de responsabilidades |
| Cámara / QR | mobile_scanner | Mejor paquete QR de Flutter con mantenimiento activo, soporta iOS y Android |

---

## Estructura del Proyecto

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTextStyles, AppTheme
│   ├── router/         # Configuración go_router, ShellRoute, todas las rutas
│   └── di/             # Registros get_it (injection.dart)
├── features/
│   ├── auth/
│   │   ├── screens/    # splash_screen, login_screen, otp_screen
│   │   ├── stores/     # AuthStore (MobX), OtpStore (MobX)
│   │   └── repositories/ # AuthRepository (abstracto) + FakeAuthRepository
│   └── home/
│       ├── screens/    # qr_screen, stub_screen
│       ├── models/     # CardInfo
│       ├── stores/     # HomeStore (MobX)
│       └── repositories/ # HomeRepository (abstracto) + FakeHomeRepository
└── shared/
    └── widgets/        # Componentes reutilizables compartidos
```

---

## Primeros Pasos

### Prerrequisitos

- Flutter 3.29.x stable ([instalar desde flutter.dev](https://flutter.dev/docs/get-started/install))
- Xcode 15+ con Command Line Tools (para builds de iOS)
- CocoaPods (`sudo gem install cocoapods`)
- Un simulador de iOS o emulador de Android

### Clonar y Ejecutar

```bash
# 1. Clonar el repositorio
git clone https://github.com/NuryReyes/flutter-kigo-flow.git
cd flutter-kigo-flow

# 2. Instalar dependencias
flutter pub get

# 3. Generar código MobX (requerido antes de la primera ejecución)
dart run build_runner build --delete-conflicting-outputs

# 4. Instalar pods de iOS
cd ios && pod install && cd ..

# 5. Ejecutar en simulador
flutter run
```

> **Nota sobre la cámara:** El visor de cámara QR en vivo requiere un dispositivo físico. En el simulador de iOS, el área de la cámara aparecerá en blanco — este es el comportamiento esperado de `mobile_scanner`.

---

## Ejecutar Pruebas

**Nota:** Las pruebas no están incluidas debido a limitaciones de tiempo

```bash
flutter test
```

---

## Construir APK de Release (Android)

```bash
flutter build apk --release
```

El APK resultante estará en `build/app/outputs/flutter-apk/app-release.apk`.

> **Requiere configuración de Android:** Asegúrate de tener Android Studio y un Android SDK instalados, o configura `ANDROID_HOME` con la ruta a tu SDK.

---

## Capa de Datos Simulada

Todos los datos son servidos por implementaciones de repositorios "fake" registrados en `core/di/injection.dart`. Para intercambiar con un backend real:

1. Crea una nueva implementación del repositorio abstracto correspondiente (p. ej. `RealAuthRepository implements AuthRepository`)
2. En `injection.dart`, reemplaza el registro de `FakeAuthRepository` con tu nueva clase
3. No se requieren más cambios — los stores y pantallas están desacoplados de la fuente de datos

```dart
// injection.dart — reemplaza esta línea:
getIt.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
// con:
getIt.registerLazySingleton<AuthRepository>(() => RealAuthRepository());
```

---

## Flujo de Navegación

```
/splash  →  /login  →  /otp  →  /home/qr
                                    ├── /home/mapa
                                    ├── /home/control
                                    ├── /home/servicios
                                    └── /home/perfil
```

El estado se pasa entre pantallas mediante el parámetro `extra` de `go_router` (p. ej. número de teléfono de login → pantalla OTP).

---

## Limitaciones Conocidas

- La vista previa de cámara no fue probada, solo se utilizó el simulador de iOS. No se tomó en cuenta nada referente a lectura de QRs después de ser capturados por la cámara.
- Las pantallas stub (Mapa, Control, Servicios, Perfil) son placeholders, cada una de estas pantallas debería manejarse como una feature separada.
- La verificación OTP acepta cualquier código y navega al usuario a la siguiente pantalla. Una implementación real de OTP podría ser más compleja de lo que se proporcionó, dependiendo del servicio utilizado y si parte del requerimiento era autocompletar el código desde el SMS recibido.
- Muchos botones en la pantalla QR (y del proceso de reqistro) no son funcionales ya que estaba fuera del alcance del proyecto, entre ellos la linterna y el selector de país.

---

## Contexto de la Evaluación

Este proyecto fue construido como la Parte 1 de una evaluación técnica de Flutter. Demuestra:

- Arquitectura feature-first con clara separación de responsabilidades
- Gestión de estado reactiva con observables, acciones y valores computados de MobX
- Patrón Repository que habilita una capa de datos completamente intercambiable
- Navegación declarativa con shell routes de go_router
- Manejo de todos los estados principales de UI: carga, éxito, vacío, error y reintento
- Implementación fiel a los diseños de Figma proporcionados, debido a limitaciones de tiempo algunas pantallas requieren trabajo adicional en detalles de UI

---

## Autora

Nuria Reyes