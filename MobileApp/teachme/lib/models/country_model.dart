class Pais {
  final String nombre;
  final String zonaHoraria;
  final List<String> idiomas;

  Pais({
    required this.nombre,
    required this.zonaHoraria,
    required this.idiomas,
  });

  factory Pais.fromJson(Map<String, dynamic> json) {
    return Pais(
      nombre: json['name']['common'],
      zonaHoraria: (json['timezones'] as List).first,
      idiomas: (json['languages'] as Map).values.map((e) => e.toString()).toList(),
    );
  }
}
