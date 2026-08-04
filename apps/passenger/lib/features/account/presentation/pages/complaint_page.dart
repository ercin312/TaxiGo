import 'package:flutter/material.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();
    if (subject.isEmpty || description.isEmpty) return;

    setState(() => _loading = true);
    try {
      final api = passengerGetIt<ApiClient>();
      await api.post(
        ApiEndpoints.complaints,
        data: {
          'subject': subject,
          'description': description,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.submitComplaint)),
      );
      _subjectController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.complaints)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: l10n.complaintSubject),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.complaintDescription),
            ),
            const Spacer(),
            PrimaryButton(
              label: l10n.submitComplaint,
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
