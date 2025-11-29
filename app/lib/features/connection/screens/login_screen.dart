import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/server_config.dart';
import '../providers/connection_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';

enum AuthMethod { key, password }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _agentPortController = TextEditingController(text: '3000');
  final _agentSecretController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _labelController = TextEditingController();

  AuthMethod _authMethod = AuthMethod.key;
  bool _obscurePassword = true;
  bool _obscureAgentSecret = true;

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _agentPortController.dispose();
    _agentSecretController.dispose();
    _privateKeyController.dispose();
    _passwordController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _handleConnect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final config = ServerConfig(
      host: _hostController.text.trim(),
      username: _usernameController.text.trim(),
      privateKey: _authMethod == AuthMethod.key
          ? _privateKeyController.text.trim()
          : null,
      password: _authMethod == AuthMethod.password
          ? _passwordController.text.trim()
          : null,
      agentPort: int.parse(_agentPortController.text.trim()),
      agentSecret: _agentSecretController.text.trim(),
      label: _labelController.text.trim().isEmpty
          ? null
          : _labelController.text.trim(),
    );

    final provider = context.read<ConnectionProvider>();
    await provider.connect(config);

    if (!mounted) return;

    if (provider.status == ConnectionStatus.connected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (provider.status == ConnectionStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Connection failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: AppTheme.electricGreen,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'RELAY',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: AppTheme.electricGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'LABEL (OPTIONAL)',
                      hintText: 'Production Server',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      labelText: 'HOST IP',
                      hintText: '192.168.1.10',
                      prefixIcon: Icon(Icons.dns),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Host is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'USERNAME',
                      hintText: 'root',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _agentPortController,
                    decoration: const InputDecoration(
                      labelText: 'AGENT PORT',
                      hintText: '3000',
                      prefixIcon: Icon(Icons.hub),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Agent port is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid port number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _agentSecretController,
                    obscureText: _obscureAgentSecret,
                    decoration: InputDecoration(
                      labelText: 'AGENT PASSWORD',
                      hintText: 'Enter agent authentication password',
                      prefixIcon: const Icon(Icons.security),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureAgentSecret
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureAgentSecret = !_obscureAgentSecret;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Agent password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.deepCharcoal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _authMethod = AuthMethod.key;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _authMethod == AuthMethod.key
                                    ? AppTheme.electricGreen
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'KEY AUTH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _authMethod == AuthMethod.key
                                      ? AppTheme.voidBlack
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _authMethod = AuthMethod.password;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _authMethod == AuthMethod.password
                                    ? AppTheme.electricGreen
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'PASSWORD AUTH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _authMethod == AuthMethod.password
                                      ? AppTheme.voidBlack
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_authMethod == AuthMethod.key)
                    TextFormField(
                      controller: _privateKeyController,
                      decoration: const InputDecoration(
                        labelText: 'PRIVATE KEY (PEM)',
                        hintText: '-----BEGIN RSA PRIVATE KEY-----',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 100),
                          child: Icon(Icons.key),
                        ),
                      ),
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (_authMethod == AuthMethod.key) {
                          if (value == null || value.isEmpty) {
                            return 'Private key is required';
                          }
                          if (!value.contains('BEGIN') ||
                              !value.contains('PRIVATE KEY')) {
                            return 'Invalid PEM format';
                          }
                        }
                        return null;
                      },
                    ),

                  if (_authMethod == AuthMethod.password)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        hintText: 'Enter SSH password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (_authMethod == AuthMethod.password) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 32),

                  Consumer<ConnectionProvider>(
                    builder: (context, provider, child) {
                      final isLoading =
                          provider.status == ConnectionStatus.connecting;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleConnect,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.voidBlack,
                                  ),
                                ),
                              )
                            : const Text('CONNECT'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
