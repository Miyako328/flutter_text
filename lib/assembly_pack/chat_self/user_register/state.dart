import 'package:flutter/material.dart';

class UserRegisterState {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserRegisterState();
}
