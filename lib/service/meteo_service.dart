import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meteo_app/models/meteo_model.dart';
import 'package:http/http.dart' as http;

class MeteoService {
  static const Base='https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  MeteoService(this.apiKey);


  Future<Meteo> getMeteo(String ville) async{
    try {
      final resultat = await http.get(
        Uri.parse('$Base?q=$ville&appid=$apiKey&units=metric'),
      );

      if (resultat.statusCode == 200) {
        return Meteo.fromJson(jsonDecode(resultat.body));
      } else if (resultat.statusCode == 401) {
        throw Exception('CLE_API_INVALIDE');
      } else if (resultat.statusCode == 404) {
        throw Exception('VILLE_INTROUVABLE');
      } else if (resultat.statusCode >= 500) {
        throw Exception('SERVEUR_OPENWEATHER');
      } else {
        throw Exception('ERREUR_INCONNUE');
      }
    } on SocketException {
      throw Exception('PAS_DE_CONNEXION');
    } on TimeoutException {
      throw Exception('TIMEOUT');
    }
  }
  }