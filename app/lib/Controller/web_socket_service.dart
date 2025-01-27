import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:logger/logger.dart';

class WebSocketService {
  final String serverUrl;
  late WebSocketChannel _channel;
  bool _isConnected = false;
  static final Logger logger = Logger();

  // Singleton instance
  static WebSocketService? _instance;

  WebSocketService._internal(this.serverUrl) {
    _connect();
  }

  factory WebSocketService({required String serverUrl}) {
    if (_instance == null) {
      _instance = WebSocketService._internal(serverUrl);
    } else if (_instance!.serverUrl != serverUrl) {
      throw Exception("WebSocketService is already initialized with a different URL.");
    }
    return _instance!;
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;
      logger.log(Level.info, "WebSocket connected to $serverUrl");

      _channel.stream.listen(
        (message) {
          logger.log(Level.info, "Message received: $message");
          // Handle incoming messages
        },
        onDone: () {
          _isConnected = false;
          logger.log(Level.warning, "WebSocket connection closed");
          _attemptReconnect();
        },
        onError: (error) {
          _isConnected = false;
          logger.log(Level.error, "WebSocket error: $error");
          _attemptReconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      logger.log(Level.error, "Failed to connect WebSocket: $e");
      _attemptReconnect();
    }
  }

  bool isConnected() {
    return _isConnected;
  }

  void sendMessage(String message) {
    if (_isConnected) {
      _channel.sink.add(message);
      logger.log(Level.info, "Message sent: $message");
    } else {
      logger.log(Level.warning, "Cannot send message. WebSocket is not connected.");
    }
  }

  void _attemptReconnect() {
    const retryInterval = Duration(seconds: 5);
    logger.log(Level.info, "Attempting to reconnect in ${retryInterval.inSeconds} seconds...");
    Timer(retryInterval, () {
      if (!_isConnected) {
        logger.log(Level.info, "Reconnecting to WebSocket...");
        _connect();
      }
    });
  }

  void reconnect() {
    if (!_isConnected) {
      logger.log(Level.info, "Manually attempting to reconnect to WebSocket...");
      _connect();
    } else {
      logger.log(Level.info, "WebSocket is already connected.");
    }
  }

  void closeConnection() {
    if (_isConnected) {
      _channel.sink.close(status.normalClosure);
      _isConnected = false;
      logger.log(Level.info, "WebSocket connection closed manually.");
    }
  }
}
