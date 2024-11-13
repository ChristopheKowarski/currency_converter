import 'dart:convert';
import 'secrets.dart';
import 'package:http/http.dart' as http;

CurrencyConvert currencyConvertFromJson(String str) =>
    CurrencyConvert.fromJson(json.decode(str));

String currencyConvertToJson(CurrencyConvert data) =>
    json.encode(data.toJson());

class CurrencyConvert {
  Map<String, double> data;

  CurrencyConvert({
    required this.data,
  });

  factory CurrencyConvert.fromJson(Map<String, dynamic> json) =>
      CurrencyConvert(
        data: Map.from(json["data"]).map(
          (k, v) => MapEntry<String, double>(k, v?.toDouble()),
        ),
      );

  Map<String, dynamic> toJson() => {
        "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

// Future<double> result = Future<double>.delayed(
//   const Duration(seconds: 2),
//   () => 0.0,
// );
// Future<double> currentResult = Future<double>.delayed(
//   const Duration(seconds: 2),
//   () => 0.0,
// );
double result = 0.0;
double fromConversion = 0.0;
double toConversion = 0.0;
double currentConversion = 0.0;
double amountConversion = 0.0;
bool responded = false;
bool thirdNeeded = false;
final Future<String> responseBody = Future.value(fetchData());

Map<String, String> currenciesSymbolsMap = {
  'AUD': "\$",
  'BGN': "лв",
  'BRL': 'R\$',
  'CAD': "\$",
  'CHF': "CHF",
  'CNY': "¥",
  'CZK': "Kč",
  'DKK': "kr",
  'EUR': "€",
  'GBP': "£",
  'HKD': "\$",
  'HRK': "kn",
  'HUF': "Ft",
  'IDR': "Rp",
  'ILS': "₪",
  'INR': "₹",
  'ISK': "kr",
  'JPY': "¥",
  'KRW': "₩",
  'MXN': "\$",
  'MYR': "RM",
  'NOK': "kr",
  'NZD': "\$",
  'PHP': "₱",
  'PLN': "zł",
  'RON': "lei",
  'RUB': "₽",
  'SEK': "kr",
  'SGD': "\$",
  'THB': "฿",
  'TRY': "₺",
  'USD': "\$",
  'ZAR': "R",
};

// Method to retrieve current conversion rates from https://api.freecurrencyapi.com
Future<String> fetchData() async {
  const String apiKey = FREE_CURRENCY_API_KEY;

  final response = await http.get(
    Uri.parse('https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey'),
  );

  return response.body;
}

// Method to convert the 'from' currency into the 'to' currency
void convert(String from, String to, double amount) async {
  String response = await responseBody;
  CurrencyConvert responseFromJSON = currencyConvertFromJson(response);

  if (responseFromJSON.data["AUD"] != null) responded = true;

  fromConversion = double.parse(responseFromJSON.data[from].toString());
  toConversion = double.parse(responseFromJSON.data[to].toString());

  amountConversion = amount;

  if (thirdNeeded) {
    currentConversion = amountConversion;
    result = currentConversion / fromConversion * toConversion;
  } else {
    result = amountConversion / fromConversion * toConversion;
  }
}
