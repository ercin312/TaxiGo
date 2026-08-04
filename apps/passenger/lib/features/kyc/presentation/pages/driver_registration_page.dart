import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/l10n_extensions.dart';
import '../../../app_mode/application/app_mode_cubit.dart';
import '../../application/kyc_bloc.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(DocumentType type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<KycBloc>().add(
            KycDocumentSelected(type: type, file: File(image.path)),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driverMode)),
      body: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycPendingApproval) {
            context.go('/driver/pending');
          } else if (state is KycApproved) {
            context.read<AppModeCubit>().switchToDriver(isApproved: true);
            context.go('/driver-home');
          } else if (state is KycFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final documents = state is KycRegistrationInProgress
              ? state.documents
              : <DocumentType, File>{};

          return LoadingOverlay(
            isLoading: state is KycLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Araç bilgileri',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taksi moduna geçmek için araç bilgilerini ve zorunlu belgeleri yükleyin.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(
                        labelText: 'Marka',
                        hintText: 'Örn. Toyota',
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Marka gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'Örn. Corolla',
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Model gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Model yılı',
                        hintText: 'Örn. 2020',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Yıl gerekli';
                        final year = int.tryParse(v);
                        if (year == null || year < 1990) {
                          return 'Geçerli bir yıl girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Renk',
                        hintText: 'Örn. Beyaz',
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Renk gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Plaka',
                        hintText: 'Örn. 34 TG 01',
                      ),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Plaka gerekli' : null,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.uploadDocument,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4 zorunlu belge: kimlik, ehliyet, ruhsat, araç fotoğrafı. '
                      'Yönetici onayından sonra taksi modu açılır.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...DocumentType.values.map(
                      (type) => _DocumentUploadTile(
                        label: type.localized(l10n),
                        file: documents[type],
                        onTap: () => _pickDocument(type),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.confirm,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (documents.length < DocumentType.values.length) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lütfen tüm belgeleri yükleyin '
                                  '(${documents.length}/${DocumentType.values.length})',
                                ),
                              ),
                            );
                            return;
                          }
                          context.read<KycBloc>()
                            ..add(
                              KycVehicleInfoSubmitted(
                                make: _makeController.text.trim(),
                                model: _modelController.text.trim(),
                                year: int.parse(_yearController.text.trim()),
                                color: _colorController.text.trim(),
                                plateNumber: _plateController.text.trim(),
                              ),
                            )
                            ..add(const KycSubmitRegistration());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.label,
    required this.file,
    required this.onTap,
  });

  final String label;
  final File? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uploaded = file != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: uploaded
                    ? Image.file(
                        file!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.upload_file,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      uploaded ? 'Yüklendi — değiştirmek için dokunun' : 'Kamera veya galeri',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                uploaded ? Icons.check_circle : Icons.add_circle_outline,
                color: uploaded ? Colors.green.shade600 : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
