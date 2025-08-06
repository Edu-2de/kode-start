import 'package:flutter/material.dart';

class TriangularLogo extends StatelessWidget {
  final double width;
  final double height;

  const TriangularLogo({super.key, this.width = 60, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: LogoPainter()),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Triângulo azul claro
    paint.color = const Color(0xFF5BCBF1);
    final path1 = Path();
    path1.moveTo(size.width * 0.2, size.height * 0.8);
    path1.lineTo(size.width * 0.5, size.height * 0.2);
    path1.lineTo(size.width * 0.8, size.height * 0.8);
    path1.close();
    canvas.drawPath(path1, paint);

    // Triângulo azul escuro
    paint.color = const Color(0xFF1E3A8A);
    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height * 0.9);
    path2.lineTo(size.width * 0.4, size.height * 0.3);
    path2.lineTo(size.width * 0.7, size.height * 0.9);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
