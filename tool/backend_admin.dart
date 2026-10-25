import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

/// Administrative helper. Credentials are read only from ignored local config.
Future<void> main(List<String> args) async {
  final config = <String, String>{...Platform.environment};
  final local = File('.env.local');
  if (await local.exists()) {
    for (final line in await local.readAsLines()) {
      final split = line.indexOf('=');
      if (split > 0) {
        config.putIfAbsent(
          line.substring(0, split),
          () => line.substring(split + 1),
        );
      }
    }
  }
  final connectionUrl = config['DATABASE_URL'];
  if (connectionUrl == null) {
    throw StateError('Set DATABASE_URL in .env.local.');
  }
  final uri = Uri.parse(connectionUrl);
  final credentials = uri.userInfo.split(':');
  Connection? connection;
  try {
    final pooler = config['DATABASE_POOLER_HOST'];
    connection = await Connection.open(
      Endpoint(
        host: pooler ?? uri.host,
        port: uri.hasPort ? uri.port : 5432,
        database: uri.pathSegments.last,
        username: pooler == null
            ? Uri.decodeComponent(credentials.first)
            : 'postgres.${uri.host.split('.')[1]}',
        password: Uri.decodeComponent(credentials.skip(1).join(':')),
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.verifyFull,
        securityContext: SecurityContext(withTrustedRoots: true)
          ..setTrustedCertificates('tool/supabase-ca.crt'),
        connectTimeout: const Duration(seconds: 15),
      ),
    );
    if (args.isEmpty || args.first == 'inspect') {
      final tables = await connection.execute(
        "select table_name from information_schema.tables where table_schema = 'public' order by table_name",
      );
      stdout.writeln(
        jsonEncode({'tables': tables.map((row) => row.first).toList()}),
      );
      final policies = await connection.execute(
        "select tablename, policyname, roles, cmd from pg_policies where schemaname = 'public'",
      );
      stdout.writeln(
        jsonEncode({
          'policies': policies.map((row) => row.toColumnMap()).toList(),
        }),
      );
    } else if (args.first == 'apply') {
      final sql = await File('supabase/schema.sql').readAsString();
      await connection.execute(sql, queryMode: QueryMode.simple);
      stdout.writeln('APEX schema applied.');
    } else if (args.first == 'verify') {
      final rows = await connection.execute(
        "select c.relname, c.relrowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relname in ('profiles','app_settings')",
      );
      stdout.writeln(jsonEncode(rows.map((row) => row.toColumnMap()).toList()));
      await connection.runTx((session) async {
        await session.execute('set local role anon');
        final settings = await session.execute(
          'select id from public.app_settings',
        );
        stdout.writeln(
          'Anonymous update metadata read: ${settings.length} row(s).',
        );
      });
    } else {
      throw ArgumentError('Use inspect, apply or verify.');
    }
  } catch (error) {
    var message = error.toString().replaceAll(connectionUrl, '<connection>');
    for (final value in credentials) {
      if (value.isNotEmpty) message = message.replaceAll(value, '<redacted>');
    }
    stderr.writeln(message);
    exitCode = 1;
  } finally {
    await connection?.close();
  }
}
