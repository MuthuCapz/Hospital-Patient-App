import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(PaymentMethodsApp());
}

class PaymentMethodsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentMethodsScreen(),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedPaymentMethod = 'Google Pay';

  // UPI details
  final String _upiID = "9845779437.ibz@icici"; // Replace with the UPI ID
  final String _payeeName = "Fishfy"; // Replace with the payee name
  final String _transactionNote =
      "Payment Note"; // Replace with a transaction note
  final double _amount = 1.00; // Example amount

  // Google Pay package name
  final String _googlePayPackageName = "com.google.android.apps.nbu.paisa.user";

  // Method to open the UPI app based on the selected payment method
  void _openPaymentApp() async {
    String upiUrl =
        "upi://pay?pa=$_upiID&pn=${Uri.encodeComponent(_payeeName)}&tn=${Uri.encodeComponent(_transactionNote)}&am=${_amount.toStringAsFixed(2)}&cu=INR";

    print(upiUrl); // Debugging the UPI URL

    if (_selectedPaymentMethod == 'Google Pay') {
      if (await canLaunch(upiUrl)) {
        try {
          await launch(
            upiUrl,
            forceSafariVC: false,
            forceWebView: false,
            universalLinksOnly: false,
          );
        } catch (e) {
          print("Error launching UPI payment: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error initiating payment. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Pay app is not installed.')),
        );
      }
    } else {
      // Handle other UPI apps (PhonePe, Paytm)
      switch (_selectedPaymentMethod) {
        case 'PhonePe':
          upiUrl =
              "phonepe://pay?pa=$_upiID&pn=${Uri.encodeComponent(_payeeName)}&tn=${Uri.encodeComponent(_transactionNote)}&am=${_amount.toStringAsFixed(2)}&cu=INR";
          break;
        case 'Paytm':
          upiUrl =
              "paytmmp://pay?pa=$_upiID&pn=${Uri.encodeComponent(_payeeName)}&tn=${Uri.encodeComponent(_transactionNote)}&am=${_amount.toStringAsFixed(2)}&cu=INR";
          break;
        default:
          return;
      }

      if (await canLaunch(upiUrl)) {
        await launch(upiUrl, forceSafariVC: false, forceWebView: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unable to open $_selectedPaymentMethod app.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            RadioListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/google_pay.png', width: 30),
                  SizedBox(width: 10),
                  Text('Google Pay'),
                ],
              ),
              value: 'Google Pay',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              activeColor: Colors.blue,
            ),
            RadioListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/phonepe.png', width: 30),
                  SizedBox(width: 10),
                  Text('PhonePe'),
                ],
              ),
              value: 'PhonePe',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              activeColor: Colors.blue,
            ),
            RadioListTile(
              title: Row(
                children: [
                  Image.asset('assets/images/paytm.png', width: 30),
                  SizedBox(width: 10),
                  Text('Paytm'),
                ],
              ),
              value: 'Paytm',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value.toString();
                });
              },
              activeColor: Colors.blue,
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openPaymentApp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Make Payment',
                    style: TextStyle(fontSize: 16),
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
