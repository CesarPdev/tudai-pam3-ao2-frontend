import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contacts_provider.dart';
import '../providers/auth_provider.dart';
import 'contact_form_screen.dart';
import 'contact_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _searchMode = false;
  final _searchCtrl = TextEditingController();
  Future<void>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<ContactsProvider>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final provider = context.watch<ContactsProvider>();
        final query = _searchCtrl.text.trim();
        final contacts = query.isEmpty
            ? provider.items
            : provider.searchBy(query);

        return Scaffold(
          appBar: AppBar(
            title: _searchMode
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar...',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : const Text('Contactos'),
            leading: _searchMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchMode = false);
                    },
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _searchMode = true),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthProvider>().logout();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                ],
              ),
            ],
          ),
          body: contacts.isEmpty
              ? const Center(child: Text('No hay contactos aún'))
              : ListView.separated(
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = contacts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          c.iniciales,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text('${c.nombre} ${c.apellido}'),
                      subtitle: Text('${c.telefono} · ${c.email}'),
                      // ⬅️ AHORA SÍ NAVEGA AL DETALLE
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ContactDetailScreen(contactId: c.id),
                          ),
                        );
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactFormScreen()),
            ),
          ),
        );
      },
    );
  }
}
