class Meteo{


  final String ville;
  final double temperature;
  final String conditionini;
  final double vitessevent;
  final int humidite;
  final double latitude;
  final double longitude;


  Meteo({
    required this.ville, required this.temperature, required this.conditionini, required this.vitessevent, required this.humidite, required this.latitude, required this.longitude});

  factory Meteo.fromJson(Map<String,dynamic> json){
  return Meteo(
    ville: json['name'],
  temperature: json['main']['temp'].toDouble(),
  conditionini: json['weather'][0]['main'],
    vitessevent: json['wind']['speed'],
      humidite:json['main']['humidity'],
    latitude:json['coord']['lat'].toDouble(),
    longitude:json['coord']['lon'].toDouble(),

  );
  }
}