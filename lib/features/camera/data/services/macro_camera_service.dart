import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS 네이티브 매크로 카메라 서비스
class MacroCameraService {
  static const MethodChannel _channel = MethodChannel('pillsnap/camera_macro');
  
  /// 싱글톤 인스턴스
  static final MacroCameraService _instance = MacroCameraService._internal();
  factory MacroCameraService() => _instance;
  MacroCameraService._internal();
  
  /// 근접 촬영에 최적화된 카메라 선택
  Future<MacroCameraInfo?> selectBestCameraForMacro() async {
    if (!Platform.isIOS) {
      debugPrint('[MacroCamera] Not iOS, skipping native macro selection');
      return null;
    }
    
    try {
      final result = await _channel.invokeMethod('selectMacroCamera');
      final bestCamera = result['bestCamera'] as Map<dynamic, dynamic>?;
      final allCameras = result['allCameras'] as List<dynamic>?;
      
      if (bestCamera != null && bestCamera.isNotEmpty) {
        debugPrint('[MacroCamera] Best camera selected: ${bestCamera['id']}');
        debugPrint('[MacroCamera] Supports macro: ${bestCamera['supportsMacro']}');
        debugPrint('[MacroCamera] Min focus distance: ${bestCamera['minimumFocusDistance']}cm');
        
        return MacroCameraInfo(
          deviceId: bestCamera['id'] as String,
          supportsMacro: bestCamera['supportsMacro'] as bool? ?? false,
          minimumFocusDistance: (bestCamera['minimumFocusDistance'] as num?)?.toDouble(),
          maxZoom: (bestCamera['maxZoom'] as num?)?.toDouble() ?? 1.0,
          supportsContinuousAutoFocus: bestCamera['supportsContinuousAutoFocus'] as bool? ?? false,
        );
      }
      
      debugPrint('[MacroCamera] Available cameras: ${allCameras?.length ?? 0}');
      return null;
    } catch (e) {
      debugPrint('[MacroCamera] Error selecting macro camera: $e');
      return null;
    }
  }
  
  /// 매크로 모드 설정
  Future<bool> configureMacroMode(String deviceId) async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _channel.invokeMethod('configureMacroMode', {
        'deviceId': deviceId,
      });
      
      debugPrint('[MacroCamera] Macro mode configured:');
      debugPrint('  - Focus mode: ${result['focusMode']}');
      debugPrint('  - Exposure mode: ${result['exposureMode']}');
      debugPrint('  - Low light boost: ${result['lowLightBoost']}');
      
      return result['success'] as bool? ?? false;
    } catch (e) {
      debugPrint('[MacroCamera] Error configuring macro mode: $e');
      return false;
    }
  }
  
  /// 매크로 포커스 설정
  Future<bool> setMacroFocus(String deviceId, double x, double y) async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _channel.invokeMethod('setMacroFocus', {
        'deviceId': deviceId,
        'x': x,
        'y': y,
      });
      
      debugPrint('[MacroCamera] Focus set to ($x, $y)');
      return result['success'] as bool? ?? false;
    } catch (e) {
      debugPrint('[MacroCamera] Error setting macro focus: $e');
      return false;
    }
  }
  
  /// 디바이스 매크로 기능 확인
  Future<MacroCapabilities> getMacroCapabilities() async {
    if (!Platform.isIOS) {
      return MacroCapabilities(
        deviceModel: 'Android',
        iOSVersion: null,
        supportsMacroMode: false,
        supportsProRAW: false,
        minimumFocusDistance: null,
      );
    }
    
    try {
      final result = await _channel.invokeMethod('getMacroCapabilities');
      
      return MacroCapabilities(
        deviceModel: result['deviceModel'] as String? ?? 'Unknown',
        iOSVersion: result['iOSVersion'] as String?,
        supportsMacroMode: result['supportsMacroMode'] as bool? ?? false,
        supportsProRAW: result['supportsProRAW'] as bool? ?? false,
        minimumFocusDistance: (result['minimumFocusDistance'] as num?)?.toDouble(),
      );
    } catch (e) {
      debugPrint('[MacroCamera] Error getting capabilities: $e');
      return MacroCapabilities(
        deviceModel: 'Unknown',
        iOSVersion: null,
        supportsMacroMode: false,
        supportsProRAW: false,
        minimumFocusDistance: null,
      );
    }
  }
  
  /// 디바이스가 매크로를 지원하는지 확인
  Future<bool> isMacroSupported() async {
    final capabilities = await getMacroCapabilities();
    return capabilities.supportsMacroMode;
  }
}

/// 매크로 카메라 정보
class MacroCameraInfo {
  final String deviceId;
  final bool supportsMacro;
  final double? minimumFocusDistance; // 센티미터 단위
  final double maxZoom;
  final bool supportsContinuousAutoFocus;
  
  MacroCameraInfo({
    required this.deviceId,
    required this.supportsMacro,
    this.minimumFocusDistance,
    required this.maxZoom,
    required this.supportsContinuousAutoFocus,
  });
  
  bool get isIdealForMacro => supportsMacro || (minimumFocusDistance != null && minimumFocusDistance! <= 15);
}

/// 매크로 기능 정보
class MacroCapabilities {
  final String deviceModel;
  final String? iOSVersion;
  final bool supportsMacroMode;
  final bool supportsProRAW;
  final double? minimumFocusDistance;
  
  MacroCapabilities({
    required this.deviceModel,
    this.iOSVersion,
    required this.supportsMacroMode,
    required this.supportsProRAW,
    this.minimumFocusDistance,
  });
  
  /// iPhone 13 Pro 이상인지 확인
  bool get isIPhone13ProOrLater {
    if (!deviceModel.contains('iPhone')) return false;
    
    // iPhone 13 Pro, iPhone 14 Pro, iPhone 15 Pro 등
    return deviceModel.contains('Pro') && 
           (deviceModel.contains('13') || 
            deviceModel.contains('14') || 
            deviceModel.contains('15') ||
            deviceModel.contains('16'));
  }
}