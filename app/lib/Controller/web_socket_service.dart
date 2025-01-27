import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:logger/logger.dart';

class WebSocketService {
  final String serverUrl;
  late WebSocketChannel _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  static final Logger logger = Logger();
  
  // Message stream controller
  final _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

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

  Future<void> _connect() async {
    if (_isConnecting) {
      logger.log(Level.warning, "Connection attempt already in progress");
      return;
    }
    
    try {
      _isConnecting = true;
      _isConnected = false;
      
      logger.log(Level.info, "Attempting to connect to WebSocket at $serverUrl");
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      
      // Wait for the connection to be established
      await _channel.ready;
      
      // Only set connected after successful connection
      _isConnected = true;
      _isConnecting = false;
      logger.log(Level.info, "WebSocket connected successfully to $serverUrl");
      
      _channel.stream.listen(
        (message) {
          logger.log(Level.info, "Message received: $message");
          // Broadcast the message to all listeners
          _messageController.add(message.toString());
        },
        onDone: () {
          _isConnected = false;
          _isConnecting = false;
          logger.log(Level.warning, "WebSocket connection closed");
          _attemptReconnect();
        },
        onError: (error) {
          _isConnected = false;
          _isConnecting = false;
          logger.log(Level.error, "WebSocket error: $error");
          _attemptReconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      logger.log(Level.error, "Failed to connect WebSocket: $e");
      _attemptReconnect();
    }
  }

  bool isConnected() {
    return _isConnected && !_isConnecting;
  }

  bool isConnecting() {
    return _isConnecting;
  }

  Future<void> sendMessage(String message) async {
    if (isConnected()) {
      _channel.sink.add(message);
      logger.log(Level.info, "Message sent: $message");
    } else {
      logger.log(Level.warning, "Cannot send message. WebSocket is not connected.");
      throw Exception("WebSocket is not connected");
    }
  }

  void _attemptReconnect() {
    const retryInterval = Duration(seconds: 5);
    logger.log(Level.info, "Attempting to reconnect in ${retryInterval.inSeconds} seconds...");
    Timer(retryInterval, () {
      if (!_isConnected && !_isConnecting) {
        logger.log(Level.info, "Reconnecting to WebSocket...");
        _connect();
      }
    });
  }

  Future<void> reconnect() async {
    if (!_isConnected && !_isConnecting) {
      logger.log(Level.info, "Manually attempting to reconnect to WebSocket...");
      await _connect();
    } else if (_isConnecting) {
      logger.log(Level.info, "Connection attempt already in progress");
    } else {
      logger.log(Level.info, "WebSocket is already connected.");
    }
  }

  void closeConnection() {
    if (_isConnected) {
      _channel.sink.close(status.normalClosure);
      _isConnected = false;
      _isConnecting = false;
      logger.log(Level.info, "WebSocket connection closed manually.");
    }
    _messageController.close();
  }

  void dispose() {
    closeConnection();
    _messageController.close();
  }
}