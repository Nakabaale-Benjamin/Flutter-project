import 'package:flutter/material.dart';

class CustomCheckboxFormField extends StatefulWidget {
  final String label;
  final String hint;
  final bool initialValue;
  final ValueChanged<bool?>? onChanged;

  const CustomCheckboxFormField({
    Key? key,
    required this.label,
    required this.hint,
    required this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomCheckboxFormFieldState createState() => _CustomCheckboxFormFieldState();
}

class _CustomCheckboxFormFieldState extends State<CustomCheckboxFormField> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFedf0f8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
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
                ),
                readOnly: true,
                initialValue: widget.label,
              ),
            ),
            Checkbox(
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value ?? false;
                  if (widget.onChanged != null) {
                    widget.onChanged!(_isChecked);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
