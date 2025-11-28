import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/centered_card.dart';
import 'reset_with_token_page.dart';

class ForgotAndVerifyPage extends StatefulWidget {
  const ForgotAndVerifyPage({super.key});

  @override
  State<ForgotAndVerifyPage> createState() => _ForgotAndVerifyPageState();
}

class _ForgotAndVerifyPageState extends State<ForgotAndVerifyPage> {
  final _mobileCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _otpSent = false;
  bool _sending = false;
  bool _verifying = false;

  String? _error;
  String? _message;

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _error = null;
      _message = null;
    });

    final mobile = _mobileCtrl.text.trim();
    if (mobile.isEmpty) {
      setState(() {
        _sending = false;
        _error = "Enter mobile number";
      });
      return;
    }

    final resp = await ApiService.forgotPasswordSms(mobile);

    setState(() {
      _sending = false;
      if (resp['success']) {
        _otpSent = true;
        _message = resp['message'] ?? "OTP sent!";
      } else {
        _error = resp['message'] ?? "Failed to send OTP";
      }
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _verifying = true;
      _error = null;
    });

    final mobile = _mobileCtrl.text.trim();
    final otp = _otpCtrl.text.trim();

    if (otp.isEmpty) {
      setState(() {
        _verifying = false;
        _error = "Enter OTP";
      });
      return;
    }

    final resp = await ApiService.verifyOtp(mobile, otp);

    setState(() {
      _verifying = false;
    });

    if (resp['success'] == true) {
      final token = resp['resetToken'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetWithTokenPage(resetToken: token),
        ),
      );
    } else {
      setState(() {
        _error = resp['message'] ?? "Invalid OTP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 900 ? 540.0 : 420.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: CenteredCard(
        maxWidth: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Reset your password",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // MOBILE FIELD
            TextField(
              controller: _mobileCtrl,
              enabled: !_otpSent,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),

            if (!_otpSent)
              SizedBox(
                width: double.infinity,
                child: _sending
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _sendOtp,
                        child: const Text("Send OTP"),
                      ),
              ),

            if (_otpSent) ...[
              if (_message != null)
                Text(_message!, style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 12),

              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: _verifying
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _verifyOtp,
                        child: const Text("Verify OTP"),
                      ),
              ),

              TextButton(
                onPressed: _sendOtp,
                child: const Text("Resend OTP"),
              )
            ],

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
