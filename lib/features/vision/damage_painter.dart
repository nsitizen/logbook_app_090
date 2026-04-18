import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  final double mockX;
  final double mockY;
  final String label;

  DamagePainter({required this.mockX, required this.mockY, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    const searchStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.yellowAccent,
    );

    final searchSpan = const TextSpan(
      text: " Searching for Road Damage... ",
      style: searchStyle,
    );

    final searchPainter = TextPainter(
      text: searchSpan,
      textDirection: TextDirection.ltr,
    );

    searchPainter.layout();

    // Tempatkan di tengah atas layar
    double searchX = (size.width - searchPainter.width) / 2;
    searchPainter.paint(canvas, Offset(searchX, 50));

    Color damageColor = label == "D40" ? Colors.redAccent : Colors.yellowAccent;
    String damageText = label == "D40" ? " [$label] POTHOLE 92% " : " [$label] CRACK 85% ";

    final paint = Paint()
      ..color = damageColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    double boxSize = size.width * 0.5;
    double left = (mockX * size.width) - (boxSize / 2);
    double top = (mockY * size.height) - (boxSize / 2);

    final rect = Rect.fromLTWH(left, top, boxSize, boxSize);
    canvas.drawRect(rect, paint);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: damageColor, 
      shadows: const [
        Shadow(
          blurRadius: 4.0,
          color: Colors.black54,
          offset: Offset(2.0, 2.0),
        ),
      ],
    );

    final textSpan = TextSpan(text: damageText, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    textPainter.layout();

    double textY = top - 25;
    if (textY < 0) textY = top + boxSize + 5;

    textPainter.paint(canvas, Offset(left, textY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    return oldDelegate.mockX != mockX || 
           oldDelegate.mockY != mockY || 
           oldDelegate.label != label;
  }
}
