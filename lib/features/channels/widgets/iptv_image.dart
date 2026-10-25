import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/utils/image_cache_service.dart';

class IptvImage extends StatefulWidget {
  final String url;
  final String fallbackUrl;
  final Widget? errorWidget;
  final double width;
  final double height;

  const IptvImage({
    super.key,
    required this.url,
    required this.fallbackUrl,
    this.errorWidget,
    required this.width,
    required this.height,
  });

  @override
  State<IptvImage> createState() => _IptvImageState();
}

class _IptvImageState extends State<IptvImage> {
  File? _imageFile;
  bool _isError = false;
  bool _isLoading = true;
  int _loadId = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(IptvImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final currentLoadId = ++_loadId;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _imageFile = null;
      });
    }

    File? file;

    // Check cache first quickly
    if (widget.fallbackUrl.isNotEmpty) {
      file = await ImageCacheService.getCachedFile(widget.fallbackUrl);
    }
    if (file == null && widget.url.isNotEmpty) {
      file = await ImageCacheService.getCachedFile(widget.url);
    }

    // If not cached, download it
    if (file == null) {
      if (widget.fallbackUrl.isNotEmpty) {
        file = await ImageCacheService.downloadFile(
          widget.fallbackUrl,
          useVlc: false,
        );
        file ??= await ImageCacheService.downloadFile(
          widget.fallbackUrl,
          useVlc: true,
        );
      }
      if (file == null && widget.url.isNotEmpty) {
        file = await ImageCacheService.downloadFile(widget.url, useVlc: false);
        file ??= await ImageCacheService.downloadFile(widget.url, useVlc: true);
      }
    }

    if (mounted && _loadId == currentLoadId) {
      if (file != null) {
        setState(() {
          _imageFile = file;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Icon(Icons.tv_outlined, color: Colors.white12),
        ),
      );
    }

    if (_isError || _imageFile == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child:
            widget.errorWidget ??
            const Icon(Icons.tv, color: Colors.white24, size: 24),
      );
    }

    return Image.file(
      _imageFile!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      cacheWidth: 320,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) =>
          widget.errorWidget ?? const Icon(Icons.broken_image_outlined),
    );
  }
}
