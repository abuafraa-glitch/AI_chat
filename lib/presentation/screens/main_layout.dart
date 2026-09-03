import 'package:ai_chat/presentation/blocs/conversations_cubit.dart';
import 'package:ai_chat/presentation/blocs/data_sources.dart';
import 'package:ai_chat/presentation/blocs/models_cubit.dart';
import 'package:ai_chat/core/di/injection.dart';
import 'package:ai_chat/core/constants/storage_keys.dart';
import 'package:ai_chat/core/services/local_storage_service.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';
import 'package:go_router/go_router.dart';

/// Main application shell rendered by the router for the four primary tabs.
class MainLayout extends StatefulWidget {
  /// Creates the main shell for [navigationShell].
  const MainLayout({super.key, required this.navigationShell});

  /// go_router navigation shell driving the tab branches.
  final StatefulNavigationShell navigationShell;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNamespace =
        sl<LocalStorageService>().getString(StorageKeys.currentUserId) ??
        'anonymous';
    return KeyedSubtree(
      key: ValueKey<String>('session-$userNamespace'),
      child: MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<ModelsCubit>.value(value: sl<ModelsCubit>()),
          BlocProvider<ConversationsCubit>(
            // Loading is an explicit user action after backend integration;
            // app boot must remain free of network requests.
            create: (context) =>
              ConversationsCubit(repository: buildConversationRepository()),
        ),
      ],
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          height: 78,
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
          indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          elevation: 0,
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline),
              selectedIcon: const Icon(Icons.chat_bubble),
              label: localizedText(context, 'Chat', 'المحادثات'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.smart_toy_outlined),
              selectedIcon: const Icon(Icons.smart_toy),
              label: localizedText(context, 'Models', 'النماذج'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: localizedText(context, 'Profile', 'الملف'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: localizedText(context, 'Settings', 'الإعدادات'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
