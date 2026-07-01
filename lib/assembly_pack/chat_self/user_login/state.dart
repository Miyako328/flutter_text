import 'package:flutter/material.dart';

class UserLoginState {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserLoginState();
}
