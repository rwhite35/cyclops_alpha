///
///  Connected.swift
///  CyclOps
///
/// AVViewModel doesn't create a capture device directly, but instead, retrieves
/// an exiting one using AVCaptureDevice.DiscoverySession method. This object
/// provides the container and configuration for the target capture device.
/// optional modes include focus, exposure, zoom, etc.
///
/// NOTE: in order to change configurations, the device must support the mode,
/// and the app must be able to call `(lock|unlock)ForConfiguration( )`
/// on the target device.
///
/// - uses device camera as the default source when no additional devices are available.
/// - depends on UserNotifications.Store.Center (aka CentralNotificationCenter)
///
/// (AVCaptureDevice)[https://developer.apple.com/documentation/avfoundation/avcapturedevice]
///
///  Created by Ron White on 6/13/24.
///
import Foundation
import AVFoundation

class Connected {
    let TAG = "Connected"
    init(){}
}
