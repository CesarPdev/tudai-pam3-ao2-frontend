class Contact {
  final int id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String domicilio;
  final DateTime? fechaNacimiento;

  const Contact({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    this.domicilio = '',
    this.fechaNacimiento,
  });

  // ─────────────────────────────────────────────
  // JSON ↔ Modelo
  // ─────────────────────────────────────────────

  /// Mapea la respuesta de GET /minimal/contactos o cualquier endpoint.
  /// Campos del backend: id (int), nombre, apellido, telefono, email.
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'] as String)
          : null,
      domicilio: json['domicilio'] as String? ?? '',
    );
  }

  /// Serializa para POST /api/contacto/add (sin id, lo genera el backend).
  Map<String, dynamic> toJsonCreate() => {
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'email': email,
        if (fechaNacimiento != null)
          "fechaNacimiento": fechaNacimiento!.toIso8601String(),
        if (domicilio.isNotEmpty) 'domicilio': domicilio,
      };

  /// Serializa para PUT /api/contacto/edit/{id} (incluye id).
  Map<String, dynamic> toJsonUpdate() => {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'email': email,
        if (fechaNacimiento != null)
          "fechaNacimiento": fechaNacimiento!.toIso8601String(),
        if (domicilio.isNotEmpty) 'domicilio': domicilio,
      };

  // ─────────────────────────────────────────────
  // Helpers de UI
  // ─────────────────────────────────────────────

  /// Retorna las iniciales del avatar cuando no hay imagen.
  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    return (n + a).toUpperCase();
  }

  Contact copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    String? domicilio,
    DateTime? fechaNacimiento,
  }) {
    return Contact(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      domicilio: domicilio ?? this.domicilio,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    );
  }
}