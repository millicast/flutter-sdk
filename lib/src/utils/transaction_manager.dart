import 'dart:async';
import 'dart:convert';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:eventify/eventify.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var _logger = getLogger('TransactionManager');

/// Simple transaction manager for json messages
/// Based on https://www.npmjs.com/package/transaction-manager
class TransactionManager extends EventEmitter {
  num maxId = 0;
  WebSocketChannel transport;
  Map<int, dynamic> transactions = {};
  StreamSubscription<dynamic>? listener;
  String? sdp;
  TransactionManager(this.transport) {
    onData(dynamic msg) async {
      Map<String, dynamic> message;
      try {
        //Process message
        message = jsonDecode(msg as String) as Map<String, dynamic>;
      } catch (e) {
        //Emit it
        //Ignore it
        return;
      }
      //Check type
      switch (message['type']) {
        case 'cmd':
          //Create command
          Map<String, dynamic> cmd = {
            'name': message['name'],
            'data': message['data'],
            'accept': (data) => {
                  //Send response back
                  transport.sink.add({
                    'type': 'response',
                    'transId': message['transId'],
                    'data': data
                  })
                },
            'reject': (data) => {
                  //Send response back
                  transport.sink.add(jsonEncode({
                    'type': 'error',
                    'transId': message['transId'],
                    'data': data
                  }))
                }
          };
          emit('cmd', this, cmd);
          break;
        case 'response':
          {
            //Get transaction
            var transaction = transactions[message['transId']];
            if (transaction == null) {
              _logger
                  .i('Transaction with ${message['transId']} was not found.');
              return;
            }
            //delete transacetion
            transactions.remove(message['transId']);
            //emit response
            if (transaction['completer'] is Completer) {
              if (message['data'] != null) {
                if (message['data']['sdp'] != null) {
                  transaction['completer'].complete(message);
                }
              }
            }
            break;
          }
        case 'error':
          {
            _logger.e(message);
            //Get transaction
            var transaction = transactions[message['transId']];
            if (transaction == null) {
              return;
            }
            //delete transacetion
            transactions.remove(message['transId']);
            break;
          }
        case 'event':
          //Create event
          var event = {
            'name': message['name'],
            'data': message['data'],
          };

          emit('event', this, event);

          break;
        default:
      }
    }

    onError(dynamic error) {
      try {
        //Process message
        emit(SignalingEvents.connectionError, this, error);
      } catch (e) {
        return;
      }
    }

    void onDone() {
      try {
        //Process message
        emit(SignalingEvents.connectionError, this);
      } catch (e) {
        return;
      }
    }

    //Add it
    listener = transport.stream.listen((event) => onData(event),
        onError: onError, onDone: onDone, cancelOnError: false);
  }

  Future<dynamic> cmd(String? name, data) async {
    var completer = Completer();
    Map<String, dynamic> cmd = {
      'type': 'cmd',
      'transId': maxId++,
      'name': name,
      'data': data,
    };
    //Serialize
    String json = jsonEncode(cmd);
    //Check name is correct
    if (name == null || name.isEmpty) {
      throw Exception('Bad command name');
    }
    //Add to map
    transactions[cmd['transId']] = {...cmd, 'completer': completer};
    try {
      //Send json
      transport.sink.add(json);
      return completer.future;
      //Add callbacks
    } catch (e) {
      //delete transacetion
      transactions.remove(cmd['transId']);
      //rethrow
      throw Exception(e);
    }
  }

  event(name, data) {
    //Check name is correct
    if (!name || name.length == 0) {
      throw Exception('Bad event name');
    }
    //Create command
    Map event = {'type': 'event', 'name': name, 'data': data};
    //Serialize
    String json = jsonEncode(event);
    //Send json
    transport.sink.add(json);
  }

  close() {
    //remove listeners
    listener?.onDone(() {});
    transport.sink.close();
  }
}
