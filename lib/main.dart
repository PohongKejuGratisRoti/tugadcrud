import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CarPage(),
    );
  }
}

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  final String baseUrl = "http://localhost:4000";

  List cars = [];

  final nameCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final idUpdateCtrl = TextEditingController();
  final idDeleteCtrl = TextEditingController();
  final searchNameCtrl = TextEditingController();

  final headers = const {"Content-Type": "application/json"};

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/cars/fetch"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        setState(() => cars = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> createCar() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/cars/create"),
        headers: headers,
        body: jsonEncode({
          "carname": nameCtrl.text,
          "carbrand": brandCtrl.text,
          "carmodel": modelCtrl.text,
          "carprice": priceCtrl.text,
        }),
      );
      fetchCars();
    } catch (e) {
      debugPrint("Create error: $e");
    }
  }

  Future<void> updateCar() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/cars/update"),
        headers: headers,
        body: jsonEncode({
          "id": int.parse(idUpdateCtrl.text),
          "carname": nameCtrl.text,
          "carbrand": brandCtrl.text,
          "carmodel": modelCtrl.text,
          "carprice": priceCtrl.text,
        }),
      );
      fetchCars();
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Future<void> deleteCar() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/cars/delete"),
        headers: headers,
        body: jsonEncode({"id": int.parse(idDeleteCtrl.text)}),
      );
      fetchCars();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  Future<void> searchByName() async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/cars/search/name"),
        headers: headers,
        body: jsonEncode({"carname": searchNameCtrl.text}),
      );

      if (res.statusCode == 200) {
        setState(() => cars = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Widget section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    priceCtrl.dispose();
    idUpdateCtrl.dispose();
    idDeleteCtrl.dispose();
    searchNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Car CRUD – Flutter Web")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            section(
              "Create Car",
              Column(
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: brandCtrl,
                    decoration: const InputDecoration(labelText: "Brand"),
                  ),
                  TextField(
                    controller: modelCtrl,
                    decoration: const InputDecoration(labelText: "Model"),
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: createCar,
                    child: const Text("CREATE"),
                  ),
                ],
              ),
            ),

            section(
              "Update Car",
              Column(
                children: [
                  TextField(
                    controller: idUpdateCtrl,
                    decoration: const InputDecoration(labelText: "ID"),
                  ),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: brandCtrl,
                    decoration: const InputDecoration(labelText: "Brand"),
                  ),
                  TextField(
                    controller: modelCtrl,
                    decoration: const InputDecoration(labelText: "Model"),
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: updateCar,
                    child: const Text("UPDATE"),
                  ),
                ],
              ),
            ),

            section(
              "Delete Car",
              Column(
                children: [
                  TextField(
                    controller: idDeleteCtrl,
                    decoration: const InputDecoration(
                      labelText: "ID to delete",
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: deleteCar,
                    child: const Text("DELETE"),
                  ),
                ],
              ),
            ),

            section(
              "Search by Name",
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchNameCtrl,
                      decoration: const InputDecoration(labelText: "Car name"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: searchByName,
                    child: const Text("SEARCH"),
                  ),
                ],
              ),
            ),

            section(
              "Result",
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cars.length,
                itemBuilder: (context, i) {
                  final c = cars[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c["id"].toString())),
                    title: Text("${c["carname"]} (${c["carmodel"]})"),
                    subtitle: Text(
                      "Brand: ${c["carbrand"]} | Price: ${c["carprice"]}",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
