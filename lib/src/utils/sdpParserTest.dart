// ignore: file_names


 String remoteSdpNoNego='''v=0
o=- 1654547312354 1 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0 1
a=msid-semantic: WMS e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ice-lite
m=video 40330 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 108 109 123 119 37 38 41 42
c=IN IP4 165.227.54.155
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:1 1 udp 2130706431 165.227.54.155 40330 typ host generation 0
a=ice-ufrag:f0a4e2c3a0a1c79c
a=ice-pwd:7c6c984caaeedbd55b068c769215447af0c9b9927ea09013
a=fingerprint:sha-256 08:17:29:59:24:5F:9E:A6:A1:87:08:90:05:70:3C:39:6E:04:EC:ED:63:D8:6B:B0:65:D4:07:D0:5F:37:B4:35
a=setup:passive
a=mid:0
a=extmap:12 http://www.webrtc.org/experiments/rtp-hdrext/abs-capture-time
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendonly
a=msid:e01b5844-23a3-4b9f-b12a-807cdfaab0b7 video7351
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtcp-fb:96 transport-cc
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=rtcp-fb:98 transport-cc
a=fmtp:98 profile-id=0
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 VP9/90000
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=rtcp-fb:100 transport-cc
a=fmtp:100 profile-id=2
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=rtpmap:102 VP9/90000
a=rtcp-fb:102 goog-remb
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack
a=rtcp-fb:102 nack pli
a=rtcp-fb:102 transport-cc
a=fmtp:102 profile-id=1
a=rtpmap:122 rtx/90000
a=fmtp:122 apt=102
a=rtpmap:127 H264/90000
a=rtcp-fb:127 goog-remb
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack
a=rtcp-fb:127 nack pli
a=rtcp-fb:127 transport-cc
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=rtpmap:121 rtx/90000
a=fmtp:121 apt=127
a=rtpmap:108 H264/90000
a=rtcp-fb:108 goog-remb
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack
a=rtcp-fb:108 nack pli
a=rtcp-fb:108 transport-cc
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:109 rtx/90000
a=fmtp:109 apt=108
a=rtpmap:123 H264/90000
a=rtcp-fb:123 goog-remb
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack
a=rtcp-fb:123 nack pli
a=rtcp-fb:123 transport-cc
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d001f
a=rtpmap:119 rtx/90000
a=fmtp:119 apt=123
a=rtpmap:37 H264/90000
a=rtcp-fb:37 goog-remb
a=rtcp-fb:37 ccm fir
a=rtcp-fb:37 nack
a=rtcp-fb:37 nack pli
a=rtcp-fb:37 transport-cc
a=fmtp:37 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=f4001f
a=rtpmap:38 rtx/90000
a=fmtp:38 apt=37
a=rtpmap:41 AV1/90000
a=rtcp-fb:41 goog-remb
a=rtcp-fb:41 ccm fir
a=rtcp-fb:41 nack
a=rtcp-fb:41 nack pli
a=rtcp-fb:41 transport-cc
a=rtpmap:42 rtx/90000
a=fmtp:42 apt=41
a=ssrc-group:FID 1628921562 1772988428
a=ssrc:1628921562 cname:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:1628921562 msid:e01b5844-23a3-4b9f-b12a-807cdfaab0b7 video7351
a=ssrc:1628921562 mslabel:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:1628921562 label:video7351
a=ssrc:1772988428 cname:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:1772988428 msid:e01b5844-23a3-4b9f-b12a-807cdfaab0b7 video7351
a=ssrc:1772988428 mslabel:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:1772988428 label:video7351
m=audio 40330 UDP/TLS/RTP/SAVPF 117 111
c=IN IP4 165.227.54.155
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:1 1 udp 2130706431 165.227.54.155 40330 typ host generation 0
a=ice-ufrag:f0a4e2c3a0a1c79c
a=ice-pwd:7c6c984caaeedbd55b068c769215447af0c9b9927ea09013
a=fingerprint:sha-256 08:17:29:59:24:5F:9E:A6:A1:87:08:90:05:70:3C:39:6E:04:EC:ED:63:D8:6B:B0:65:D4:07:D0:5F:37:B4:35
a=setup:passive
a=mid:1
a=extmap:14 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=sendonly
a=msid:e01b5844-23a3-4b9f-b12a-807cdfaab0b7 audio7352
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:117 multiopus/48000/6
a=fmtp:117 channel_mapping=0,4,1,2,3,5;coupled_streams=2;minptime=10;num_streams=4;useinbandfec=1
a=rtpmap:111 opus/48000/2
a=fmtp:111 minptime=10;stereo=1;useinbandfec=1
a=ssrc:616622190 cname:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:616622190 msid:e01b5844-23a3-4b9f-b12a-807cdfaab0b7 audio7352
a=ssrc:616622190 mslabel:e01b5844-23a3-4b9f-b12a-807cdfaab0b7
a=ssrc:616622190 label:audio7352''';


