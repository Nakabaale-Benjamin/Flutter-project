import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final IconData? icon;
  final bool isPassword;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.icon,
    this.isPassword = false,
    this.readOnly = false,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54) : null,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword ? _obscureText : false,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        validator: widget.validator,
      ),
    );
  }
}
