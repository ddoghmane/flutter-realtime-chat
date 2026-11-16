import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connecté');
    });

    socket.onDisconnect((_) {
      print('❌ Socket déconnecté');
    });

    socket.onConnectError((error) {
      print('🚨 Erreur connexion : $error');
    });
  }

  void registerUser(String username) {
    socket.emit('registerUser', username);
  }

  void sendMessage(Map<String, dynamic> data) {
    socket.emit('sendMessage', data);
  }

  void listen(Function(dynamic) callback) {
    socket.on('newPrivateMessage', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}
