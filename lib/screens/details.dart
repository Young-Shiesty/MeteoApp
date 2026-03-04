import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class Details extends StatefulWidget {

  final String ville;
  final double temperature;
  final String conditionini;
  final double vitessevent;
  final int humidite;
  final double latitude;
  final double longitude;

  const Details({
    super.key,
    required this.ville,
    required this.temperature,
    required this.conditionini,
    required this.vitessevent,
    required this.humidite,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<Details> createState() => DetailsState();
}

class DetailsState extends State<Details> {

  String getWeatherIcon() {
    switch (widget.conditionini.toLowerCase()) {
      case "clear":        return "☀️";
      case "clouds":       return "☁️";
      case "rain":         return "🌧️";
      case "drizzle":      return "🌦️";
      case "thunderstorm": return "⛈️";
      case "snow":         return "❄️";
      case "mist":
      case "fog":          return "🌫️";
      default:             return "⛅";
    }
  }

  String getDescription() {
    switch (widget.conditionini.toLowerCase()) {
      case "clear":        return "Ciel dégagé";
      case "clouds":       return "Nuageux";
      case "rain":         return "Pluvieux";
      case "drizzle":      return "Bruine";
      case "thunderstorm": return "Orage";
      case "snow":         return "Neige";
      case "mist":
      case "fog":          return "Brouillard";
      default:             return widget.conditionini;
    }
  }

  Future<void> ouvrirCarte() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          coords: Coords(widget.latitude, widget.longitude),
          title: widget.ville,
          description: "${widget.temperature.toStringAsFixed(1)}°C - ${getDescription()}",
        );
      }
    } catch (e) {
  showDialog(
  context: context,
  builder: (_) => AlertDialog(
  title: const Text('❌ Une erreur est survenue'),
  content: const Text('🗺️ Impossible d\'ouvrir la carte\nVerifie que Google Maps est installee.'),
  actions: [
  TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Retour'),
  ),
  ],
  ),
  );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildHeroSection(),
                    const SizedBox(height: 20),
                    buildStatsCards(),
                    const SizedBox(height: 24),
                    buildMapSection(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Text(
            "Détail ville",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeroSection() {
    return Column(
      children: [
        Text(
          widget.ville,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          getWeatherIcon(),
          style: const TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 8),
        Text(
          "${widget.temperature.toStringAsFixed(1)}°C",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            letterSpacing: -3,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Text(
            getDescription(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          statCard("💧", "${widget.humidite}%", "Humidité"),
          const SizedBox(width: 8),
          statCard("💨", "${widget.vitessevent.toStringAsFixed(1)} m/s", "Vent"),
          const SizedBox(width: 8),
          statCard("📍", widget.latitude.toStringAsFixed(2), "Latitude"),
          const SizedBox(width: 8),
          statCard("🧭", widget.longitude.toStringAsFixed(2), "Longitude"),
        ],
      ),
    );
  }

  Widget statCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF7EC8E3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7EC8E3).withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "LOCALISATION",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: ouvrirCarte,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1B3A6B),
                    Color(0xFF0D1B2A),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF7EC8E3).withValues(alpha: 0.3),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: MapGridPainter(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${widget.ville} • ${widget.temperature.toStringAsFixed(0)}°C",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Ouvrir dans Maps",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
