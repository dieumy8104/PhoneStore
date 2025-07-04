import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phone_store/app_constant.dart';

class PaymentService {
 
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (double.parse(amount).toInt()).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var secretKey = AppConstant.stripeSecretKey;
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      print("✅ Stripe response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("❌ Error creating payment intent: $e");
      return null;
    }
  }
 

}
