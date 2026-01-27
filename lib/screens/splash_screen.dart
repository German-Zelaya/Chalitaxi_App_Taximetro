import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _meterController;
  late AnimationController _fadeController;
  late Animation<double> _carAnimation;
  late Animation<double> _meterAnimation;
  late Animation<double> _fadeAnimation;

  double _currentFare = 0.0;

  @override
  void initState() {
    super.initState();

    // Animación del auto moviéndose
    _carController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _carAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _carController, curve: Curves.easeInOut),
    );

    // Animación del taxímetro (contador)
    _meterController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _meterAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(
      CurvedAnimation(parent: _meterController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _currentFare = _meterAnimation.value;
      });
    });

    // Animación de fade in del logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Iniciar animaciones
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _carController.repeat(reverse: true);
      _meterController.forward();
    });

    // Navegar a la pantalla principal después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _carController.dispose();
    _meterController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF0000), // Rojo brillante
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Logo "ChaliTaxi" con fade in
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'ChaliTaxi',
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Animación del auto
            SizedBox(
              height: 80,
              child: AnimatedBuilder(
                animation: _carAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Línea de carretera
                      Positioned(
                        bottom: 25,
                        left: 40,
                        right: 40,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Auto animado
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.5 +
                              (_carAnimation.value * MediaQuery.of(context).size.width * 0.3) - 30,
                        bottom: 20,
                        child: Icon(
                          Icons.local_taxi,
                          size: 60,
                          color: Colors.yellow[400],
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Taxímetro digital animado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'TARIFA',
                    style: GoogleFonts.orbitron(
                      color: Colors.green[400],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bs. ${_currentFare.toStringAsFixed(1)}',
                    style: GoogleFonts.orbitron(
                      color: Colors.green[300],
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Indicador de carga circular
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white.withOpacity(0.3),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Iniciando...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
