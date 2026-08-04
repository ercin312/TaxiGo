import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:taxigo_core/taxigo_core.dart';

/// Notifies GoRouter when [AuthBloc] emits a new state.
class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh(AuthBloc authBloc) : _authBloc = authBloc {
    _subscription = _authBloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;

  AuthState get state => _authBloc.state;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
