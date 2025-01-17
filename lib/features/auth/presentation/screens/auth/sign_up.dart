import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import '../home_screen.dart';
import 'components/text_field.dart';
import '../../../../../data/services/auth_service.dart';
import '../Users/user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();

  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  bool isLoading = false;

  // Password validation flags
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final password = passwordController.text;
    setState(() {
      containsUpperCase = password.contains(RegExp(r'[A-Z]'));
      containsLowerCase = password.contains(RegExp(r'[a-z]'));
      containsNumber = password.contains(RegExp(r'[0-9]'));
      containsSpecialChar =
          password.contains(RegExp(r'[!@#$&*~`%)(_+=;:,.<>/?"{}\[\]\\|^-]'));
      contains8Length = password.length >= 8;
    });
  }
    Future<void> _saveCredentials(String username, String secret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('secret', secret);
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final response = await authService.signUp(
          username: usernameController.text.trim(),
          firstName: nameController.text.trim(),
          lastName: lastNameController.text.trim(),
          secret: passwordController.text.trim(),
          customJson: {'high_score': 2000},
        );

        if (response) {
          final username = usernameController.text.trim();
          final secret = passwordController.text.trim();

          // Save username and secret in SharedPreferences
          await _saveCredentials(username, secret);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UsersScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sign-up failed. Please try again.'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-up failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Username/Email TextField
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(CupertinoIcons.mail_solid),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      }
                      // bool emailValid = RegExp(
                      //         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                      //     .hasMatch(val);
                      // print(
                      //     'Email validation result: $emailValid for email: $val');
                      // if (!emailValid) {
                      //   return 'Please enter a valid email';
                      // }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Password TextField
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: const Icon(CupertinoIcons.lock_fill),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                          iconPassword = obscurePassword
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill;
                        });
                      },
                      icon: Icon(iconPassword),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      }
                      bool passwordValid = containsUpperCase &&
                          containsLowerCase &&
                          containsNumber &&
                          containsSpecialChar &&
                          contains8Length;
                      if (!passwordValid) {
                        return 'Please enter a valid password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Password Requirements
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⚈  1 uppercase",
                            style: TextStyle(
                              color: containsUpperCase
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "⚈  1 lowercase",
                            style: TextStyle(
                              color: containsLowerCase
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "⚈  1 number",
                            style: TextStyle(
                              color: containsNumber
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⚈  1 special character",
                            style: TextStyle(
                              color: containsSpecialChar
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "⚈  8 minimum character",
                            style: TextStyle(
                              color: contains8Length
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // First Name TextField
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MyTextField(
                    controller: nameController,
                    hintText: 'First Name',
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    prefixIcon: const Icon(CupertinoIcons.person_fill),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (val.length > 30) {
                        return 'Name too long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Last Name TextField
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MyTextField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    prefixIcon: const Icon(CupertinoIcons.person),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please fill in this field';
                      } else if (val.length > 30) {
                        return 'Name too long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Sign Up Button
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: TextButton(
                    onPressed: isLoading ? null : _signUp,
                    style: TextButton.styleFrom(
                      elevation: 3.0,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
