import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../data/contacts_db.dart';

class ContactsProvider extends ChangeNotifier {
  final ContactsDb _db;
  ContactsProvider(this._db);

  bool _loaded = false;
  final List<Contact> _contacts = [];

  List<Contact> get items => List.unmodifiable(_contacts);

  Future<void> load() async {
    if (_loaded) return;
    await _db.open();
    _contacts
      ..clear()
      ..addAll(await _db.getAll());
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(Contact c) async {
    await _db.insert(c);
    _contacts.add(c);
    notifyListeners();
  }

  Future<void> update(Contact c) async {
    await _db.update(c);
    final index = _contacts.indexWhere((x) => x.id == c.id);
    if (index != -1) {
      _contacts[index] = c;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await _db.deleteById(id);
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<Contact> searchBy(String query) {
    final q = query.toLowerCase();

    return _contacts.where((c) {
      return normalize(c.nombre).contains(q) ||
          normalize(c.apellido).contains(q) ||
          normalize(c.telefono).contains(q) ||
          normalize(c.email).contains(q);
    }).toList();
  }
}
