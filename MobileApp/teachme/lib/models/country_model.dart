class Pais {
  final String nombre;
  final String zonaHoraria;
  final List<String> idiomas;        // ej: English
  final List<String> codigosIdioma;  // ej: en

  Pais({
    required this.nombre,
    required this.zonaHoraria,
    required this.idiomas,
    required this.codigosIdioma,
  });

  factory Pais.fromJson(Map json) {
    final name = json['name'] as Map?;
    final common = name?['common'] ?? '';
    final timezones = json['timezones'] as List?;
    final langMap = json['languages'] as Map? ?? {};

    return Pais(
      nombre: common,
      zonaHoraria: timezones?.first ?? '',
      idiomas: langMap.values.map((e) => e.toString()).toList(),
      codigosIdioma: langMap.keys.map((e) => e.toString()).toList(),
    );
  }
}
