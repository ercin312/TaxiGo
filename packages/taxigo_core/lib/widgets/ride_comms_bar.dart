import 'dart:async';

import 'package:flutter/material.dart';

import '../core/di/locator.dart';
import '../core/theme/app_colors.dart';
import '../domain/models/ride_comms_models.dart';
import '../domain/repositories/ride_comms_repository.dart';
import '../l10n/app_localizations.dart';
import '../services/feature_modules_service.dart';

/// In-ride messaging only (no calling). Module: `ride_comms`.
class RideCommsBar extends StatelessWidget {
  const RideCommsBar({
    super.key,
    required this.rideId,
    this.compact = false,
  });

  final int rideId;
  final bool compact;

  void _openChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideChatSheet(rideId: rideId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!locator<FeatureModulesService>().rideComms) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return IconButton(
        tooltip: l10n.rideChat,
        onPressed: () => _openChat(context),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: () => _openChat(context),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: Text(l10n.rideChat),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.accent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class RideChatSheet extends StatefulWidget {
  const RideChatSheet({super.key, required this.rideId});

  final int rideId;

  @override
  State<RideChatSheet> createState() => _RideChatSheetState();
}

class _RideChatSheetState extends State<RideChatSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<RideMessageModel> _messages = [];
  List<RideMessageTemplate> _templates = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _load(quiet: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final repo = locator<RideCommsRepository>();
    final msgs = await repo.getMessages(widget.rideId);
    final tpls = await repo.getTemplates(widget.rideId);
    if (!mounted) return;

    msgs.fold(
      (e) {
        if (!quiet) setState(() => _error = e);
      },
      (list) => setState(() {
        _messages = list;
        _loading = false;
      }),
    );
    tpls.fold((_) {}, (list) => setState(() => _templates = list));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send({String? body, String? templateKey}) async {
    final text = body?.trim() ?? '';
    if (_sending) return;
    if (templateKey == null && text.isEmpty) return;

    setState(() => _sending = true);
    final result = await locator<RideCommsRepository>().sendMessage(
      widget.rideId,
      body: templateKey == null ? text : null,
      templateKey: templateKey,
    );
    if (!mounted) return;
    setState(() => _sending = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (msg) {
        _controller.clear();
        setState(() => _messages = [..._messages, msg]);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  String _templateLabel(AppLocalizations l10n, String key) {
    return switch (key) {
      'where_are_you' => l10n.chatTplWhereAreYou,
      'im_outside' => l10n.chatTplImOutside,
      'at_the_door' => l10n.chatTplAtTheDoor,
      'luggage' => l10n.chatTplLuggage,
      'running_late' => l10n.chatTplRunningLate,
      'cant_find' => l10n.chatTplCantFind,
      'ok' => l10n.chatTplOk,
      'on_my_way' => l10n.chatTplOnMyWay,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.72,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.rideChat,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          l10n.rideChatPrivacyHint,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (_templates.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _templates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final t = _templates[i];
                    return ActionChip(
                      label: Text(_templateLabel(l10n, t.key)),
                      onPressed: _sending
                          ? null
                          : () => _send(templateKey: t.key),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _messages.isEmpty
                      ? Center(child: Text(_error!))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            final m = _messages[i];
                            return Align(
                              alignment: m.isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: m.isMine
                                      ? AppColors.ink
                                      : AppColors.mist.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  m.body,
                                  style: TextStyle(
                                    color: m.isMine
                                        ? Colors.white
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLength: 280,
                        decoration: InputDecoration(
                          hintText: l10n.rideChatHint,
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _send(body: _controller.text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _sending
                          ? null
                          : () => _send(body: _controller.text),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.accent,
                      ),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
