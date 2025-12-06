import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const RouletteApp());
}

class RouletteApp extends StatelessWidget {
  const RouletteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      home: const RouletteScreen(),
    );
  }
}

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _resultController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _resultOpacityAnimation;

  int? _result;
  bool _isSpinning = false;

  final List<Color> _segmentColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.decelerate,
    );

    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));

    _resultOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: const Interval(0.0, 0.5),
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _spinRoulette() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    _resultController.reset();

    final random = math.Random();
    final targetSegment = random.nextInt(8) + 1;
    final baseRotations = 4 + random.nextDouble() * 2;
    final segmentAngle = 360 / 8;
    final targetAngle = (8 - targetSegment) * segmentAngle + (segmentAngle / 2);
    final totalRotation = baseRotations * 360 + targetAngle;

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.decelerate,
    ));

    _rotationController.reset();
    await _rotationController.forward();

    setState(() {
      _result = targetSegment;
      _isSpinning = false;
    });

    _resultController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3F51B5),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _resultController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _resultScaleAnimation.value,
                        child: Opacity(
                          opacity: _resultOpacityAnimation.value,
                          child: _result != null
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$_result',
                                    style: const TextStyle(
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * math.pi / 180,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: RoulettePainter(_segmentColors),
                            size: const Size(300, 300),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: ElevatedButton(
                    onPressed: _isSpinning ? null : _spinRoulette,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: Text(_isSpinning ? 'スピン中...' : 'スタート'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoulettePainter extends CustomPainter {
  final List<Color> segmentColors;

  RoulettePainter(this.segmentColors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 360 / 8;

    for (int i = 0; i < 8; i++) {
      final paint = Paint()
        ..color = segmentColors[i]
        ..style = PaintingStyle.fill;

      final startAngle = (i * segmentAngle - 90) * math.pi / 180;
      final sweepAngle = segmentAngle * math.pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        ),
      );
    }

    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..color = Colors.deepPurple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}