import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meteo_app/models/meteo_model.dart';
import 'package:meteo_app/pages/home_screen.dart';
import 'package:meteo_app/service/meteo_service.dart';
import 'package:meteo_app/screens/details.dart';


class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

  final meteoService = MeteoService('a5a4809e01d399d956603aa27481262c');
  final List<String> villes = ['Dakar', 'Nairobi', 'Hong Kong', 'London', 'Paris'];
  List<Meteo> meteoList = [];
  Meteo? meteoAffichee;
  bool loading = true;
  String messageChargement = 'Nous téléchargeons les données…';
  double progression = 0.0;
  bool afficherListe = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    lancerChargement();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> recupererMeteo() async {
    meteoList.clear();
    for (String ville in villes) {
      try {
        final meteo = await meteoService.getMeteo(ville);
        meteoList.add(meteo);
      } catch (e) {
        print('Erreur pour $ville : $e');
      }
    }
    if (meteoList.isNotEmpty) {
      setState(() {
        meteoAffichee = meteoList[0];
      });
    }
  }

  void lancerChargement() {
    setState(() {
      loading = true;
      progression = 0.0;
      messageChargement = 'Nous téléchargeons les données…';
    });
    recupererMeteo();
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      setState(() {
        progression += 0.02;
        if (progression >= 0.33 && progression < 0.35) {
          messageChargement = 'C\'est presque fini…';
        }
        if (progression >= 0.66 && progression < 0.68) {
          messageChargement = 'Plus que quelques secondes…';
        }
        if (progression >= 1.0) {
          progression = 1.0;
          t.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() { loading = false; });
          });
        }
      });
    });
  }

  String getEmoji(String condition) {
    String c = condition.toLowerCase();
    if (c == 'clear') return '☀️';
    if (c == 'clouds') return '⛅';
    if (c == 'rain' || c == 'drizzle') return '🌧️';
    if (c == 'thunderstorm') return '⛈️';
    if (c == 'snow') return '❄️';
    return '🌤️';
  }

  Color getCouleurFond(String condition) {
    String c = condition.toLowerCase();
    if (c == 'clear') return const Color(0xFF7EB8F7);
    if (c == 'rain' || c == 'drizzle') return const Color(0xFF7B9BC7);
    if (c == 'clouds') return const Color(0xFF9BAFC7);
    return const Color(0xFF89C4E1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: loading ? buildEcranChargement() : buildEcranPrincipal(),
      ),
    );
  }
  Widget buildEcranChargement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Météo App ☁️',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
          const SizedBox(height: 40),
          SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progression,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFDCE7FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B8DEE)),
                  strokeCap: StrokeCap.round,
                ),
                Text('${(progression * 100).round()}%',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(messageChargement,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5B8DEE))),
        ],
      ),
    );
  }
  Widget buildEcranPrincipal() {
    if (meteoAffichee == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        buildEntete(),
        const SizedBox(height: 16),
        if (afficherListe)
          Expanded(child: buildListeVilles())
        else ...[
          buildCarteMeteo(),
          const SizedBox(height: 14),
          buildStats(),
          buildSectionToday(),
        ],
      ],
    );
  }
  Widget buildEntete() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(meteoAffichee?.ville ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
          GestureDetector(
            onTap: () => setState(() { afficherListe = !afficherListe; }),
            child: Row(
              children: [
                const Text('Changer',
                    style: TextStyle(fontSize: 14, color: Color(0xFF5B8DEE), fontWeight: FontWeight.w600)),
                Icon(
                  afficherListe ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF5B8DEE),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget buildListeVilles() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: meteoList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final m = meteoList[i];
          final estSelectionnee = m.ville == meteoAffichee?.ville;
          return ListTile(
            leading: Text(getEmoji(m.conditionini), style: const TextStyle(fontSize: 28)),
            title: Text(m.ville,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: estSelectionnee ? const Color(0xFF5B8DEE) : const Color(0xFF1A2F5E))),
            trailing: Text('${m.temperature.round()}°C',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16,
                    color: estSelectionnee ? const Color(0xFF5B8DEE) : const Color(0xFF1A2F5E))),
            onTap: () {
              setState(() {
                meteoAffichee = m;
                afficherListe = false;
              });
            },
          );
        },
      ),
    );
  }
  Widget buildCarteMeteo() {
    final meteo = meteoAffichee!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: getCouleurFond(meteo.conditionini),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meteo.ville,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
                  const SizedBox(height: 4),
                  Text(meteo.conditionini,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4A6FA5), fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${meteo.temperature.round()}°C',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF5B8DEE),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('🏠 Accueil',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),

                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(
                                ville: meteo.ville,
                                temperature: meteo.temperature,
                                conditionini: meteo.conditionini,  // ← ici
                                vitessevent: meteo.vitessevent,
                                humidite: meteo.humidite,
                                latitude: meteo.latitude,
                                longitude: meteo.longitude,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B8DEE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('📍 Détails',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            Positioned(
              right: 20, top: 20,
              child: Text(getEmoji(meteo.conditionini), style: const TextStyle(fontSize: 80)),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildStats() {
    final meteo = meteoAffichee!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildUneStat('💨', 'Wind Speed', '${meteo.vitessevent.round()} km/h'),
            Container(width: 1, height: 40, color: const Color(0xFFEEF2FF)),
            buildUneStat('💧', 'Humidity', '${meteo.humidite}%'),
          ],
        ),
      ),
    );
  }

  Widget buildUneStat(String emoji, String label, String valeur) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8899BB), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(valeur, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
      ],
    );
  }
  Widget buildSectionToday() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text('Today',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A2F5E))),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: meteoList.length,
            itemBuilder: (context, i) {
              final m = meteoList[i];
              final estSelectionnee = m.ville == meteoAffichee?.ville;
              return GestureDetector(
                onTap: () => setState(() { meteoAffichee = m; }),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: estSelectionnee ? const Color(0xFF5B8DEE) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${m.temperature.round()}°C',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                              color: estSelectionnee ? Colors.white : const Color(0xFF1A2F5E))),
                      const SizedBox(height: 4),
                      Text(getEmoji(m.conditionini), style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(m.ville,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: estSelectionnee ? Colors.white.withOpacity(0.85) : const Color(0xFF8899BB))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}