import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/contracts/login_result.dart';
import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/widgets/registration/registration_solid_primary_button.dart';
import '../../../data/driver_onboarding_repository.dart';
import '../../../onboarding/navigation/driver_onboarding_exit.dart';
import '../../../otp/navigation/driver_otp_navigation.dart';
import '../widgets/driver_document_upload_card.dart';

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
    final int selectedCount = _paths.values.where((String? p) => p != null).length;

    return Scaffold(
      backgroundColor: DriverAppTokens.screenBackground,
      appBar: AppBar(
        backgroundColor: DriverAppTokens.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: DriverAppTokens.primary,
        title: const Text(
          'Verification documents',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: DriverAppTokens.ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => DriverOnboardingExit.toRoleSelection(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DriverAppTokens.routeBox,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8C4CC)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: DriverAppTokens.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Upload clear photos',
                            style: TextStyle(
                              color: DriverAppTokens.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Each document must be readable and under 5 MB (JPEG, PNG, or PDF).',
                            style: TextStyle(
                              color: DriverAppTokens.bodyGray,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$selectedCount of ${_docs.length} added',
                style: const TextStyle(
                  color: DriverAppTokens.bodyGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (BuildContext context, int index) {
                    final (_DocMeta type, String title, IconData icon) = _docs[index];
                    final String? path = _paths[type];
                    return DriverDocumentUploadCard(
                      title: title,
                      icon: icon,
                      hasFile: path != null,
                      filePath: path,
                      uploading: _uploadingType == type,
                      enabled: !_submitting,
                      onTap: () => _pick(type),
                    );
                  },
                ),
              ),
              RegistrationSolidPrimaryButton(
                label: 'CONTINUE',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _submitting ? null : () => DriverOnboardingExit.toRoleSelection(context),
                child: const Text(
                  'Continue as customer instead',
                  style: TextStyle(
                    color: DriverAppTokens.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _DocMeta = String;
