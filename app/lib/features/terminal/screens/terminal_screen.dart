import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';
import 'package:dartssh2/dartssh2.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/connection/providers/connection_provider.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late Terminal terminal;
  SSHSession? session;

  @override
  void initState() {
    super.initState();
    terminal = Terminal(maxLines: 10000);
    _initializeTerminal();
  }

  Future<void> _initializeTerminal() async {
    final provider = context.read<ConnectionProvider>();

    if (!provider.isConnected) {
      terminal.write('Not connected to server\r\n');
      return;
    }

    try {
      session = await provider.sshClient.shell();

      session!.stdout.cast<List<int>>().transform(utf8.decoder).listen((data) {
        terminal.write(data);
      });

      session!.stderr.cast<List<int>>().transform(utf8.decoder).listen((data) {
        terminal.write(data);
      });

      terminal.onOutput = (data) {
        session?.stdin.add(utf8.encode(data));
      };
    } catch (e) {
      terminal.write('Failed to initialize terminal: $e\r\n');
    }
  }

  @override
  void dispose() {
    session?.close();
    super.dispose();
  }

  void _sendSpecialKey(String key) {
    if (session == null) return;

    switch (key) {
      case 'ESC':
        session!.stdin.add(Uint8List.fromList([27]));
        break;
      case 'TAB':
        session!.stdin.add(Uint8List.fromList([9]));
        break;
      case 'CTRL+C':
        session!.stdin.add(Uint8List.fromList([3]));
        break;
      case 'CTRL+X':
        session!.stdin.add(Uint8List.fromList([24]));
        break;
      case 'UP':
        session!.stdin.add(Uint8List.fromList([27, 91, 65]));
        break;
      case 'DOWN':
        session!.stdin.add(Uint8List.fromList([27, 91, 66]));
        break;
      case '/':
        session!.stdin.add(Uint8List.fromList([47]));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('TERMINAL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: TerminalView(
                terminal,
                theme: TerminalTheme(
                  cursor: AppTheme.electricGreen,
                  selection: AppTheme.electricGreen.withValues(alpha: 0.3),
                  foreground: AppTheme.textWhite,
                  background: Colors.black,
                  black: Colors.black,
                  red: AppTheme.errorRed,
                  green: AppTheme.electricGreen,
                  yellow: AppTheme.warningYellow,
                  blue: AppTheme.neonBlue,
                  magenta: const Color(0xFFFF00FF),
                  cyan: AppTheme.neonBlue,
                  white: AppTheme.textWhite,
                  brightBlack: AppTheme.textGrey,
                  brightRed: AppTheme.errorRed,
                  brightGreen: AppTheme.electricGreen,
                  brightYellow: AppTheme.warningYellow,
                  brightBlue: AppTheme.neonBlue,
                  brightMagenta: const Color(0xFFFF00FF),
                  brightCyan: AppTheme.neonBlue,
                  brightWhite: AppTheme.textWhite,
                  searchHitBackground: AppTheme.electricGreen,
                  searchHitBackgroundCurrent: AppTheme.neonBlue,
                  searchHitForeground: AppTheme.voidBlack,
                ),
                textStyle: const TerminalStyle(
                  fontSize: 13,
                  fontFamily: 'Courier',
                ),
                autofocus: true,
              ),
            ),
          ),
          Container(
            color: AppTheme.deepCharcoal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolbarButton('ESC'),
                  _buildToolbarButton('TAB'),
                  _buildToolbarButton('CTRL+C'),
                  _buildToolbarButton('CTRL+X'),
                  _buildToolbarButton('UP'),
                  _buildToolbarButton('DOWN'),
                  _buildToolbarButton('/'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => _sendSpecialKey(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.voidBlack,
          foregroundColor: AppTheme.electricGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: const Size(60, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppTheme.electricGreen, width: 1),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
