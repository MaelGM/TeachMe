
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teachme/models/country_model.dart';

class CountryService {
  Future<Pais?> getCountryByName(String name) async {
    final url = Uri.parse('https://restcountries.com/v3.1/name/$name?fullText=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print(data);
      if (data.isNotEmpty) {
        return Pais.fromJson(data[0]);
      }
    }

    return null;
  }
}