const remoteSdpWithNego ='''v=0
o=- 1654536558929 0 IN IP4 127.0.0.1
s=semantic-sdp
c=IN IP4 0.0.0.0
t=0 0
a=ice-lite
a=msid-semantic: WMS *
a=group:BUNDLE 0 1 2
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 108 109 123 119 37 38 41 42
a=rtpmap:96 VP8/90000
a=rtpmap:97 rtx/90000
a=rtpmap:98 VP9/90000
a=rtpmap:99 rtx/90000
a=rtpmap:100 VP9/90000
a=rtpmap:101 rtx/90000
a=rtpmap:102 VP9/90000
a=rtpmap:122 rtx/90000
a=rtpmap:127 H264/90000
a=rtpmap:121 rtx/90000
a=rtpmap:108 H264/90000
a=rtpmap:109 rtx/90000
a=rtpmap:123 H264/90000
a=rtpmap:119 rtx/90000
a=rtpmap:37 H264/90000
a=rtpmap:38 rtx/90000
a=rtpmap:41 AV1/90000
a=rtpmap:42 rtx/90000
a=fmtp:97 apt=96
a=fmtp:99 apt=98
a=fmtp:98 profile-id=0
a=fmtp:101 apt=100
a=fmtp:100 profile-id=2
a=fmtp:122 apt=102
a=fmtp:102 profile-id=1
a=fmtp:121 apt=127
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=fmtp:109 apt=108
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=fmtp:119 apt=123
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d001f
a=fmtp:38 apt=37
a=fmtp:37 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=f4001f
a=fmtp:42 apt=41
a=rtcp-fb:96 goog-remb 
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack 
a=rtcp-fb:96 nack pli
a=rtcp-fb:96 transport-cc 
a=rtcp-fb:98 goog-remb 
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack 
a=rtcp-fb:98 nack pli
a=rtcp-fb:98 transport-cc 
a=rtcp-fb:100 goog-remb 
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack 
a=rtcp-fb:100 nack pli
a=rtcp-fb:100 transport-cc 
a=rtcp-fb:102 goog-remb 
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack 
a=rtcp-fb:102 nack pli
a=rtcp-fb:102 transport-cc 
a=rtcp-fb:127 goog-remb 
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack 
a=rtcp-fb:127 nack pli
a=rtcp-fb:127 transport-cc 
a=rtcp-fb:108 goog-remb 
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack 
a=rtcp-fb:108 nack pli
a=rtcp-fb:108 transport-cc 
a=rtcp-fb:123 goog-remb 
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack 
a=rtcp-fb:123 nack pli
a=rtcp-fb:123 transport-cc 
a=rtcp-fb:37 goog-remb 
a=rtcp-fb:37 ccm fir
a=rtcp-fb:37 nack 
a=rtcp-fb:37 nack pli
a=rtcp-fb:37 transport-cc 
a=rtcp-fb:41 goog-remb 
a=rtcp-fb:41 ccm fir
a=rtcp-fb:41 nack 
a=rtcp-fb:41 nack pli
a=rtcp-fb:41 transport-cc 
a=extmap:12 http://www.webrtc.org/experiments/rtp-hdrext/abs-capture-time
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=setup:passive
a=mid:0
a=msid:ac6b710b-1476-4b64-9997-94db924cfed6 video5552
a=sendonly
a=ice-ufrag:0f4b10273ed08f42
a=ice-pwd:6feb66ae97ae014aa9544cc0284ce4e074a015b675131a0d
a=fingerprint:sha-256 08:17:29:59:24:5F:9E:A6:A1:87:08:90:05:70:3C:39:6E:04:EC:ED:63:D8:6B:B0:65:D4:07:D0:5F:37:B4:35
a=candidate:1 1 udp 2130706431 165.227.54.155 57215 typ host
a=ssrc:1865904804 cname:ac6b710b-1476-4b64-9997-94db924cfed6
a=ssrc:1865904804 msid:ac6b710b-1476-4b64-9997-94db924cfed6 video5552
a=ssrc:378333061 cname:ac6b710b-1476-4b64-9997-94db924cfed6
a=ssrc:378333061 msid:ac6b710b-1476-4b64-9997-94db924cfed6 video5552
a=ssrc-group:FID 1865904804 378333061
a=rtcp-mux
a=rtcp-rsize
m=audio 9 UDP/TLS/RTP/SAVPF 117 111
a=rtpmap:117 multiopus/48000/6
a=rtpmap:111 opus/48000/2
a=fmtp:117 channel_mapping=0,4,1,2,3,5;coupled_streams=2;minptime=10;num_streams=4;useinbandfec=1
a=fmtp:111 minptime=10;stereo=1;useinbandfec=1
a=extmap:14 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=setup:passive
a=mid:1
a=msid:ac6b710b-1476-4b64-9997-94db924cfed6 audio5553
a=sendonly
a=ice-ufrag:0f4b10273ed08f42
a=ice-pwd:6feb66ae97ae014aa9544cc0284ce4e074a015b675131a0d
a=fingerprint:sha-256 08:17:29:59:24:5F:9E:A6:A1:87:08:90:05:70:3C:39:6E:04:EC:ED:63:D8:6B:B0:65:D4:07:D0:5F:37:B4:35
a=candidate:1 1 udp 2130706431 165.227.54.155 57215 typ host
a=ssrc:585882543 cname:ac6b710b-1476-4b64-9997-94db924cfed6
a=ssrc:585882543 msid:ac6b710b-1476-4b64-9997-94db924cfed6 audio5553
a=rtcp-mux
a=rtcp-rsize
video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 108 109 123 119 37 38 41 42
a=rtpmap:96 VP8/90000
a=rtpmap:97 rtx/90000
a=rtpmap:98 VP9/90000
a=rtpmap:99 rtx/90000
a=rtpmap:100 VP9/90000
a=rtpmap:101 rtx/90000
a=rtpmap:102 VP9/90000
a=rtpmap:122 rtx/90000
a=rtpmap:127 H264/90000
a=rtpmap:121 rtx/90000
a=rtpmap:108 H264/90000
a=rtpmap:109 rtx/90000
a=rtpmap:123 H264/90000
a=rtpmap:119 rtx/90000
a=rtpmap:37 H264/90000
a=rtpmap:38 rtx/90000
a=rtpmap:41 AV1/90000
a=rtpmap:42 rtx/90000
a=fmtp:97 apt=96
a=fmtp:99 apt=98
a=fmtp:98 profile-id=0
a=fmtp:101 apt=100
a=fmtp:100 profile-id=2
a=fmtp:122 apt=102
a=fmtp:102 profile-id=1
a=fmtp:121 apt=127
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=fmtp:109 apt=108
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=fmtp:119 apt=123
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d001f
a=fmtp:38 apt=37
a=fmtp:37 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=f4001f
a=fmtp:42 apt=41
a=rtcp-fb:96 goog-remb 
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack 
a=rtcp-fb:96 nack pli
a=rtcp-fb:96 transport-cc 
a=rtcp-fb:98 goog-remb 
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack 
a=rtcp-fb:98 nack pli
a=rtcp-fb:98 transport-cc 
a=rtcp-fb:100 goog-remb 
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack 
a=rtcp-fb:100 nack pli
a=rtcp-fb:100 transport-cc 
a=rtcp-fb:102 goog-remb 
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack 
a=rtcp-fb:102 nack pli
a=rtcp-fb:102 transport-cc 
a=rtcp-fb:127 goog-remb 
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack 
a=rtcp-fb:127 nack pli
a=rtcp-fb:127 transport-cc 
a=rtcp-fb:108 goog-remb 
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack 
a=rtcp-fb:108 nack pli
a=rtcp-fb:108 transport-cc 
a=rtcp-fb:123 goog-remb 
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack 
a=rtcp-fb:123 nack pli
a=rtcp-fb:123 transport-cc 
a=rtcp-fb:37 goog-remb 
a=rtcp-fb:37 ccm fir
a=rtcp-fb:37 nack 
a=rtcp-fb:37 nack pli
a=rtcp-fb:37 transport-cc 
a=rtcp-fb:41 goog-remb 
a=rtcp-fb:41 ccm fir
a=rtcp-fb:41 nack 
a=rtcp-fb:41 nack pli
a=rtcp-fb:41 transport-cc 
a=extmap:12 http://www.webrtc.org/experiments/rtp-hdrext/abs-capture-time
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=setup:passive
a=mid:2
a=sendonly
a=ice-ufrag:0f4b10273ed08f42
a=ice-pwd:6feb66ae97ae014aa9544cc0284ce4m=e074a015b675131a0d
a=fingerprint:sha-256 08:17:29:59:24:5F:9E:A6:A1:87:08:90:05:70:3C:39:6E:04:EC:ED:63:D8:6B:B0:65:D4:07:D0:5F:37:B4:35
a=candidate:1 1 udp 2130706431 165.227.54.155 57215 typ host
a=rtcp-mux
a=rtcp-rsize''';

