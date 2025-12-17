import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// An enum to represent the different states of network connectivity.
enum ConnectivityStatus { connected, disconnected }

/// A service class to manage and provide network connectivity status.
///
/// This service abstracts the `connectivity_plus` package and provides a simple
/// stream of [ConnectivityStatus] that the UI can listen to.
class ConnectivityService {
  // A private controller for the connectivity stream.
  final _connectivityController = StreamController<ConnectivityStatus>();
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// A public stream to listen for connectivity status changes.
  Stream<ConnectivityStatus> get status => _connectivityController.stream;

  ConnectivityService() {
    // Listen to the stream from the connectivity_plus package.
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final hasConnection = !result.contains(ConnectivityResult.none);
    // Add the new status to the stream.
    _connectivityController.add(
        hasConnection ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
  }

  /// Disposes the stream controller and subscription to prevent memory leaks.
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController.close();
  }
}