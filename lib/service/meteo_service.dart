import 'dart:convert';

import 'package:meteo_app/models/meteo_model.dart';
import 'package:http/http.dart' as http;

class MeteoService {
  static const Base='https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  MeteoService(this.apiKey);


  Future<Meteo> getMeteo(String ville) async{
    final resultat = await http.get(Uri.parse('$Base?q=$ville&appid=$apiKey&units=metric'));
    if(resultat.statusCode==200){
      return Meteo.fromJson(jsonDecode(resultat.body));
    }else{
      throw Exception('Probleme ');
    }
  }
}