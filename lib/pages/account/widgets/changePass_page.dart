import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/pages/login_page/register_page.dart';
import 'package:phone_store/pages/login_page/verifyOTP.dart';

class ChangepassPage extends StatefulWidget {
  static String routeName = '/changePass_page';

  ChangepassPage({
    super.key,
  });

  @override
  State<ChangepassPage> createState() => _ChangepassPageState();
}

class _ChangepassPageState extends State<ChangepassPage> {
  bool isSee1 = true;
  bool isSee2 = true;
  bool isSee3 = true;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _passController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
  }

  Future<void> updateUserPassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await user.reload();
        print("Password updated successfully!");
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Update Password Successful!'),
              );
            },
          );
        }
      } catch (e) {
        print("Failed to update password: $e");
      }
    }
  }

  Future<bool> verifyPassword(String email, String password, String newPassword,
      String confirmPass) async {
    try {
      // Lấy user hiện tại
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User chưa đăng nhập");
        return false;
      }

      // Xác thực lại user với mật khẩu nhập vào
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      print("Mật khẩu đúng!");

      if (password == newPassword) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Vui lòng đặt khẩu khác mật khẩu cũ!'),
            );
          },
        );
      } else if (newPassword != confirmPass) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Vui lòng nhập đúng mật khẩu xác nhận!'),
            );
          },
        );
      } else {
        await updateUserPassword(newPassword);
        await Future.delayed(Duration(seconds: 4));
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
      return true;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password. Please try again!'),
          );
        },
      );
      print("Mật khẩu sai hoặc có lỗi: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            RegisterForm(
              inputController: _passController,
              hintText: 'Password',
              message: 'Enter your password',
              obscureText: isSee1,
              suffix: IconButton(
                icon: isSee1
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.remove_red_eye),
                onPressed: () {
                  setState(
                    () {
                      isSee1 = !isSee1;
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RegisterForm(
              inputController: _newPassController,
              obscureText: isSee2,
              hintText: 'New Password',
              message: 'Enter your new password',
              suffix: IconButton(
                icon: isSee2
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.remove_red_eye),
                onPressed: () {
                  setState(
                    () {
                      isSee2 = !isSee2;
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RegisterForm(
              inputController: _confirmPassController,
              obscureText: isSee3,
              hintText: 'Confirm New Password',
              message: 'Enter your confirm new password',
              suffix: IconButton(
                icon: isSee2
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.remove_red_eye),
                onPressed: () {
                  setState(
                    () {
                      isSee3 = !isSee3;
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.pushNamed(
                  context,
                  VerifyOTPPage.routeName,
                  arguments: {
                    "email": data['email'],
                  },
                );
              },
              child: Text(
                'Forgot Password ?',
                style: TextStyle(
                  color: Colors.blue[500],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  verifyPassword(
                    data['email'],
                    _passController.text.trim(),
                    _newPassController.text.trim(),
                    _confirmPassController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 211, 88, 123),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Đổi mật khẩu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
