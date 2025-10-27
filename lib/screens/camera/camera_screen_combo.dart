// TODO: wire real camera
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../components/common/pill_app_bar.dart';
import '../../components/camera/crosshair_overlay.dart';
import '../../components/camera/zoom_selector.dart';
import '../../components/camera/flash_toggle.dart';
import '../../components/camera/guide_dialog.dart';

class CameraScreenCombo extends StatefulWidget {
  const CameraScreenCombo({super.key});

  @override
  State<CameraScreenCombo> createState() => _CameraScreenComboState();
}

class _CameraScreenComboState extends State<CameraScreenCombo> {
  double _currentZoom = 1.0;
  bool _isFlashOn = false;

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) => GuideDialog(
        title: '여러 약품 촬영 가이드',
        imagePath: 'assets/10-2.combination_camera_info.png',
        checkList: const [
          '최대 4개까지 촬영 가능합니다',
          '약품 간격을 충분히 띄워주세요',
          '참고용으로만 활용해주세요',
        ],
        onStart: () {},
      ),
    );
  }

  void _takePicture() {
    // 촬영 후 로딩 화면으로 이동
    Navigator.pushNamed(context, '/CAMERA_INFO');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,  // AppBar 뒤로 body 확장
      appBar: PillAppBar(
        title: '여러 약품 촬영',
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
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            // 십자선 오버레이 (십자선 없이, 화면 정중앙)
            const Center(
              child: CrosshairOverlay(
                guideText: '4개 이하, 약품 간격을 띄워 촬영하세요',
                showCrosshair: false,
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