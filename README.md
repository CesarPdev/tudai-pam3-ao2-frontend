# Agenda 2.0 - Cliente Móvil (AO2 - PAM III)

Aplicación Flutter moderna para gestionar contactos. Refactorizada para consumir una Web API RESTful mediante peticiones HTTP, implementando autenticación JWT e inyección automática de tokens.

## 📌 Descripción

Esta aplicación representa el cliente frontend para la gestión de contactos. Evolucionando desde una persistencia local, esta versión se conecta a un backend en .NET 8 utilizando **Dio** para el manejo de red y un **Interceptor** para la gestión segura de sesiones con JSON Web Tokens (JWT). Conserva sus estilos globales y el soporte total para **tema oscuro**[cite: 21].

---

## 🚀 Funcionalidades

### 🔐 Autenticación Real con JWT
- Registro de nuevos usuarios.
- Login de usuarios validando contra la base de datos.
- Almacenamiento seguro del token JWT en `SharedPreferences`.
- Inyección automática del token en los encabezados HTTP (Bearer) mediante InterceptorsWrapper.

### 📇 Gestión de Contactos (CRUD)
- Listado completo obtenido desde el servidor.
- Crear nuevo contacto.
- Editar contacto con actualización optimista (Optimistic UI) para mayor fluidez.
- Eliminar contacto sincronizado con la base de datos real.

### 🔎 Búsqueda avanzada (en tiempo real)
Búsqueda reactiva en memoria por:
- Nombre
- Apellido
- Teléfono
- Email

### 🎨 UI/UX Consistente
- Diálogos personalizados y validaciones de formularios asíncronas.
- Indicadores de carga (`CircularProgressIndicator`) durante las peticiones de red.
- Manejo de errores de red traducidos a mensajes amigables para el usuario.

---

## 🛠️ Stack Tecnológico
- **Framework:** Flutter / Dart
- **Estado:** Provider
- **Cliente HTTP:** Dio
- **Almacenamiento Local:** Shared Preferences (para sesión JWT)

---

## 📁 Estructura del proyecto
```text
lib/
├─ app_theme.dart               # Tema global (colores, estilos)
├─ main.dart                    # Providers + AuthGate
├─ models/
│  └─ contact.dart              # Modelo serializable para JSON
├─ services/
│  └─ api_client.dart           # Instancia global de Dio + Interceptor JWT
├─ providers/
│  ├─ auth_provider.dart        # Gestión de sesión, login y registro
│  └─ contacts_provider.dart    # Peticiones CRUD al backend
├─ screens/
│  ├─ login_screen.dart         # Pantalla de acceso
│  ├─ register_screen.dart      # Pantalla de creación de cuenta
│  ├─ contacts_screen.dart      # Listado + búsqueda
│  ├─ contact_detail_screen.dart# Vista detallada
│  └─ contact_form_screen.dart  # Formulario alta/edición
└─ widgets/
   ├─ login_form.dart
   └─ register_form.dart
