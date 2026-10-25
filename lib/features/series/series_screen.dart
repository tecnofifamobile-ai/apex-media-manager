import 'package:flutter/material.dart';

import '../movies/catalog_screen.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});
  @override
  Widget build(BuildContext context) => const CatalogScreen(series: true);
}
