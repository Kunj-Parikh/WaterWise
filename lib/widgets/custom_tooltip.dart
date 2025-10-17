import 'package:flutter/material.dart';

class CustomTooltip extends StatefulWidget {
  final String info;
  final Widget child;
  final VoidCallback? onTap;
  const CustomTooltip({
    super.key,
    required this.info,
    required this.child,
    this.onTap,
  });

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  bool _overlayVisible = false;

  void _showOverlay(BuildContext context, Offset position) {
    if (_overlayVisible) return;
    _overlayVisible = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 50,
        top: position.dy - 12,
        child: MouseRegion(
          onEnter: (_) {
            _isHovering = true;
          },
          onExit: (_) {
            _isHovering = false;
            _removeOverlay();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: _buildRichContent(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (!_overlayVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _isHovering = true;
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);
        _showOverlay(context, offset);
      },
      onExit: (event) {
        _isHovering = false;
        Future.delayed(Duration(milliseconds: 100), () {
          if (!_isHovering) _removeOverlay();
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          if (widget.onTap != null) {
            widget.onTap!();
            return;
          }
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: _buildRichContent(),
              contentPadding: EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }

  Widget _buildRichContent() {
    final lines = widget.info.split('\n\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('[BOLD]') && line.endsWith('[/BOLD]')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line.replaceAll('[BOLD]', '').replaceAll('[/BOLD]', ''),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line, style: TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
