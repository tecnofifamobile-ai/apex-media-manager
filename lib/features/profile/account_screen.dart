import '../../core/widgets/glass.dart';
import '../../core/widgets/ios_spinner.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/local_mode_provider.dart';
import 'providers/profile_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(localModeProvider);
    final profiles = ref.watch(profilesProvider);
    return GlassScaffold(
      appBar: AppBar(title: const Text('Cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            local
                ? 'En este dispositivo'
                : Supabase.instance.client.auth.currentUser?.email ??
                      'Cuenta APEX',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (local) const Text('Tus perfiles se guardan en este dispositivo.'),
          const SizedBox(height: 24),
          const Text('Perfiles'),
          ...profiles.when(
            data: (values) => values
                .map(
                  (profile) => GlassTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(profile.colorCode),
                      child: const Icon(Icons.person),
                    ),
                    title: Text(profile.name),
                    onTap: () {
                      ref
                          .read(activeProfileProvider.notifier)
                          .setProfile(profile);
                      context.go('/channels');
                    },
                  ),
                )
                .toList(),
            loading: () => [const Center(child: IosSpinner())],
            error: (_, _) => [
              const Text('No se pudieron cargar los perfiles.'),
            ],
          ),
          const SizedBox(height: 24),
          GlassTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Gestionar perfiles'),
            onTap: () => context.go('/profile'),
          ),
          GlassTile(
            leading: const Icon(Icons.logout),
            title: Text(local ? 'Volver al inicio de sesión' : 'Cerrar sesión'),
            onTap: () async {
              try {
                if (local) {
                  await ref.read(localModeProvider.notifier).disable();
                } else {
                  await Supabase.instance.client.auth.signOut(
                    scope: SignOutScope.local,
                  );
                }
                if (context.mounted) context.go('/auth');
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo cerrar la sesión.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
