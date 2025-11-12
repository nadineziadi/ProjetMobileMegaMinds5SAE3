import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterBottleWidget extends StatefulWidget {
  final double percentage; // 0.0 à 100.0
  final int currentAmount;
  final int goalAmount;

  const WaterBottleWidget({
    super.key,
    required this.percentage,
    required this.currentAmount,
    required this.goalAmount,
  });

  @override
  State<WaterBottleWidget> createState() => _WaterBottleWidgetState();
}

class _WaterBottleWidgetState extends State<WaterBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouteille avec animation
        SizedBox(
          width: 200,
          height: 320,
          child: CustomPaint(
            painter: WaterBottlePainter(
              percentage: widget.percentage,
              waveAnimation: _waveController,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Informations
        Text(
          '${widget.currentAmount} ml',
          style: const TextStyle(
            color: Color(0xFFC7F000),
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'sur ${widget.goalAmount} ml',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.percentage.toInt()}% de l\'objectif',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class WaterBottlePainter extends CustomPainter {
  final double percentage;
  final Animation<double> waveAnimation;

  WaterBottlePainter({
    required this.percentage,
    required this.waveAnimation,
  }) : super(repaint: waveAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    
    // Dessiner le contour de la bouteille
    final bottlePaint = Paint()
      ..color = const Color(0xFF2A2E32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Corps de la bouteille
    final bodyPath = Path();
    final bodyWidth = size.width * 0.6;
    final bodyHeight = size.height * 0.75;
    final bodyLeft = centerX - bodyWidth / 2;
    final bodyTop = size.height * 0.15;
    
    bodyPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
        const Radius.circular(20),
      ),
    );
    
    // Goulot
    final neckWidth = bodyWidth * 0.4;
    final neckHeight = size.height * 0.1;
    final neckPath = Path();
    neckPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - neckWidth / 2,
          bodyTop - neckHeight,
          neckWidth,
          neckHeight,
        ),
        const Radius.circular(10),
      ),
    );
    
    // Bouchon
    final capWidth = neckWidth * 0.8;
    final capHeight = size.height * 0.05;
    final capPath = Path();
    capPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - capWidth / 2,
          0,
          capWidth,
          capHeight,
        ),
        const Radius.circular(8),
      ),
    );

    canvas.drawPath(bodyPath, bottlePaint);
    canvas.drawPath(neckPath, bottlePaint);
    canvas.drawPath(capPath, bottlePaint);

    // Remplir avec de l'eau
    if (percentage > 0) {
      final waterHeight = bodyHeight * (percentage / 100);
      final waterTop = bodyTop + bodyHeight - waterHeight;
      
      // Créer le chemin de l'eau avec des vagues
      final waterPath = Path();
      waterPath.moveTo(bodyLeft, bodyTop + bodyHeight);
      waterPath.lineTo(bodyLeft, waterTop);
      
      // Dessiner les vagues
      final waveAmplitude = 5.0;
      final waveFrequency = 2.0;
      final waveOffset = waveAnimation.value * math.pi * 2;
      
      for (double x = bodyLeft; x <= bodyLeft + bodyWidth; x += 2) {
        final relativeX = (x - bodyLeft) / bodyWidth;
        final wave = math.sin(relativeX * math.pi * waveFrequency + waveOffset) * 
                     waveAmplitude;
        waterPath.lineTo(x, waterTop + wave);
      }
      
      waterPath.lineTo(bodyLeft + bodyWidth, bodyTop + bodyHeight);
      waterPath.close();

      // Dégradé de l'eau
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4FC3F7).withOpacity(0.6),
            const Color(0xFF0288D1).withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTWH(
          bodyLeft,
          waterTop,
          bodyWidth,
          waterHeight,
        ));

      canvas.drawPath(waterPath, waterPaint);

      // Ajouter des reflets
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawOval(
        Rect.fromLTWH(
          bodyLeft + bodyWidth * 0.15,
          waterTop + waterHeight * 0.2,
          bodyWidth * 0.25,
          waterHeight * 0.4,
        ),
        highlightPaint,
      );
    }

    // Dessiner les graduations
    final gradPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = bodyTop + (bodyHeight / 5) * i;
      canvas.drawLine(
        Offset(bodyLeft + 5, y),
        Offset(bodyLeft + 20, y),
        gradPaint,
      );
      canvas.drawLine(
        Offset(bodyLeft + bodyWidth - 5, y),
        Offset(bodyLeft + bodyWidth - 20, y),
        gradPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}