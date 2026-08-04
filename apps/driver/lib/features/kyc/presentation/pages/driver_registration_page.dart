import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/l10n_extensions.dart';
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
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
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
            context.go('/pending');
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
                    TextFormField(
                      controller: _makeController,
                      decoration: InputDecoration(labelText: l10n.driverMode),
                      validator: (v) =>
                          v?.isEmpty ?? true ? l10n.somethingWentWrong : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Year'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Plate'),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.uploadDocument,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...DocumentType.values.map(
                      (type) => _DocumentUploadTile(
                        label: type.localized(l10n),
                        isUploaded: documents.containsKey(type),
                        onTap: () => _pickDocument(type),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.confirm,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (documents.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.uploadDocument)),
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
    required this.isUploaded,
    required this.onTap,
  });

  final String label;
  final bool isUploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.upload_file, color: AppColors.primary),
        title: Text(label),
        trailing: isUploaded
            ? Icon(Icons.check_circle, color: Colors.green.shade600)
            : const Icon(Icons.add),
        onTap: onTap,
      ),
    );
  }
}
