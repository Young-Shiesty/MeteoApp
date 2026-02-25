import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meteo_app/models/meteo_model.dart';
import 'package:meteo_app/service/meteo_service.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

final meteo_service = MeteoService('a5a4809e01d399d956603aa27481262c');
Meteo ? _meteo;


final List<String> villes = [
  "Dakar",
  "Nairobi",
  "Hong Kong",
  "London",
  "Paris"
];
List<Meteo>_meteoList = [];

  Future<void> recupmeteo(List<String> villes)async {
    _meteoList.clear();
    for (String ville in villes) {
      try {
        final meteo = await meteo_service.getMeteo(ville);
        setState(() {
          _meteoList.add(meteo);
        });
      } catch (e) {
        print(e);
      }
    }
  }
@override
void initState() {
  recupmeteo(villes);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_meteoList.isEmpty? Center(child: Text("Nous téléchargeons les données…")):
      ListView.builder(
        itemCount: _meteoList.length,
        itemBuilder: (context, i){
      final meteo = _meteoList[i];

      return ListTile(
        title: Text(meteo.ville),
        subtitle: Text('${meteo.temperature.round()}°C'),
      );
        }
      ),

    );
  }
}
