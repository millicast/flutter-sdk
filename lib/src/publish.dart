import 'utils/base_web_rtc.dart';

const Map<String, dynamic> connectOptions = {};
const Object logger = {};

///
/// Callback invoke when a new connection path is needed.
///
/// @callback tokenGeneratorCallback
/// @returns {Promise<MillicastDirectorResponse>} Promise object which represents the result of getting the new connection path.
///
/// You can use your own token generator or use the <a href='Director'>Director available methods</a>.


/// @class BaseWebRTC
/// @extends EventEmitter
/// @classdesc Base class for common actions about peer connection and reconnect mechanism for Publishers and Viewer instances.
///
/// @constructor
/// @param {String} streamName - Millicast existing stream name.
/// @param {tokenGeneratorCallback} tokenGenerator - Callback function executed when a new token is needed.
/// @param {Object} loggerInstance - Logger instance from the extended classes.
/// @param {Boolean} autoReconnect - Enable auto reconnect.
/// 
///  */
class Publish extends BaseWebRTC {
  Publish(
      {required String streamName,
      required Function tokenGenerator,
      bool autoReconnect = true})
      : super(
            streamName: streamName,
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect,
            loggerInstance: logger);

  void connect({Map<String, dynamic> connectOptions = connectOptions}) async {}
  void reconnect() {}
}
