#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AudioManager.h"
#import "AudioProcessingAdapter.h"
#import "AudioUtils.h"
#import "CameraUtils.h"
#import "FlutterRPScreenRecorder.h"
#import "FlutterRTCDataChannel.h"
#import "FlutterRTCDesktopCapturer.h"
#import "FlutterRTCFrameCapturer.h"
#import "FlutterRTCFrameCryptor.h"
#import "FlutterRTCMediaStream.h"
#import "FlutterRTCPeerConnection.h"
#import "FlutterRTCVideoRenderer.h"
#import "FlutterWebRTCPlugin.h"
#import "LocalAudioTrack.h"
#import "LocalTrack.h"
#import "LocalVideoTrack.h"
#import "VideoProcessingAdapter.h"

FOUNDATION_EXPORT double flutter_webrtcVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_webrtcVersionString[];

