
import 'package:flutter/material.dart';
import 'package:phone_store/pages/login_page/verifyOTP.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 88, 123),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email and we will send you OTP!',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 249, 242, 245),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail_outlined),
                  border: InputBorder.none,
                  hintText: "Write your email!",
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.only(top: 13),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            MaterialButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      if (_emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter your email'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        setState(() => _isLoading = false);
                        return;
                      }
                      Navigator.pushNamed(context, VerifyOTPPage.routeName,
                          arguments: {"email": _emailController.text.trim()});
                      setState(() => _isLoading = false);
                    },
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Send OTP'),
              color: Color.fromARGB(255, 211, 88, 123),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
