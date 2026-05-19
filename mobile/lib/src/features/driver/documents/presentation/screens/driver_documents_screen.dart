import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/login_result.dart';
import '../../../../../shared/theme/customer_registration_tokens.dart';
import '../../../../../shared/widgets/registration/registration_solid_primary_button.dart';
import '../../../data/driver_onboarding_repository.dart';
import '../../../otp/navigation/driver_otp_navigation.dart';

/// Upload required driver verification documents before OTP.
class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  final Map<String, String?> _paths = <String, String?>{
    'license': null,
    'national_id': null,
    'vehicle_registration': null,
  };

  bool _submitting = false;
  String? _uploadingType;

  static const List<(_DocMeta type, String title, IconData icon)> _docs = <(_DocMeta, String, IconData)>[
    ('license', 'Driver license', Icons.badge_outlined),
    ('national_id', 'National ID', Icons.credit_card_rounded),
    ('vehicle_registration', 'Vehicle registration', Icons.description_outlined),
  ];

  Future<void> _pick(String type) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) {
      return;
    }
    setState(() => _paths[type] = file.path);
  }

  Future<void> _submit() async {
    for (final (_DocMeta type, String title, _) in _docs) {
      if (_paths[type] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload: $title')),
        );
        return;
      }
    }

    setState(() => _submitting = true);
    final DriverOnboardingRepository repo = context.read<DriverOnboardingRepository>();

    try {
      for (final (_DocMeta type, _, _) in _docs) {
        setState(() => _uploadingType = type);
        final String path = _paths[type]!;
        final LoginResult res = await repo.uploadDocument(
          documentType: type,
          filePath: path,
          filename: path.split(Platform.pathSeparator).last,
          contentType: 'image/jpeg',
        );
        if (res is LoginFailure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
          }
          return;
        }
      }
      if (mounted) {
        DriverOtpNavigation.open(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadingType = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: CustomerRegistrationTokens.primaryMaroon,
        title: const Text('Verification documents', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Upload clear photos of each document. Max 5 MB per file (JPEG/PNG/PDF).',
                style: TextStyle(color: CustomerRegistrationTokens.labelGray, height: 1.4),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final (_DocMeta type, String title, IconData icon) = _docs[index];
                    final bool hasFile = _paths[type] != null;
                    final bool uploading = _uploadingType == type;
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      tileColor: const Color(0xFFF3E8EB),
                      leading: Icon(icon, color: CustomerRegistrationTokens.primaryMaroon),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(hasFile ? 'Ready to upload' : 'Tap to select file'),
                      trailing: uploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              hasFile ? Icons.check_circle : Icons.upload_file_rounded,
                              color: hasFile ? Colors.green : CustomerRegistrationTokens.primaryMaroon,
                            ),
                      onTap: _submitting ? null : () => _pick(type),
                    );
                  },
                ),
              ),
              RegistrationSolidPrimaryButton(
                label: 'CONTINUE',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _DocMeta = String;
