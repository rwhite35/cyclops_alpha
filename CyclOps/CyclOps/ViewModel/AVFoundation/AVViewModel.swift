//
//  AVViewModel.swift
//  CyclOps
//
//  Created by Ron White on 6/12/24.
//

import AVFoundation
import CoreImage

class AVViewModel: NSObject, ObservableObject {
    
    let TAG = "AVViewModel"
    @Published var frame: CGImage?
    
    /// AVCaptureSession ( captureSession )
    private var permissionGranted = true
    private var defaultDevicePosition: AVCaptureDevice.Position = .unspecified
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    
    override init() {
        super.init()
        self.checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }

    // - MARK: Permission workflow
    ///
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.permissionGranted = true
                
            case .notDetermined: // The user has not yet been asked for camera access.
                self.requestPermission()
                
        // Combine the two other cases into the default case
        default:
            self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    
    // - MARK: Camera Connection
    ///
    /// connect to discoverable camera, device camera is always defaulit.
    /// options by device and media type, and position
    /// - Parameter AVCaptureDevice.Position defaults to .back, but can .front or .unspecified
    ///
    func setDeviceByDiscovery(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera]
        if #available(iOS 17, *) { deviceTypes.append(.external) }
        print("\(TAG).setDeviceByDiscovery :\(#line) discovering device types: \(deviceTypes)")

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            let deviceDiscoverSession = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTypes,
                mediaType: .video,
                position: .unspecified
            )
            for device in deviceDiscoverSession.devices {
                print("FrameHandler :\(#line) check position \(position) for camera \(device)")
                /// returns the matched position passed at runtime
                if device.position == position { return device }
            }
        /// re-request camera permission
        } else { self.requestPermission() }
        return nil
    }
    
    
    /// called on initializer, creates the session and queue
    /// Note: if camera permission wasn't granted by now, return an empty screen.
    ///
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        guard permissionGranted else { return }
        /// set the camera
        var videoDevice =  setDeviceByDiscovery(position: defaultDevicePosition)
        if videoDevice == nil { /// fallback to device back camera
            videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back)
        }
        print("\(TAG).setupCaptureSession :\(#line) new videoDevice added \(String(describing: videoDevice))")

        /// the actual camera
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!) else { return }

        /// the session video input
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)

        /// the session sample buffer delegate
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)

        /// connection to the video output (screen)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
}

extension AVViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        /// a new frame from imageFromSampleBuffer CMSampleBufferGetImageBuffer
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        /// CMSampleBuffer Image passed into CGImage object and sent.
        /// UI updates must be performed on the main queue.
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didDrop sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        print("AVViewModel.didDrop notified, dropped \(sampleBuffer.numSamples) frames.")
    }
    
    /// CIImage is CoreImage object
    ///
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return cgImage
    }
}
