import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class AddDonationForm extends StatefulWidget {
  const AddDonationForm({super.key});

  @override
  _AddDonationFormState createState() => _AddDonationFormState();
}

class _AddDonationFormState extends State<AddDonationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _foodType = 'Veg';
  DateTime? _bestBefore;
  String _deliveryMethod = 'NGO will come and collect the food';

  String? _pickedAddress;
  LatLng? _pickedLocation;

  // Get Current Location
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _pickedLocation = LatLng(position.latitude, position.longitude);
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _pickedAddress =
      "${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}";
      _addressController.text = _pickedAddress!;
    });
  }

  // Pick Best Before Date and Time
  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _bestBefore = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // Submit Donation
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation Submitted Successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = _bestBefore == null
        ? 'Select Date & Time'
        : DateFormat('dd/MM/yyyy hh:mm a').format(_bestBefore!);

    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          floatingLabelStyle: TextStyle(color: Colors.green), // ✅ Label turns green
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.green), // ✅ Text typed in green
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Excess Food Sharing",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Food Name
                TextFormField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter food name' : null,
                ),
                const SizedBox(height: 16),

                // Food Quantity
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Food Quantity',
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter quantity' : null,
                ),
                const SizedBox(height: 16),

                // Food Type
                DropdownButtonFormField<String>(
                  value: _foodType,
                  decoration: const InputDecoration(
                    labelText: 'Food Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Veg', child: Text('Veg')),
                    DropdownMenuItem(value: 'Non-Veg', child: Text('Non-Veg')),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _foodType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Best Before with Date & Time
                InkWell(
                  onTap: _pickDateTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Best Before',
                    ),
                    child: Text(
                      formattedDateTime,
                      style: TextStyle(
                        color: _bestBefore == null
                            ? Colors.black54
                            : Colors.green, // ✅ text green when selected
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pickup Address
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Pickup Address (Tap map icon to fetch)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.map, color: Colors.green),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please select address' : null,
                ),
                const SizedBox(height: 16),

                // Delivery Method (Only One Option)
                DropdownButtonFormField<String>(
                  value: _deliveryMethod,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Method',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'NGO will come and collect the food',
                      child: Text('NGO will come and collect the food'),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _deliveryMethod = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // ✅ Phone Number (after Delivery Method)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    } else if (value.length < 10) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Donate",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
