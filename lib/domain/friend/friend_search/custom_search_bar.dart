import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.formKey,
    required this.onQueryTyped,
    this.initialValue,
  });

  final GlobalKey<FormState> formKey;
  final Function(String value) onQueryTyped;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        decoration: const InputDecoration(
          label: Text('Search by Username'),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: Icon(
            Icons.search,
          ),
          counterText: '',
        ),
        initialValue: initialValue,
        maxLength: 16,
        onChanged: onQueryTyped,
      ),
    );
  }
}
