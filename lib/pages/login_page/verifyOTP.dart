import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VerifyOTPPage extends StatefulWidget {
  static String routeName = '/otppage';
  VerifyOTPPage({super.key});

  @override
  State<VerifyOTPPage> createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  bool isVi = false;
  int remainingSeconds = 60;
  Timer? countdownTimer;
  Map<String, dynamic>? data;
  List<TextEditingController> _otpController =
      List.generate(4, (index) => TextEditingController());

  String res() {
    return _otpController.map((controller) => controller.text).join();
  }

  void startCountdown() {
    setState(() {
      isVi = !isVi;
    });
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        setState(() {
          timer.cancel();
          isVi = !isVi;
          remainingSeconds = 60;
        });
      }
    });
  }

  bool isOTPComplete() {
    return _otpController.every((controller) => controller.text.isNotEmpty);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (data == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        data = args;
      } else {
        print("Lỗi: Không có arguments phù hợp");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      data = args;
      if (data != null) {
        EmailOTP.sendOTP(email: data!['email']);
      }
    });
  }
  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
 
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content:
                  Text('A password reset link has been sent to your email.'),
            );
          },
        );
      }
    } catch (e) {
      print("Lỗi gửi email đặt lại mật khẩu: $e");
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                  'Failed to send password reset email. Please try again.'),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    print('${data?['email']}................' );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 88, 123),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                (index) {
                  return Container(
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: _otpController[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          isVi
              ? Text(
                  "Mã OTP sẽ hết hạn trong: $remainingSeconds giây",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : ElevatedButton(
                  onPressed: () async {
                    startCountdown();

                    if (await EmailOTP.sendOTP(email: data?['email'])) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP has been sent")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP failed sent")));
                    }
                  },
                  child: Text("Gửi lại OTP"),
                ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: isOTPComplete()
                ? () async {
                    bool result = await EmailOTP.verifyOTP(otp: res());
                    if (result) {
                      setState(() {
                        isVi = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("OTP hợp lệ!"),
                      ));
                      await resetPassword(data?['email']);
                      await Future.delayed(Duration(seconds: 5), () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("OTP không hợp lệ"),
                        ),
                      );
                    }
                  }
                : null,
            child: Text('Verify'),
          ),
        ],
      ),
    );
  }
}
