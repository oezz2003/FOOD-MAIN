import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants.dart';

class CustomField extends ConsumerWidget {
  CustomField({
    required this.controller,
    this.hint,
    this.testKey,
    this.label,
    this.width,
    this.scroller,
    this.enabled,
    this.secure,
    this.icon,
    this.action,
    this.inputType,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.required,
    this.textAlign,
    this.focusNode,
    this.inputFormatters,
    this.maxLines,
  });

  final String? label;
  final String? hint;
  final String? testKey;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final double? width;
  final Widget? icon;
  final Widget? action;
  final TextAlign? textAlign;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? secure;
  final bool? enabled;
  final bool? required;
  final int? maxLines;
  final ScrollController? scroller;
  final showPass = StateProvider((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showPassVal = ref.watch(showPass);
    
    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        enabled: enabled ?? true,
        focusNode: focusNode,
        textAlign: textAlign ?? TextAlign.start,
        key: testKey == null ? null : Key(testKey!),
        obscureText: secure == true && !showPassVal,
        controller: controller,
        maxLines: maxLines ?? 1,
        keyboardType: inputType,
        validator: validator,
        onTap: () {
          if (scroller != null) {
            scroller?.animateTo(
              scroller!.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          }
        },
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          hintText: hint == null ? null : (hint! + (required == true ? " *" : "")),
          prefixIcon: icon != null 
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: icon,
              )
            : null,
          suffixIcon: secure == true
            ? IconButton(
                onPressed: () {
                  ref.read(showPass.notifier).state = !showPassVal;
                },
                icon: Icon(
                  showPassVal ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                  size: 20,
                ),
              )
            : action,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintStyle: TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
