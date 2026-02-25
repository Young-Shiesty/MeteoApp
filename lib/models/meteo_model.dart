class Meteo{
//pour la classe de la weather
  final String ville;
  final double temperature;
  final String mainCondition;

  Meteo({
    required this.ville, required this.temperature, required this.mainCondition});

  factory Meteo.fromJson(Map<String,dynamic> json){
  return Meteo(
    ville: json['name'],
  temperature: json['main']['temp'].toDouble(),
  mainCondition: json['weather'][0]['main'],
  );
  }

}