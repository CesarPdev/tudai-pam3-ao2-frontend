import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../providers/contacts_provider.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? edit;

  const ContactFormScreen({super.key, this.edit});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dirCtrl = TextEditingController();
  
  String? _selectedGender; // Estado para el DropdownButton
  DateTime? _fechaNac;

  @override
  void initState() {
    super.initState();

    final c = widget.edit;
    if (c != null) {
      _nombreCtrl.text = c.nombre;
      _apellidoCtrl.text = c.apellido;
      _telCtrl.text = c.telefono;
      _emailCtrl.text = c.email;
      _dirCtrl.text = c.domicilio;
      _fechaNac = c.fechaNacimiento;
      
      // Validamos que el género previo sea una de las opciones válidas
      if (['M', 'F', 'X'].contains(c.genero)) {
        _selectedGender = c.genero;
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _dirCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v, String campo) =>
      (v == null || v.trim().isEmpty) ? 'Ingrese $campo' : null;

  String? _validEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingrese el email';
    if (!v.contains('@') || !v.contains('.')) return 'Email inválido';
    return null;
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNac ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _fechaNac = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ContactsProvider>();
    bool ok;

    if (widget.edit == null) {
      // ── CREAR: id=0 como placeholder; el backend asigna el ID real. ──
      final contact = Contact(
        id: 0,
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        domicilio: _dirCtrl.text.trim(),
        fechaNacimiento: _fechaNac,
        genero: _selectedGender ?? '', // Agregado al crear
      );
      ok = await provider.addContact(contact);
    } else {
      // ── EDITAR ──
      final updated = widget.edit!.copyWith(
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        domicilio: _dirCtrl.text.trim(),
        fechaNacimiento: _fechaNac,
        genero: _selectedGender ?? '', // Usa el valor del dropdown
      );
      ok = await provider.updateContact(updated);
    }

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Error al guardar. Intente nuevamente.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ContactsProvider>().isLoading;
    final f = _fechaNac == null
        ? 'Sin definir'
        : DateFormat('dd/MM/yyyy').format(_fechaNac!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit == null ? 'Nuevo contacto' : 'Editar contacto'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : _save,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el nombre'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'\-]"),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _apellidoCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el apellido'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s'\-]"),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => _req(v, 'el teléfono'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9+\s\-]")),
                    LengthLimitingTextInputFormatter(18),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validEmail,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                    LengthLimitingTextInputFormatter(60),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dirCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: ['M', 'F', 'X'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(f),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _pickFecha,
                      icon: const Icon(Icons.date_range),
                      label: const Text('Elegir'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _save,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}