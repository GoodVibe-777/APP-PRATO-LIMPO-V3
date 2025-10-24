import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/navigation_provider.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/diary/diary_screen.dart';
import 'screens/scanner/scanner_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          ScannerScreen(),
          DiaryScreen(),
          ChatScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            ref.read(navIndexProvider.notifier).state = value,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Diário',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Nutri-IA',
          ),
        ],
      ),
    );
  }
}