const localSdp ='''v=0
o=- 8302999682125171423 3 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0 1 2
a=extmap-allow-mixed
a=msid-semantic: WMS
m=video 52200 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 125 107 108 109 124 120 123 119 35 36 37 38 39 40 41 42 114 115 116 43
c=IN IP4 186.50.9.10
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:1560499547 1 udp 2113937151 2cf0b2c0-0842-4fe3-aaa0-4556a2dfbadc.local 33192 typ host generation 0 network-cost 999
a=candidate:842163049 1 udp 1677729535 186.50.9.10 52200 typ srflx raddr 0.0.0.0 rport 0 generation 0 network-cost 999
a=candidate:842163049 1 udp 1677729535 186.50.9.10 62793 typ srflx raddr 0.0.0.0 rport 0 generation 0 network-cost 999
a=ice-ufrag:gydc
a=ice-pwd:qEA+KCGezaoGknNYbpAADXBK
a=ice-options:trickle
a=fingerprint:sha-256 03:63:4B:E0:AA:51:4E:82:82:EE:A6:A9:4F:6E:4E:95:72:E5:AE:CD:CB:89:F0:1F:E4:C9:CA:27:02:1F:26:6A
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:toffset
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:5 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay
a=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type
a=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-timing
a=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/color-space
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=recvonly
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 transport-cc
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 transport-cc
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=fmtp:98 profile-id=0
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 VP9/90000
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 transport-cc
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=fmtp:100 profile-id=2
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=rtpmap:102 VP9/90000
a=rtcp-fb:102 goog-remb
a=rtcp-fb:102 transport-cc
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack
a=rtcp-fb:102 nack pli
a=fmtp:102 profile-id=1
a=rtpmap:122 rtx/90000
a=fmtp:122 apt=102
a=rtpmap:127 H264/90000
a=rtcp-fb:127 goog-remb
a=rtcp-fb:127 transport-cc
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack
a=rtcp-fb:127 nack pli
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=rtpmap:121 rtx/90000
a=fmtp:121 apt=127
a=rtpmap:125 H264/90000
a=rtcp-fb:125 goog-remb
a=rtcp-fb:125 transport-cc
a=rtcp-fb:125 ccm fir
a=rtcp-fb:125 nack
a=rtcp-fb:125 nack pli
a=fmtp:125 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42001f
a=rtpmap:107 rtx/90000
a=fmtp:107 apt=125
a=rtpmap:108 H264/90000
a=rtcp-fb:108 goog-remb
a=rtcp-fb:108 transport-cc
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack
a=rtcp-fb:108 nack pli
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:109 rtx/90000
a=fmtp:109 apt=108
a=rtpmap:124 H264/90000
a=rtcp-fb:124 goog-remb
a=rtcp-fb:124 transport-cc
a=rtcp-fb:124 ccm fir
a=rtcp-fb:124 nack
a=rtcp-fb:124 nack pli
a=fmtp:124 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42e01f
a=rtpmap:120 rtx/90000
a=fmtp:120 apt=124
a=rtpmap:123 H264/90000
a=rtcp-fb:123 goog-remb
a=rtcp-fb:123 transport-cc
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack
a=rtcp-fb:123 nack pli
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d001f
a=rtpmap:119 rtx/90000
a=fmtp:119 apt=123
a=rtpmap:35 H264/90000
a=rtcp-fb:35 goog-remb
a=rtcp-fb:35 transport-cc
a=rtcp-fb:35 ccm fir
a=rtcp-fb:35 nack
a=rtcp-fb:35 nack pli
a=fmtp:35 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=4d001f
a=rtpmap:36 rtx/90000
a=fmtp:36 apt=35
a=rtpmap:37 H264/90000
a=rtcp-fb:37 goog-remb
a=rtcp-fb:37 transport-cc
a=rtcp-fb:37 ccm fir
a=rtcp-fb:37 nack
a=rtcp-fb:37 nack pli
a=fmtp:37 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=f4001f
a=rtpmap:38 rtx/90000
a=fmtp:38 apt=37
a=rtpmap:39 H264/90000
a=rtcp-fb:39 goog-remb
a=rtcp-fb:39 transport-cc
a=rtcp-fb:39 ccm fir
a=rtcp-fb:39 nack
a=rtcp-fb:39 nack pli
a=fmtp:39 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=f4001f
a=rtpmap:40 rtx/90000
a=fmtp:40 apt=39
a=rtpmap:41 AV1/90000
a=rtcp-fb:41 goog-remb
a=rtcp-fb:41 transport-cc
a=rtcp-fb:41 ccm fir
a=rtcp-fb:41 nack
a=rtcp-fb:41 nack pli
a=rtpmap:42 rtx/90000
a=fmtp:42 apt=41
a=rtpmap:114 red/90000
a=rtpmap:115 rtx/90000
a=fmtp:115 apt=114
a=rtpmap:116 ulpfec/90000
a=rtpmap:43 flexfec-03/90000
a=rtcp-fb:43 goog-remb
a=rtcp-fb:43 transport-cc
a=fmtp:43 repair-window=10000000
m=audio 57217 UDP/TLS/RTP/SAVPF 111 63 103 104 9 0 8 106 105 13 110 112 113 126 117
c=IN IP4 186.50.9.10
a=rtcp:9 IN IP4 0.0.0.0
a=candidate:1560499547 1 udp 2113937151 2cf0b2c0-0842-4fe3-aaa0-4556a2dfbadc.local 54264 typ host generation 0 network-cost 999
a=candidate:842163049 1 udp 1677729535 186.50.9.10 57217 typ srflx raddr 0.0.0.0 rport 0 generation 0 network-cost 999
a=candidate:842163049 1 udp 1677729535 186.50.9.10 41993 typ srflx raddr 0.0.0.0 rport 0 generation 0 network-cost 999
a=ice-ufrag:gydc
a=ice-pwd:qEA+KCGezaoGknNYbpAADXBK
a=ice-options:trickle
a=fingerprint:sha-256 03:63:4B:E0:AA:51:4E:82:82:EE:A6:A9:4F:6E:4E:95:72:E5:AE:CD:CB:89:F0:1F:E4:C9:CA:27:02:1F:26:6A
a=setup:actpass
a=mid:1
a=extmap:14 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=recvonly
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;stereo=1;useinbandfec=1
a=rtpmap:63 red/48000/2
a=fmtp:63 111/111
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=rtpmap:117 multiopus/48000/6
a=fmtp:117 channel_mapping=0,4,1,2,3,5;coupled_streams=2;minptime=10;num_streams=4;useinbandfec=1
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 125 107 108 109 124 120 123 119 35 36 37 38 39 40 41 42 114 115 116 43
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:gydc
a=ice-pwd:qEA+KCGezaoGknNYbpAADXBK
a=ice-options:trickle
a=fingerprint:sha-256 03:63:4B:E0:AA:51:4E:82:82:EE:A6:A9:4F:6E:4E:95:72:E5:AE:CD:CB:89:F0:1F:E4:C9:CA:27:02:1F:26:6A
a=setup:actpass
a=mid:2
a=extmap:1 urn:ietf:params:rtp-hdrext:toffset
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:5 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay
a=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type
a=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-timing
a=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/color-space
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=recvonly
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 transport-cc
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 transport-cc
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=fmtp:98 profile-id=0
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 VP9/90000
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 transport-cc
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=fmtp:100 profile-id=2
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=rtpmap:102 VP9/90000
a=rtcp-fb:102 goog-remb
a=rtcp-fb:102 transport-cc
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack
a=rtcp-fb:102 nack pli
a=fmtp:102 profile-id=1
a=rtpmap:122 rtx/90000
a=fmtp:122 apt=102
a=rtpmap:127 H264/90000
a=rtcp-fb:127 goog-remb
a=rtcp-fb:127 transport-cc
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack
a=rtcp-fb:127 nack pli
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=rtpmap:121 rtx/90000
a=fmtp:121 apt=127
a=rtpmap:125 H264/90000
a=rtcp-fb:125 goog-remb
a=rtcp-fb:125 transport-cc
a=rtcp-fb:125 ccm fir
a=rtcp-fb:125 nack
a=rtcp-fb:125 nack pli
a=fmtp:125 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42001f
a=rtpmap:107 rtx/90000
a=fmtp:107 apt=125
a=rtpmap:108 H264/90000
a=rtcp-fb:108 goog-remb
a=rtcp-fb:108 transport-cc
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack
a=rtcp-fb:108 nack pli
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:109 rtx/90000
a=fmtp:109 apt=108
a=rtpmap:124 H264/90000
a=rtcp-fb:124 goog-remb
a=rtcp-fb:124 transport-cc
a=rtcp-fb:124 ccm fir
a=rtcp-fb:124 nack
a=rtcp-fb:124 nack pli
a=fmtp:124 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42e01f
a=rtpmap:120 rtx/90000
a=fmtp:120 apt=124
a=rtpmap:123 H264/90000
a=rtcp-fb:123 goog-remb
a=rtcp-fb:123 transport-cc
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack
a=rtcp-fb:123 nack pli
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d001f
a=rtpmap:119 rtx/90000
a=fmtp:119 apt=123
a=rtpmap:35 H264/90000
a=rtcp-fb:35 goog-remb
a=rtcp-fb:35 transport-cc
a=rtcp-fb:35 ccm fir
a=rtcp-fb:35 nack
a=rtcp-fb:35 nack pli
a=fmtp:35 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=4d001f
a=rtpmap:36 rtx/90000
a=fmtp:36 apt=35
a=rtpmap:37 H264/90000
a=rtcp-fb:37 goog-remb
a=rtcp-fb:37 transport-cc
a=rtcp-fb:37 ccm fir
a=rtcp-fb:37 nack
a=rtcp-fb:37 nack pli
a=fmtp:37 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=f4001f
a=rtpmap:38 rtx/90000
a=fmtp:38 apt=37
a=rtpmap:39 H264/90000
a=rtcp-fb:39 goog-remb
a=rtcp-fb:39 transport-cc
a=rtcp-fb:39 ccm fir
a=rtcp-fb:39 nack
a=rtcp-fb:39 nack pli
a=fmtp:39 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=f4001f
a=rtpmap:40 rtx/90000
a=fmtp:40 apt=39
a=rtpmap:41 AV1/90000
a=rtcp-fb:41 goog-remb
a=rtcp-fb:41 transport-cc
a=rtcp-fb:41 ccm fir
a=rtcp-fb:41 nack
a=rtcp-fb:41 nack pli
a=rtpmap:42 rtx/90000
a=fmtp:42 apt=41
a=rtpmap:114 red/90000
a=rtpmap:115 rtx/90000
a=fmtp:115 apt=114
a=rtpmap:116 ulpfec/90000
a=rtpmap:43 flexfec-03/90000
a=rtcp-fb:43 goog-remb
a=rtcp-fb:43 transport-cc
a=fmtp:43 repair-window=10000000
''';

