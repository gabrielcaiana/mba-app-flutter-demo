import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  List<Role> _availableRoles = [];
  Set<String> _selectedRoles = {};
  bool _loadingRoles = true;
  bool _saving = false;
  bool _obscurePassword = true;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.user!.name;
      _usernameCtrl.text = widget.user!.username;
      _selectedRoles = Set.from(widget.user!.roles);
    }
    _loadRoles();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await ApiService.instance.getRoles();
      if (mounted) setState(() => _availableRoles = roles);
    } catch (_) {
      // Roles não obrigatórias para carregar o formulário
    } finally {
      if (mounted) setState(() => _loadingRoles = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final user = User(
        id: widget.user?.id,
        name: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
        roles: _selectedRoles.toList(),
      );

      if (_isEditing) {
        await ApiService.instance.updateUser(widget.user!.id!, user);
      } else {
        await ApiService.instance.createUser(user);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Usuário atualizado!' : 'Usuário criado!'),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuário' : 'Novo Usuário'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dados do Usuário',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Usuário (login)',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o usuário' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'Nova senha (deixe em branco para manter)'
                      : 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (!_isEditing && (v == null || v.isEmpty)) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Roles do Usuário',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              _buildRolesSection(),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Salvar Alterações' : 'Criar Usuário',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolesSection() {
    if (_loadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableRoles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Nenhuma role disponível. Cadastre roles primeiro.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: _availableRoles.map((role) {
          final isSelected = _selectedRoles.contains(role.name);
          return CheckboxListTile(
            title: Text(role.name),
            subtitle: role.description != null && role.description!.isNotEmpty
                ? Text(role.description!)
                : null,
            value: isSelected,
            activeColor: Colors.deepPurple,
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedRoles.add(role.name);
                } else {
                  _selectedRoles.remove(role.name);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
