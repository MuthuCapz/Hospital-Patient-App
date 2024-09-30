import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

import 'payment_success_screen.dart';

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
  final String _upiID = "9845779437.ibz@icici"; // Replace with the UPI ID
  final String _payeeName = "Fishfy"; // Replace with the payee name
  String _transactionNote = "Payment Note"; // Replace with a transaction note
  double _amount = 1.00; // Set ₹1 for the transaction

  UpiIndia _upiIndia = UpiIndia();
  Future<UpiResponse>? _transaction;

  // Initiating a UPI transaction
  String _generateUniqueTransactionRefId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<UpiResponse> initiateTransaction() async {
    return await _upiIndia.startTransaction(
      app: _selectedUpiApp(),
      receiverUpiId: _upiID,
      receiverName: _payeeName,
      transactionRefId: _generateUniqueTransactionRefId(),
      transactionNote: _transactionNote,
      amount: _amount,
    );
  }

  UpiApp _selectedUpiApp() {
    switch (_selectedPaymentMethod) {
      case 'Google Pay':
        return UpiApp.googlePay;
      case 'PhonePe':
        return UpiApp.phonePe;
      case 'Paytm':
        return UpiApp.paytm;
      default:
        return UpiApp.googlePay; // Default app
    }
  }

  void _makePayment() {
    if (_selectedUpiApp() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a UPI app")),
      );
    } else {
      setState(() {
        _transaction = initiateTransaction();
      });
    }
  }

  void checkInstalledUpiApps() async {
    List<UpiApp>? apps = await _upiIndia.getAllUpiApps();
    if (apps == null || apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No UPI apps found. Please install a UPI app.")),
      );
    }
  }

  // Display the result of the UPI transaction
  Widget _displayUpiResponse(UpiResponse response) {
    String txnStatus = response.status ?? "Unknown";

    // Navigate to PaymentSuccessScreen regardless of failure or success
    Future.microtask(() {
      if (txnStatus == UpiPaymentStatus.SUCCESS ||
          txnStatus == UpiPaymentStatus.FAILURE ||
          txnStatus == UpiPaymentStatus.SUBMITTED) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(),
          ),
        );
      }
    });

    if (txnStatus == UpiPaymentStatus.SUCCESS) {
      return Column(
        children: [
          Text('Transaction Successful!'),
          Text('Transaction ID: ${response.transactionId}'),
        ],
      );
    } else if (txnStatus == UpiPaymentStatus.FAILURE) {
      return Column(
        children: [
          Text('Transaction Failed. Please try again.'),
          Text(''),
        ],
      );
    } else if (txnStatus == UpiPaymentStatus.SUBMITTED) {
      return Column(
        children: [
          Text('Transaction Submitted. Please wait for confirmation.'),
          Text('Transaction ID: ${response.transactionId}'),
        ],
      );
    } else {
      return Text('Unknown Transaction Status: $txnStatus');
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
        padding: const EdgeInsets.all(20.0),
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
                  onPressed: _makePayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    backgroundColor: Color(0xFF0000FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Make Payment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            FutureBuilder<UpiResponse>(
              future: _transaction,
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Processing transaction...");
                } else if (snapshot.hasError) {
                  return Text("");
                } else if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return Text("No response received. Try again.");
                  } else {
                    return _displayUpiResponse(snapshot.data!);
                  }
                } else {
                  return Text("");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}