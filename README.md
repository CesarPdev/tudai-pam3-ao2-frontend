# agenda 2.0

Aplicación Flutter moderna para gestionar contactos, con Provider para manejo de estado y SQLite para persistencia real.

## 📌 Descripción

**agenda_2.0** es una app completa de gestión de contactos. Incluye autenticación de demostración, listado con búsqueda avanzada, vista de detalle, creación, edición y eliminación de contactos.  
Utiliza **Provider**, **SQLite (sqflite)**, estilos globales y soporte total para **tema oscuro**.

---

## 🚀 Funcionalidades

### 🔐 Login de demostración
- Usuario: `admin@mail.com`
- Contraseña: `123456`

### 📇 Contactos
- Crear contacto
- Editar contacto (detalle reactivo, siempre actualizado)
- Eliminar contacto con diálogo personalizado
- Avatar generado con iniciales
- Persistencia local con SQLite

### 🔎 Búsqueda avanzada (en tiempo real)
Podés buscar por:
- Nombre  
- Apellido  
- Teléfono  
- Email  

### 🗑️ Diálogo de eliminación personalizado
- Botón **Eliminar** usando el color primario del tema
- Botón **Cancelar** estilo oscuro
- Ambos botones full-width y alineados verticalmente

### 🎨 Tema y estilos globales
- AppBar estilizado
- Botones con tema global
- Inputs unificados
- Colores consistentes según AppTheme

### 🧩 Arquitectura basada en Provider
- `AuthProvider` para login
- `ContactsProvider` para CRUD, búsqueda y carga desde SQLite
- Detalle del contacto basado en ID para obtener siempre datos actualizados

---

## 📁 Estructura del proyecto
```

lib/
├─ app_theme.dart # Tema global (colores, estilos)
├─ main.dart # Providers + AuthGate
├─ models/
│ └─ contact.dart # Modelo Contact
├─ data/
│ └─ contacts_db.dart # CRUD SQLite
├─ providers/
│ ├─ auth_provider.dart # Autenticación fake
│ └─ contacts_provider.dart # Manejo de contactos + búsqueda
├─ screens/
│ ├─ login_screen.dart
│ ├─ contacts_screen.dart # Lista + búsqueda + navegación
│ ├─ contact_detail_screen.dart # Vista detallada reactiva
│ └─ contact_form_screen.dart # Alta / edición con validaciones
└─ widgets/
│ └─ login_form.dart # Formulario
└─ login_form.dart
```
---

## ▶️ Primeros pasos

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar en dispositivo o emulador:
```bash
flutter run
```
