import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../shared/theme/driver_app_tokens.dart';

/// Single document slot on the verification upload screen.
class DriverDocumentUploadCard extends StatelessWidget {
  const DriverDocumentUploadCard({
    super.key,
    required this.title,
    required this.icon,
    required this.hasFile,
    required this.filePath,
    required this.uploading,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool hasFile;
  final String? filePath;
  final bool uploading;
  final bool enabled;
  final VoidCallback onTap;

  static const Color _cardBorder = Color(0xFFE8D4D8);
  static const Color _placeholderFill = Color(0xFFFAF6F7);
  static const Color _placeholderBorder = Color(0xFFD4A8B0);
  static const Color _hintText = Color(0xFF4A4A4A);
  static const Color _metaText = Color(0xFF6E6E6E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverAppTokens.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasFile ? const Color(0xFF8BC49A) : _cardBorder,
          width: hasFile ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _DocIconBadge(icon: icon, selected: hasFile),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: DriverAppTokens.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (uploading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DriverAppTokens.primary,
                      ),
                    )
                  else if (hasFile)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D4A), size: 26)
                  else
                    Icon(Icons.add_photo_alternate_outlined, color: DriverAppTokens.primary.withValues(alpha: 0.9), size: 26),
                ],
              ),
              const SizedBox(height: 12),
              if (hasFile && filePath != null)
                _SelectedPreview(path: filePath!)
              else
                const _UploadPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocIconBadge extends StatelessWidget {
  const _DocIconBadge({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8F5E9) : DriverAppTokens.routeBox,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: selected ? const Color(0xFF2E7D4A) : DriverAppTokens.primary,
        size: 24,
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: DriverDocumentUploadCard._placeholderFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DriverDocumentUploadCard._placeholderBorder, width: 1.2),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: DriverDocumentUploadCard._placeholderBorder),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: DriverAppTokens.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap to choose a photo',
            style: TextStyle(
              color: DriverDocumentUploadCard._hintText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'From your gallery · JPEG or PNG',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DriverDocumentUploadCard._metaText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  const _SelectedPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 56,
              height: 56,
              color: DriverAppTokens.routeBox,
              child: const Icon(Icons.image_not_supported_outlined, color: DriverAppTokens.bodyGray),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Photo selected',
                style: TextStyle(
                  color: Color(0xFF2E7D4A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to change',
                style: TextStyle(
                  color: DriverAppTokens.bodyGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
