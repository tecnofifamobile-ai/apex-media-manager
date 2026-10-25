import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HeroImage extends StatefulWidget {
  final String url;

  const HeroImage({super.key, required this.url});

  @override
  State<HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends State<HeroImage> {
  static final Map<String, Uint8List> _cache = {};
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(HeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _error = false;
      _bytes = null;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.url.isEmpty) {
      if (mounted) setState(() => _error = true);
      return;
    }

    if (_cache.containsKey(widget.url)) {
      if (mounted) {
        setState(() {
          _bytes = _cache[widget.url];
        });
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(widget.url),
        headers: {'User-Agent': 'ESPTV_Player/1.0 (Windows NT 10.0; Win64; x64)'},
      );
      if (response.statusCode == 200) {
        _cache[widget.url] = response.bodyBytes;
        if (mounted) {
          setState(() {
            _bytes = response.bodyBytes;
          });
        }
      } else {
        if (mounted) setState(() => _error = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error || _bytes == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF13151D), Color(0xFF1E2132)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    return Image.memory(
      _bytes!,
      key: ValueKey(widget.url),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    );
  }
}
