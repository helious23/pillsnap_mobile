// TODO: wire real camera
import 'package:flutter/material.dart';
import '../theme.dart';
import '../components/common/pill_app_bar.dart';
import '../components/camera/crosshair_overlay.dart';
import '../components/camera/zoom_selector.dart';
import '../components/camera/flash_toggle.dart';
import '../components/camera/guide_dialog.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  double _currentZoom = 1.0;
  bool _isFlashOn = false;

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => GuideDialog(
        title: '단일 약품 촬영 가이드',
        imagePath: 'assets/10-1.single_camera_info.png',
        checkList: const [
          '약품을 정중앙에 위치시켜주세요',
          '수직으로 촬영해주세요',
          '밝은 조명에서 촬영해주세요',
        ],
        onStart: () {},
      ),
    );
  }

  void _takePicture() {
    // 촬영 후 결과 화면으로 이동
    Navigator.pushNamed(context, '/CAMERA_RESULT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,  // AppBar 뒤로 body 확장
      appBar: PillAppBar(
        title: '단일 약품 촬영',
        showBack: true,
        showInfo: true,
        isDark: true,  // 다크 모드 활성화
        onInfoTap: _showGuide,
        trailing: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: FlashToggle(
            isOn: _isFlashOn,
            onToggle: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2332),
              Color(0xFF0F1621),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 카메라 아이콘 (화면 정중앙)
            Center(
              child: Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            // 십자선 오버레이 (화면 정중앙)
            const Center(
              child: CrosshairOverlay(
                guideText: '약품을 정중앙에 맞춰주세요',
                showCrosshair: true,
              ),
            ),
            // 하단 컨트롤
            Positioned(
              bottom: 40,  // 하단 여백 조정
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 줌 선택기
                  ZoomSelector(
                    currentZoom: _currentZoom,
                    onZoomChanged: (zoom) {
                      setState(() {
                        _currentZoom = zoom;
                      });
                    },
                  ),
                  const SizedBox(height: 40),  // 간격 증가
                  // 셔터 버튼
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}