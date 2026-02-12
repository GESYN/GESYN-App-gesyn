import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user_store.dart';
import '../widgets/gs_modal.dart';
import '../widgets/app_drawer.dart';
import '../routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _nationality = TextEditingController();
  final _document = TextEditingController();
  final _address = TextEditingController();
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _username,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _password,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _firstName,
              decoration: InputDecoration(labelText: 'First name'),
            ),
            TextField(
              controller: _lastName,
              decoration: InputDecoration(labelText: 'Last name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nationality,
              decoration: InputDecoration(labelText: 'Nationality'),
            ),
            TextField(
              controller: _document,
              decoration: InputDecoration(labelText: 'Document'),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // show terms dialog
                      final raw = await DefaultAssetBundle.of(
                        context,
                      ).loadString('assets/terms/terms.html');
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Terms of use'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: SingleChildScrollView(child: Text(raw)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'I accept the Terms of Use (tap to read)',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: userStore.loading
                  ? null
                  : () async {
                      if (!_acceptedTerms) {
                        await GsModal(
                          parentContext: context,
                          text: 'You must accept the terms of use to register',
                          type: GsModalType.warning,
                        ).show();
                        return;
                      }
                      final body = {
                        'email': _email.text.trim(),
                        'username': _username.text.trim(),
                        'password': _password.text,
                        'firstName': _firstName.text.trim(),
                        'lastName': _lastName.text.trim(),
                        'nationality': _nationality.text.trim(),
                        'document': _document.text.trim(),
                        'address': _address.text.trim(),
                      };
                      final res = await userStore.register(body);
                      if (res['ok'] == true) {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AuthRoute.home);
                      } else {
                        await GsModal(
                          parentContext: context,
                          text: res['error']?.toString() ?? 'Register failed',
                          type: GsModalType.error,
                        ).show();
                      }
                    },
              child: userStore.loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
