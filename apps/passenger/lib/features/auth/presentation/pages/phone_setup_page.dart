import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../widgets/country_dial_codes.dart';

/// Collects phone after Apple / Google sign-in.
class PhoneSetupPage extends StatefulWidget {
  const PhoneSetupPage({super.key});

  @override
  State<PhoneSetupPage> createState() => _PhoneSetupPageState();
}

class _PhoneSetupPageState extends State<PhoneSetupPage> {
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  CountryDialCode _country = kDefaultCountryDial;
  bool _loading = false;
  bool _countryPicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openCountryPicker(initial: true);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _logout() {
    takePendingIntendedRole();
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.go('/login');
  }

  Future<void> _openCountryPicker({bool initial = false}) async {
    final selected = await showModalBottomSheet<CountryDialCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _CountryPickerSheet(
        searchController: _searchController,
        selected: _country,
      ),
    );
    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _country = selected;
        _countryPicked = true;
      });
    } else if (initial) {
      // User dismissed without picking — keep Montenegro default and continue.
      setState(() => _countryPicked = true);
    }
  }

  String _buildE164() {
    final raw = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    if (raw.startsWith('+')) return '+$digits';
    return '${_country.dialCode}$digits';
  }

  Future<void> _submit() async {
    final phone = _buildE164();
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir telefon numarası girin')),
      );
      return;
    }

    setState(() => _loading = true);
    final result = await passengerGetIt<UserRepository>().updateProfile(
      phone: phone,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    await result.fold(
      (error) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      (user) async {
        context.read<AuthBloc>().add(AuthUserUpdated(user));
        final route = await resolvePostAuthRoute(user);
        if (mounted) context.go(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthBloc>().state.user;

    return AuthScaffold(
      title: l10n.phoneNumber,
      subtitle: 'Apple / Google girişinden sonra telefon numaranızı ekleyin.',
      topAction: TextButton(
        onPressed: _loading ? null : _logout,
        child: Text(
          l10n.signOut,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null && user.name.trim().isNotEmpty) ...[
            Text(
              user.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (user.email != null && user.email!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.email!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          InkWell(
            onTap: _loading ? null : () => _openCountryPicker(),
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Ülke kodu',
                prefixIcon: const Icon(Icons.public_rounded),
                suffixIcon: const Icon(Icons.expand_more_rounded),
              ),
              child: Text(
                _countryPicked
                    ? '${_country.flag}  ${_country.name}  (${_country.dialCode})'
                    : 'Ülke seçin',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            enabled: !_loading && _countryPicked,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-]')),
            ],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.phoneNumber,
              hintText: '67 000 000',
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: '${_country.dialCode}  ',
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: l10n.continueButton,
            isLoading: _loading,
            onPressed: _countryPicked ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.searchController,
    required this.selected,
  });

  final TextEditingController searchController;
  final CountryDialCode selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? kCountryDialCodes
        : kCountryDialCodes.where((c) {
            return c.name.toLowerCase().contains(q) ||
                c.dialCode.contains(q) ||
                c.iso2.toLowerCase().contains(q);
          }).toList();

    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Ülke kodu seçin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: widget.searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ülke veya kod ara…',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                final selected = c.iso2 == widget.selected.iso2 &&
                    c.dialCode == widget.selected.dialCode;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(c.name),
                  trailing: Text(
                    c.dialCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.accentDeep : null,
                    ),
                  ),
                  selected: selected,
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
