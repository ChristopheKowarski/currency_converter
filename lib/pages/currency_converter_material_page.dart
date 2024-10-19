// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        data: Map.from(json["data"])
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  double result = 0;
  final TextEditingController textEditingController = TextEditingController();
  late Future<double> futureCurrency;
  bool _buttonState = true;
  String _subtitle = "AUD to EUR";
  final String _dollarSymbol = '\$';
  final String _euroSymbol = '€';
  final String _renminbiSymbol = '¥';
  String currencySymbol = "";

  @override
  void initState() {
    futureCurrency = fetchConversion();
    super.initState();
  }

  // Method to retrieve current conversion rates from https://api.freecurrencyapi.com
  Future<double> fetchConversion() async {
    final headers = {'Authorization': 'Bearer token'};
    final response = await http.get(
        Uri.parse('https://api.freecurrencyapi.com/v1/latest'),
        headers: headers);

    CurrencyConvert responseFromJSON = currencyConvertFromJson(response.body);

    double AUDconversion =
        double.parse(responseFromJSON.data["AUD"].toString());
    double EURconversion =
        double.parse(responseFromJSON.data["EUR"].toString());

    if (_buttonState == true) {
      double conversion = (double.tryParse(textEditingController.text) ?? 0) /
          AUDconversion *
          EURconversion;
      currencySymbol = _euroSymbol;
      setState(() {});
      result = conversion;
    } else {
      double conversion = (double.tryParse(textEditingController.text) ?? 0) /
          EURconversion *
          AUDconversion;
      currencySymbol = _dollarSymbol;
      result = conversion;
    }

    if (response.statusCode == 200) {
      setState(() {});
      return EURconversion;
    } else {
      throw Exception('Failed to fetch conversion rate');
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(
        width: 2.0,
        style: BorderStyle.solid,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DropdownButton(items: items, onChanged: onChanged),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  Switch(
                    // thumb color (round icon)
                    activeColor: Colors.amber,
                    activeTrackColor: Colors.cyan,
                    inactiveThumbColor: Colors.blueGrey,
                    inactiveTrackColor: Colors.grey,
                    splashRadius: 50.0,
                    // boolean variable value
                    value: _buttonState,
                    // changes the state of the switch
                    onChanged: (bool newValue) {
                      _subtitle =
                          newValue == true ? "AUD to EUR" : "EUR to AUD";
                      setState(() {
                        _buttonState = newValue;
                      });
                    },
                  ),
                ],
              ),
              Text(
                result != 0
                    ? "$currencySymbol${result.toStringAsFixed(2)}"
                    : "$currencySymbol${result.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              TextField(
                controller: textEditingController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Please enter the amount in AUD',
                  hintStyle: const TextStyle(
                    color: Colors.black,
                  ),
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  prefixIconColor: Colors.black,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: border,
                  enabledBorder: border,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchConversion,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text('Convert'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
