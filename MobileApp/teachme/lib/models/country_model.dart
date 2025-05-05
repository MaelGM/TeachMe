class Pais {
  final String nombre;
  final String zonaHoraria;
  final List<String> idiomas;

  Pais({
    required this.nombre,
    required this.zonaHoraria,
    required this.idiomas,
  });

  factory Pais.fromJson(Map json) {
    final name = json['name'] as Map?;
    final common = name?['common'] ?? '';
    final timezones = json['timezones'] as List?;
    final langs = (json['languages'] as Map?)?.values.map((e) => e.toString()).toList() ?? [];
  
    return Pais(
      nombre: common,
      zonaHoraria: timezones?.first ?? '',
      idiomas: langs,
    );
  }
}
