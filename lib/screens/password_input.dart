import 'package:flutter/material.dart';
import '../theme.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController _pw = TextEditingController();
  final TextEditingController _pw2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비밀번호 설정',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _pw,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pw2,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/ONBOARDING_FIRST',
                  ),
                  child: const Text(
                    '완료',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '영문/숫자 포함 8자 이상 권장',
                style: AppTextStyles.bodySecondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
