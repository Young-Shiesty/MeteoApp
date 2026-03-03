import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

  // ── Données fictives des 5 villes ─────────────────────
  final List<Map<String, dynamic>> _cities = [
    {'city': 'DAKAR',     'flag': '🇸🇳', 'temp': '32°C', 'weather': 'Ensoleillé', 'icon': Icons.wb_sunny},
    {'city': 'NAIROBI',   'flag': '🇰🇪', 'temp': '22°C', 'weather': 'Nuageux',    'icon': Icons.cloud},
    {'city': 'HONG KONG', 'flag': '🇭🇰', 'temp': '28°C', 'weather': 'Pluvieux',   'icon': Icons.grain},
    {'city': 'LONDON',    'flag': '🇬🇧', 'temp': '14°C', 'weather': 'Orageux',    'icon': Icons.thunderstorm},
    {'city': 'PARIS',     'flag': '🇫🇷', 'temp': '18°C', 'weather': 'Venteux',    'icon': Icons.air},
  ];

  final List<String> _waitMessages = [
    'Nous téléchargeons les données…',
    'C\'est presque fini…',
    'Plus que quelques secondes…',
  ];

  int _messageIndex = 0;
  double _progressValue = 0.0;
  bool _isComplete = false;

  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _progressController.addListener(() {
      setState(() {
        _progressValue = _progressController.value;
        _messageIndex = (_progressController.value * 3).floor().clamp(0, 2);
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isComplete = true);
        _fadeController.forward();
      }
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() {
      _progressValue = 0.0;
      _isComplete = false;
      _messageIndex = 0;
    });
    _fadeController.reset();
    _progressController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        // Fond dégradé bleu nuit → bleu marine → bleu ciel
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A), // bleu nuit foncé
              Color(0xFF1B3A6B), // bleu marine
              Color(0xFF2E6DB4), // bleu ciel
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 20),

                // ── Header avec bouton retour ──────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Météo Mondiale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── Phase 1 : jauge + messages ─────────
                if (!_isComplete) ...[

                  const Spacer(),

                  const Icon(
                    Icons.cloud_download_outlined,
                    color: Color(0xFF7EC8E3), // bleu clair
                    size: 60,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    _waitMessages[_messageIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── Jauge de progression ───────────────
                  Column(
                    children: [
                      Text(
                        '${(_progressValue * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF7EC8E3), // bleu clair
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressValue,
                          minHeight: 14,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1E88E5), // bleu vif
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ── Phase 2 : tableau météo ────────────
                ] else ...[

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [

                        const Text(
                          'Résultats Météo 🌍',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ...List.generate(_cities.length, (index) {
                          final city = _cities[index];
                          return _CityCard(
                            flag: city['flag'],
                            city: city['city'],
                            temp: city['temp'],
                            weather: city['weather'],
                            icon: city['icon'],
                          );
                        }),

                        const SizedBox(height: 24),

                        // ── Bouton Recommencer ─────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _restart,
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text(
                              'Recommencer',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5), // bleu vif
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF1E88E5).withOpacity(0.5),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget carte d'une ville ───────────────────────────
class _CityCard extends StatelessWidget {
  final String flag;
  final String city;
  final String temp;
  final String weather;
  final IconData icon;

  const _CityCard({
    required this.flag,
    required this.city,
    required this.temp,
    required this.weather,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Drapeau
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),

          // Nom de la ville
          Expanded(
            child: Text(
              city,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Icône météo
          Icon(icon, color: Color(0xFF7EC8E3), size: 22), // bleu clair
          const SizedBox(width: 8),

          // Type de météo
          Text(
            weather,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),

          // Température
          Text(
            temp,
            style: const TextStyle(
              color: Color(0xFF7EC8E3), // bleu clair
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}