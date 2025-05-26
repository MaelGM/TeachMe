import 'package:flutter/material.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/ui/input_decorations.dart';
import 'package:teachme/utils/utils.dart';

class PaymentPage extends StatefulWidget {
  static final routeName = 'pay';
  final double amount;
  final String courseTitle;

  const PaymentPage({Key? key, required this.amount, required this.courseTitle})
    : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndPay() async {
    final cardHolder = _cardHolderController.text.trim();
    final cardNumber = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvc = _cvcController.text.trim();

    if (cardHolder.isEmpty ||
        cardNumber.isEmpty ||
        expiry.isEmpty ||
        cvc.isEmpty) {
      ScaffoldMessageError("Todos los campos son obligatorios.", context);
      return;
    }

    if (cardNumber.length != 16) {
      ScaffoldMessageError(
        "El número de tarjeta debe tener 16 dígitos.",
        context,
      );
      return;
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
      ScaffoldMessageError(
        "Fecha de expiración inválida. Usa el formato MM/AA.",
        context,
      );
      return;
    }

    if (cvc.length != 3) {
      ScaffoldMessageError("El CVC debe tener 3 dígitos.", context);
      return;
    }

    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Color(0xFF1A1A1A),
            title: Text(
              "Confirmar pago",
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              "¿Quieres pagar ${widget.amount.toStringAsFixed(2)} € por '${widget.courseTitle}'?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancela
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await CourseService.payCourse(widget.amount);
                  ScaffoldMessageInfo(
                    "Has pagado ${widget.amount.toStringAsFixed(2)} € por '${widget.courseTitle}'",
                    context,
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  "Confirmar",
                  style: TextStyle(color: Color(0xFF3B82F6)),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            backgroundColor: Color(0xFF1E1E1E),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
                SizedBox(width: 10),
                Text("Pago exitoso", style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              "Has pagado ${widget.amount.toStringAsFixed(2)} € por '${widget.courseTitle}'.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text("Aceptar", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: false,
      maxLength: maxLength,
      style: TextStyle(color: Colors.white),
      keyboardType: type,
      decoration: InputDecorations.authInputDecorationBorderFull(
        labelText: label,
        hintText: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pagar curso")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(),
              SizedBox(height: 10),
              _price(),
              SizedBox(height: 31),
              _inputField(
                label: "Titular de la tarjeta",
                controller: _cardHolderController,
              ),
              SizedBox(height: 28),
              _inputField(
                label: "Número de tarjeta",
                controller: _cardNumberController,
                type: TextInputType.number,
                maxLength: 16,
              ),
              SizedBox(height: 15),
              _cvcExpiration(),
              SizedBox(height: 30),
              _payButton(),
            ],
          ),
        ),
      ),
    );
  }

  Row _cvcExpiration() {
    return Row(
      children: [
        Expanded(
          child: _inputField(
            label: "Expiración (MM/AA)",
            controller: _expiryController,
            maxLength: 5,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _inputField(
            label: "CVC",
            controller: _cvcController,
            maxLength: 3,
            type: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Text _price() {
    return Text(
      "${widget.amount.toStringAsFixed(2)} €",
      style: TextStyle(fontSize: 18, color: Colors.greenAccent),
    );
  }

  Text _title() {
    return Text(
      widget.courseTitle,
      style: TextStyle(fontSize: 22, color: Colors.white),
    );
  }

  TextButton _payButton() {
    return TextButton(
      onPressed: _isProcessing ? null : _confirmAndPay,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isProcessing ? Colors.grey : Color(0xFF3B82F6),
        ),
        child: Center(
          child:
              _isProcessing
                  ? CircularProgressIndicator()
                  : Text(
                    'Pagar ${widget.amount.toStringAsFixed(0)} €',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
        ),
      ),
    );
  }
}
