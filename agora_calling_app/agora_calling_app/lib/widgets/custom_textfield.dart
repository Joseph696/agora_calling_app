import 'package:agora_calling_app/utils/constants.dart';

import 'package:flutter/material.dart';

class CustomTextField
    extends StatelessWidget {

  final TextEditingController
      controller;

  final String hintText;

  final bool obscureText;

  final String? Function(
    String?,
  )? validator;

  const CustomTextField({

    super.key,

    required this.controller,

    required this.hintText,

    this.obscureText = false,

    this.validator,
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(

      style: const TextStyle(
        color: AppColors.white,
      ),

      controller: controller,

      obscureText: obscureText,

      validator: validator,

      decoration: InputDecoration(

        hintText: hintText,

        hintStyle: const TextStyle(
          color: Colors.grey,
        ),

        filled: true,

        fillColor:
            const Color(
          0xff1E293B,
        ),

        contentPadding:
            const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 18,
        ),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              BorderSide(

            color:
                Colors.white
                    .withOpacity(
              0.05,
            ),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(

            color:
                Color(
              0xff4F46E5,
            ),

            width: 1.5,
          ),
        ),

        errorBorder:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(

            color:
                Colors.red,
          ),
        ),
      ),
    );
  }
}