import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'dart:convert';

void main() {
  group('getSubscriber Tests', () {
    test(
        '''Subscribe to an existing unrestricted stream, invalid accountId and no token''',
        () async {
      var mockedReponseJson = {
        'status': 'fail',
        'data': {
          'streamId': 'Existing_Account_Id/Existing_Stream_Name',
          'message': 'stream not found'
        }
      };
      var client = MockClient((request) async => http.Response(
          json.encode(mockedReponseJson), 401,
          request: request, headers: {'content-type': 'application/json'}));

      const accountId = 'Existing_Account_Id';
      const streamName = 'Existing_Stream_Name';

      DirectorSubscriberOptions options = DirectorSubscriberOptions(
          streamName: streamName, streamAccountId: accountId, client: client);
      expect(Director.getSubscriber(options), throwsException);
    });

    test(
        '''Subscribe to an existing unrestricted stream, valid accountId, no token and options as object''',
        () async {
      const String dummyToken =
          '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE2NDM3NzYwODIsImV4cCI6MTY0Mzc3NjE0MiwiaWF0IjoxNjQzNzc2MDgyLCJpc3MiOiJodHRwczovL2RpcmVjdG9yLm1pbGxpY2FzdC5jb20iLCJhdWQiOiJNaWxsaWNhc3REaXJlY3RvclJlc291cmNlIiwibWlsbGljYXN0Ijp7InR5cGUiOiJTdWJzY3JpYmUiLCJzdHJlYW1BY2NvdW50SWQiOiJ0bkpodksiLCJzdHJlYW1OYW1lIjoia3l0MXpuamYiLCJzZXJ2ZXJJZCI6IjBlOGU1MmRjZGMyYzQ0NWRiNGM5ZTI1MjFmNzZiMDkxIiwiYWxsb3dlZElwQWRkcmVzc2VzIjpbXSwiYWxsb3dlZENvdW50cmllcyI6W10sImRlbmllZENvdW50cmllcyI6W10sImN1c3RvbURhdGEiOnsiaXNEaXJlY3RvciI6dHJ1ZSwicmVxdWVzdElkIjpudWxsLCJ0b2tlbiI6bnVsbCwic3Vic2NyaWJlUmVxdWlyZXNBdXRoIjpudWxsfX19.0F1P3OlrZwS2W3kefB2_o5Vd5Oip88uOlojV40SnmUk''';
      var mockedReponseJson = {
        'status': 'success',
        'data': {
          'wsUrl': 'wss://live-west.millicast.com/ws/v2/sub/12345',
          'urls': [
            'wss://live-west.millicast.com/ws/v2/sub/abf4edb5833a463d87c3f23ae891d3ed'
          ],
          'jwt': dummyToken,
          'streamAccountId': 'Existing_Stream_Id'
        }
      };
      var client = MockClient((request) async => http.Response(
          json.encode(mockedReponseJson), 200,
          request: request, headers: {'content-type': 'application/json'}));

      const accountId = 'Existing_Account_Id';
      const streamName = 'Existing_Stream_Name';

      DirectorSubscriberOptions options = DirectorSubscriberOptions(
          streamName: streamName, streamAccountId: accountId, client: client);
      var subscriberResopnse = await Director.getSubscriber(options);
      expect(subscriberResopnse, isA<MillicastDirectorResponse>());
    });
  });

  group('Publisher Tests', () {
    test('''Publish with an existing stream name and invalid token''',
        () async {
      var mockedReponseJson = {
        'status': 'fail',
        'data': {'message': 'Unauthorized: Invalid token'}
      };
      var client = MockClient((request) async => http.Response(
          json.encode(mockedReponseJson), 401,
          request: request, headers: {'content-type': 'application/json'}));

      const token = 'Invalid_token';
      const streamName = 'Existing_Stream_Name';

      DirectorPublisherOptions options = DirectorPublisherOptions(
          token: token, streamName: streamName, client: client);
      expect(Director.getPublisher(options), throwsException);
    });

    test(
        ''''Publish with an existing stream name, valid token and options as object''',
        () async {
      const String dummyToken =
          '''eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE2NDM3NzYwODIsImV4cCI6MTY0Mzc3NjE0MiwiaWF0IjoxNjQzNzc2MDgyLCJpc3MiOiJodHRwczovL2RpcmVjdG9yLm1pbGxpY2FzdC5jb20iLCJhdWQiOiJNaWxsaWNhc3REaXJlY3RvclJlc291cmNlIiwibWlsbGljYXN0Ijp7InR5cGUiOiJTdWJzY3JpYmUiLCJzdHJlYW1BY2NvdW50SWQiOiJ0bkpodksiLCJzdHJlYW1OYW1lIjoia3l0MXpuamYiLCJzZXJ2ZXJJZCI6IjBlOGU1MmRjZGMyYzQ0NWRiNGM5ZTI1MjFmNzZiMDkxIiwiYWxsb3dlZElwQWRkcmVzc2VzIjpbXSwiYWxsb3dlZENvdW50cmllcyI6W10sImRlbmllZENvdW50cmllcyI6W10sImN1c3RvbURhdGEiOnsiaXNEaXJlY3RvciI6dHJ1ZSwicmVxdWVzdElkIjpudWxsLCJ0b2tlbiI6bnVsbCwic3Vic2NyaWJlUmVxdWlyZXNBdXRoIjpudWxsfX19.0F1P3OlrZwS2W3kefB2_o5Vd5Oip88uOlojV40SnmUk''';
      const Map<String, dynamic> mockedReponseJson = {
        'status': 'success',
        'data': {
          'wsUrl': 'wss://live-west.millicast.com/ws/v2/sub/12345',
          'urls': [
            'wss://live-west.millicast.com/ws/v2/sub/abf4edb5833a463d87c3f23ae891d3ed'
          ],
          'jwt': dummyToken,
          'streamAccountId': 'Existing_Stream_Id'
        }
      };
      var client = MockClient((request) async => http.Response(
          json.encode(mockedReponseJson), 200,
          request: request, headers: {'content-type': 'application/json'}));

      const token = 'Invalid_token';
      const streamName = 'Existing_Stream_Name';

      DirectorPublisherOptions options = DirectorPublisherOptions(
          streamName: streamName, token: token, client: client);
      var publisherResponse = await Director.getPublisher(options);
      expect(publisherResponse, isA<MillicastDirectorResponse>());
    });
  });
}
