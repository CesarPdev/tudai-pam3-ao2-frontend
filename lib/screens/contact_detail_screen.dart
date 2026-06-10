import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contacts_provider.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  // id ahora es int, igual que Contact.id del backend.
  final int contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  Widget build(BuildContext context) {
    // Puede ser null si el contacto fue eliminado mientras se navegaba.
    final provider = context.watch<ContactsProvider>();
    final contact = provider.items.cast<dynamic>().firstWhere(
          (c) => c.id == contactId,
          orElse: () => null,
        );

    if (contact == null) {
      // El contacto ya no existe en la lista (fue eliminado externamente).
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Contacto no encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.nombre} ${contact.apellido}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactFormScreen(edit: contact),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
            onPressed: () => _confirmDelete(context, contact.id),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      contact.iniciales,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoRow(Icons.phone, 'Teléfono', contact.telefono),
                  const SizedBox(height: 8),
                  _infoRow(Icons.email, 'Email', contact.email),
                  if (contact.domicilio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.location_on, 'Dirección', contact.domicilio),
                  ],
                  if (contact.fechaNacimiento != null) ...[
                    const SizedBox(height: 8),
                    _infoRow(
                      Icons.cake,
                      'Fecha de nacimiento',
                      '${contact.fechaNacimiento!.day}/'
                          '${contact.fechaNacimiento!.month}/'
                          '${contact.fechaNacimiento!.year}',
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: theme.dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Eliminar contacto',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Confirmás la eliminación?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final provider = context.read<ContactsProvider>();
                    final ok = await provider.deleteContact(id);
                    if (!context.mounted) return;
                    Navigator.pop(context); // cierra el diálogo
                    if (ok) {
                      Navigator.pop(context); // vuelve a la lista
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ?? 'No se pudo eliminar.',
                          ),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
