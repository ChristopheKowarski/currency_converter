import 'dart:ui';
import 'package:country/country.dart';
import 'package:currency_converter/utils/conversion.dart' as conversion;
import 'package:currency_converter/utils/location.dart';
import 'package:currency_converter/utils/secrets.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

conversion.CurrencyConvert currencyConvertFromJson(String str) =>
    conversion.CurrencyConvert.fromJson(json.decode(str.toString()));

String currencyConvertToJson(conversion.CurrencyConvert data) =>
    json.encode(data.toJson());

final location = MyLocation();

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  final TextEditingController textEditingController = TextEditingController();
  late Future<double> futureCurrency;
  late Future<Map<String, dynamic>> weather;
  String start = 'AUD';
  String end = 'EUR';
  String currencyName = conversion.currenciesSymbolsMap.keys.elementAt(8);
  String currencySymbol = conversion.currenciesSymbolsMap.values.elementAt(8);
  String dropdownValueFrom = conversion.currenciesSymbolsMap.keys.elementAt(0);
  String dropdownValueTo = conversion.currenciesSymbolsMap.keys.elementAt(8);
  String currentCurrencyName = "";
  String currentCurrencySymbol = "";
  // double fromConversion = 0.0;
  // double toConversion = 0.0;
  // double amountConversion = 0.0;
  Map<String, String> currencySymbolMap = conversion.currenciesSymbolsMap;
  late Position? position;
  LocationPermission? permission;
  String? currentAddress;
  String? countryCode;
  String? country;
  final double kelvinToCelcius = 273.15;

  @override
  void initState() {
    super.initState();
    conversion.fetchData();
    conversion.convert(
        dropdownValueFrom, dropdownValueTo, 0.0, dropdownValueTo);
    getLocation();
    weather = getCurrentWeather();
  }

  void changedState() {
    double amount = 0.0;
    String thisCurrency = "";
    currentCurrencySymbol = "";

    if (textEditingController.text != "") {
      amount = double.parse(textEditingController.text);
    }
    thisCurrency = getCurrency(countryCode);
    currentCurrencySymbol =
        conversion.currenciesSymbolsMap[thisCurrency] as String;

    // conversion.convert(
    //     dropdownValueFrom, dropdownValueTo, amount, dropdownValueFrom);
    if (dropdownValueFrom != thisCurrency && dropdownValueTo != thisCurrency) {
      conversion.thirdNeeded = true;
      conversion.convert(
          dropdownValueFrom, dropdownValueTo, amount, thisCurrency);
    }
    setState(() {});
  }

  String getCurrency(thisCurrencyCode) {
    for (final thisCountry in Countries.values) {
      if (thisCountry.alpha2 == thisCurrencyCode) {
        return thisCountry.currencyCode;
      }
    }
    return "";
  }

  void getLocation() async {
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled');
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Locations permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Locations permissions are permanently denied. Cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentAddress =
        await placemarkFromCoordinates(position!.latitude, position!.longitude)
            .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      currentAddress = '${place.postalCode}, ${place.country}';
      country = place.country;
      countryCode = place.isoCountryCode;
      setState(() {});
      return currentAddress;
    });
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      final resultWeather = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&APPID=$OPEN_WEATHER_API_KEY',
        ),
      );
      final weatherData = jsonDecode(resultWeather.body);
      if (weatherData['cod'] != 200) {
        throw 'An error occurred!';
      }
      countryCode = weatherData['sys']['country'];
      return weatherData;
    } catch (e) {
      throw e.toString();
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
      backgroundColor: Colors.teal.shade700,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        title: const Text(
          'Travel Dashboard',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                          future: weather,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator.adaptive());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.error.toString()));
                            }

                            final data = snapshot.data!;

                            String currentSky = data['weather'][0]['main'];
                            double currentTempDouble = data['main']['temp'];
                            currentTempDouble -= kelvinToCelcius;
                            String currentTemp =
                                currentTempDouble.toStringAsFixed(1);
                            String currentCity = data['name'];
                            String currentCountry = data['sys']['country'];
                            countryCode = currentCountry;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Main Card
                                  SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '$currentCity, $currentCountry',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '$currentTemp °C',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Icon(
                                                  currentSky == 'Sunny'
                                                      ? Icons.sunny
                                                      : currentSky == "Clouds"
                                                          ? Icons.cloud
                                                          : currentSky == 'Rain'
                                                              ? Icons.shower
                                                              : Icons.air,
                                                  size: 64,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  currentSky,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // DropdownButton(items: items, onChanged: onChanged),
                            DropdownButton(
                              value: dropdownValueFrom.isNotEmpty
                                  ? dropdownValueFrom
                                  : "",
                              icon: const Icon(Icons.keyboard_arrow_down),
                              dropdownColor: Colors.blueGrey[600],
                              items: [
                                for (MapEntry<String, String> e
                                    in conversion.currenciesSymbolsMap.entries)
                                  DropdownMenuItem(
                                    value: e.key,
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (newValue) {
                                if (conversion.currentCountry ==
                                        dropdownValueFrom ||
                                    conversion.currentCountry ==
                                        dropdownValueTo) {
                                  conversion.thirdNeeded = false;
                                }

                                dropdownValueFrom = newValue.toString();
                                changedState();
                              },
                            ),
                            const Text(
                              "-->",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            DropdownButton(
                              value: dropdownValueTo.isNotEmpty
                                  ? dropdownValueTo
                                  : "",
                              icon: const Icon(Icons.keyboard_arrow_down),
                              dropdownColor: Colors.blueGrey[600],
                              items: [
                                for (MapEntry<String, String> e
                                    in conversion.currenciesSymbolsMap.entries)
                                  DropdownMenuItem(
                                    value: e.key,
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (newValue) {
                                if (conversion.currentCountry ==
                                        dropdownValueFrom ||
                                    conversion.currentCountry ==
                                        dropdownValueTo) {
                                  conversion.thirdNeeded = false;
                                }

                                setState(() {
                                  dropdownValueTo = newValue.toString();
                                  changedState();
                                  currencySymbol = conversion
                                      .currenciesSymbolsMap[dropdownValueTo]!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  // convertDefault(),
                  '$currencySymbol${conversion.convertResult.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                if (conversion.thirdNeeded &&
                    conversion.currentCountry != dropdownValueFrom &&
                    conversion.currentCountry != dropdownValueTo) ...[
                  Text(
                    '$currentCurrencySymbol${conversion.convertLocale.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
                TextField(
                  controller: textEditingController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Please enter the amount in $dropdownValueFrom',
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
                  onPressed: changedState,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Convert',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
