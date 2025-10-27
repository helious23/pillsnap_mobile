import Flutter
import AVFoundation
import UIKit

public class MacroCameraPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pillsnap/camera_macro",
                                         binaryMessenger: registrar.messenger())
        let instance = MacroCameraPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "selectMacroCamera":
            selectBestCameraForMacro(result: result)
        case "configureMacroMode":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String {
                configureMacroMode(deviceId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing deviceId", details: nil))
            }
        case "setMacroFocus":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["deviceId"] as? String,
               let x = args["x"] as? Double,
               let y = args["y"] as? Double {
                setMacroFocus(deviceId: deviceId, x: x, y: y, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing parameters", details: nil))
            }
        case "getMacroCapabilities":
            getMacroCapabilities(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func selectBestCameraForMacro(result: @escaping FlutterResult) {
        var bestCamera: [String: Any]?
        var allCameras: [[String: Any]] = []
        
        var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera]
        
        if #available(iOS 13.0, *) {
            deviceTypes.append(.builtInUltraWideCamera)
            deviceTypes.append(.builtInTripleCamera)
        }
        deviceTypes.append(.builtInDualCamera)
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .back
        )
        
        for device in discoverySession.devices {
            var cameraInfo: [String: Any] = [
                "id": device.uniqueID,
                "position": device.position == .back ? "back" : "front",
                "deviceType": deviceTypeString(device.deviceType)
            ]
            
            // 매크로 모드 지원 확인 (iOS 15+)
            if #available(iOS 15.0, *) {
                // iPhone 13 Pro 이상에서 매크로 모드 지원
                let supportsMacro = device.deviceType == .builtInUltraWideCamera && 
                                  device.minimumFocusDistance >= 0
                cameraInfo["supportsMacro"] = supportsMacro
                
                // 최소 포커스 거리 (센티미터로 변환)
                if device.minimumFocusDistance >= 0 {
                    // minimumFocusDistance는 디옵터 단위, 센티미터로 변환
                    let focusDistanceCm = device.minimumFocusDistance > 0 ? 100.0 / Float(device.minimumFocusDistance) : 0
                    cameraInfo["minimumFocusDistance"] = focusDistanceCm
                }
            } else {
                cameraInfo["supportsMacro"] = false
            }
            
            // 줌 범위
            cameraInfo["minZoom"] = device.minAvailableVideoZoomFactor
            cameraInfo["maxZoom"] = device.maxAvailableVideoZoomFactor
            
            // 연속 오토포커스 지원
            cameraInfo["supportsContinuousAutoFocus"] = device.isFocusModeSupported(.continuousAutoFocus)
            
            allCameras.append(cameraInfo)
            
            // 매크로에 가장 적합한 카메라 선택
            // 1순위: Ultra Wide (iPhone 13 Pro 이상)
            // 2순위: Wide 카메라
            if bestCamera == nil {
                if #available(iOS 15.0, *) {
                    if device.deviceType == .builtInUltraWideCamera && device.minimumFocusDistance >= 0 {
                        bestCamera = cameraInfo
                    } else if device.deviceType == .builtInWideAngleCamera && bestCamera == nil {
                        bestCamera = cameraInfo
                    }
                } else {
                    if device.deviceType == .builtInWideAngleCamera {
                        bestCamera = cameraInfo
                    }
                }
            }
        }
        
        result([
            "bestCamera": bestCamera ?? [:],
            "allCameras": allCameras
        ])
    }
    
    private func configureMacroMode(deviceId: String, result: @escaping FlutterResult) {
        guard let device = AVCaptureDevice(uniqueID: deviceId) else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Camera device not found", details: nil))
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            var config: [String: Any] = ["success": true]
            
            // 포커스 모드 설정
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
                config["focusMode"] = "continuousAutoFocus"
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
                config["focusMode"] = "autoFocus"
            }
            
            // 노출 모드 설정
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
                config["exposureMode"] = "continuousAutoExposure"
            }
            
            // 저조도 부스트
            if device.isLowLightBoostSupported {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
                config["lowLightBoost"] = true
            }
            
            // 매크로 모드 전용 설정 (iOS 15+)
            if #available(iOS 15.0, *) {
                // 자동 렌즈 전환 활성화 (iOS 15+ API)
                // virtualDeviceSwitchoverVideoZoomFactors는 iOS 15+에서만 사용 가능
                // 대신 다른 방법으로 매크로 지원 확인
                if device.deviceType == .builtInUltraWideCamera {
                    config["automaticLensSwitching"] = true
                }
            }
            
            device.unlockForConfiguration()
            result(config)
        } catch {
            result(FlutterError(code: "CONFIG_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func setMacroFocus(deviceId: String, x: Double, y: Double, result: @escaping FlutterResult) {
        guard let device = AVCaptureDevice(uniqueID: deviceId) else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Camera device not found", details: nil))
            return
        }
        
        let focusPoint = CGPoint(x: x, y: y)
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            result(["success": true])
        } catch {
            result(FlutterError(code: "FOCUS_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func getMacroCapabilities(result: @escaping FlutterResult) {
        var capabilities: [String: Any] = [:]
        
        // 디바이스 모델
        capabilities["deviceModel"] = UIDevice.current.model
        
        // iOS 버전
        capabilities["iOSVersion"] = UIDevice.current.systemVersion
        
        // 매크로 모드 지원 확인
        var supportsMacro = false
        var minFocusDistance: Float?
        
        if #available(iOS 15.0, *) {
            var ultraWideTypes: [AVCaptureDevice.DeviceType] = []
            if #available(iOS 13.0, *) {
                ultraWideTypes.append(.builtInUltraWideCamera)
            }
            
            if !ultraWideTypes.isEmpty {
                let discoverySession = AVCaptureDevice.DiscoverySession(
                    deviceTypes: ultraWideTypes,
                    mediaType: .video,
                    position: .back
                )
            
                if let ultraWide = discoverySession.devices.first {
                    supportsMacro = ultraWide.minimumFocusDistance >= 0
                    if ultraWide.minimumFocusDistance > 0 {
                        minFocusDistance = 100.0 / Float(ultraWide.minimumFocusDistance)
                    }
                }
            }
        }
        
        capabilities["supportsMacroMode"] = supportsMacro
        capabilities["minimumFocusDistance"] = minFocusDistance
        
        // ProRAW 지원
        if #available(iOS 14.3, *) {
            capabilities["supportsProRAW"] = AVCapturePhotoOutput().isAppleProRAWSupported
        } else {
            capabilities["supportsProRAW"] = false
        }
        
        result(capabilities)
    }
    
    private func deviceTypeString(_ deviceType: AVCaptureDevice.DeviceType) -> String {
        if deviceType == .builtInWideAngleCamera {
            return "wide"
        } else if deviceType == .builtInTelephotoCamera {
            return "telephoto"
        } else if deviceType == .builtInDualCamera {
            return "dual"
        }
        
        if #available(iOS 13.0, *) {
            if deviceType == .builtInUltraWideCamera {
                return "ultraWide"
            } else if deviceType == .builtInTripleCamera {
                return "triple"
            }
        }
        
        return "unknown"
    }
}
