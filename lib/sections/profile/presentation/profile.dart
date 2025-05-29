import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Profile/presentation/widgets_profile.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:flutter/services.dart';
import 'package:mi_hospital/sections/Profile/entities/ProfileFirebase.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var userLogin = GetData().getUserLogin();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  final ProfileFirebase _profileFirebase = ProfileFirebase();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: userLogin["correo"] ?? '');
    _phoneController = TextEditingController(text: userLogin["telefono"] ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _profileFirebase.updateUserProfile(
          userLogin["codigo"],
          {
            'email': _emailController.text.trim(),
            'telefono': _phoneController.text.trim(),
          },
        );
        
        setState(() {
          _isEditing = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Datos actualizados exitosamente'),
            backgroundColor: ThemeHospital.getButtonBlue(),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar los datos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarHospital().getAppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeHospital.getButtonBlue().withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              widgets_Profile().getAvatar(),
              const SizedBox(height: 24),
              widgets_Profile().getWidgetNameSurName(userLogin["nombre"], ""),
              const SizedBox(height: 16),
              widgets_Profile().getWidgetCode(userLogin["codigo"]),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widgets_Profile().getIconHospital(),
                    const SizedBox(width: 12),
                    widgets_Profile().getNameHospital(userLogin["hospital"]),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: ThemeHospital.getButtonBlue()),
                              const SizedBox(width: 12),
                              Text(
                                'Información del Perfil',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeHospital.getButtonBlue(),
                                ),
                              ),
                            ],
                          ),
                          if (!_isEditing)
                            IconButton(
                              icon: Icon(Icons.edit, color: ThemeHospital.getButtonBlue()),
                              onPressed: () => setState(() => _isEditing = true),
                            )
                          else
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: _saveChanges,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _emailController.text = userLogin["correo"] ?? '';
                                      _phoneController.text = userLogin["telefono"] ?? '';
                                    });
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildEditableInfoItem(
                        Icons.email_outlined,
                        'Correo',
                        _emailController,
                        _isEditing,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un correo';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Por favor ingrese un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildEditableInfoItem(
                        Icons.phone_outlined,
                        'Teléfono',
                        _phoneController,
                        _isEditing,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un teléfono';
                          }
                          if (value.length != 9) {
                            return 'El teléfono debe tener 9 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildInfoItem(Icons.work_outline, 'Cargo', userLogin["cargo"] ?? 'No disponible'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableInfoItem(
    IconData icon,
    String label,
    TextEditingController controller,
    bool isEditing,
    String? Function(String?)? validator,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (isEditing)
                TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: label == 'Teléfono' ? TextInputType.number : TextInputType.emailAddress,
                  inputFormatters: label == 'Teléfono' 
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                  maxLength: label == 'Teléfono' ? 9 : null,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeHospital.getButtonBlue()),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: ThemeHospital.getButtonBlue()),
                    ),
                    counterText: '',
                    hintText: label == 'Teléfono' ? '9 dígitos' : 'ejemplo@correo.com',
                  ),
                )
              else
                Text(
                  controller.text.isEmpty ? 'No disponible' : controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
