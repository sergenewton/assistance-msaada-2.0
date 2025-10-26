import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfoImpl(this.connectivity);
  
  @override
  Future<bool> get isConnected => _hasConnection();
  
  Future<bool> _hasConnection() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Double check with actual network request
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}