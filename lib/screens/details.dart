import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Details extends StatefulWidget {
  // ✅ Exactement les mêmes champs que le modèle Meteo du coéquipier
  final String ville;
  final double temperature;
  final String mainCondition;

  const Details({
    super.key,
    required this.ville,
    required this.temperature,
    required this.mainCondition,
  });

  @override
  State<Details> createState() => DetailScreenState();
}

class DetailScreenState extends State<Details> {
  GoogleMapController? mapController;

  // ─────────────────────────────────────────
  // Coordonnées fixes par ville
  // (à remplacer quand le coéquipier ajoute lat/lon dans Meteo)
  // ─────────────────────────────────────────
  Map<String, LatLng> coordonnees = {
    "Paris":    LatLng(48.8566, 2.3522),
    "Dakar":    LatLng(14.6937, -17.4441),
    "London":   LatLng(51.5074, -0.1278),
    "New York": LatLng(40.7128, -74.0060),
    "Tokyo":    LatLng(35.6762, 139.6503),
  };

  // Récupère les coordonnées de la ville ou Paris par défaut
  LatLng getCoordonnees() {
    return coordonnees[widget.ville] ?? LatLng(48.8566, 2.3522);
  }

  // ─────────────────────────────────────────
  // Icône météo selon mainCondition
  // ─────────────────────────────────────────
  String getWeatherIcon() {
    switch (widget.mainCondition.toLowerCase()) {
      case "clear":
        return "☀️";
      case "clouds":
        return "☁️";
      case "rain":
        return "🌧️";
      case "drizzle":
        return "🌦️";
      case "thunderstorm":
        return "⛈️";
      case "snow":
        return "❄️";
      case "mist":
      case "fog":
        return "🌫️";
      default:
        return "⛅";
    }
  }

  // ─────────────────────────────────────────
  // Description en français selon mainCondition
  // ─────────────────────────────────────────
  String getDescription() {
    switch (widget.mainCondition.toLowerCase()) {
      case "clear":
        return "Ciel dégagé";
      case "clouds":
        return "Nuageux";
      case "rain":
        return "Pluvieux";
      case "drizzle":
        return "Bruine";
      case "thunderstorm":
        return "Orage";
      case "snow":
        return "Neige";
      case "mist":
      case "fog":
        return "Brouillard";
      default:
        return widget.mainCondition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
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
                    buildMapSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
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
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // HERO : Ville + Icône + Température
  // ─────────────────────────────────────────
  Widget buildHeroSection() {
    return Column(
      children: [
        // Nom de la ville
        Text(
          widget.ville,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 12),

        // Icône météo
        Text(
          getWeatherIcon(),
          style: const TextStyle(fontSize: 70),
        ),

        const SizedBox(height: 8),

        // Température
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

        // Badge description
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            getDescription(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SECTION GOOGLE MAPS
  // ─────────────────────────────────────────
  Widget buildMapSection() {
    LatLng position = getCoordonnees();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre section
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
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

          // Carte Google Maps
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 12,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                markers: {
                  Marker(
                    markerId: MarkerId(widget.ville),
                    position: position,
                    infoWindow: InfoWindow(
                      title: widget.ville,
                      snippet: "${widget.temperature.toStringAsFixed(1)}°C - ${getDescription()}",
                    ),
                  ),
                },
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}