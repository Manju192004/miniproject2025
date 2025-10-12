import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- AddDonationForm Widget ---
class AddDonationForm extends StatefulWidget {
  const AddDonationForm({super.key});

  @override
  _AddDonationFormState createState() => _AddDonationFormState();
}

class _AddDonationFormState extends State<AddDonationForm> {
  final _formKey = GlobalKey<FormState>();

  // Mock Donor Details (Replace with FirebaseAuth)
  final String _currentDonorId = "donor_uid_12345";
  final String _currentDonorName = "John Doe";

  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _foodType = 'Veg';
  DateTime? _bestBefore;
  String _deliveryMethod = 'NGO will come and collect the food';
  LatLng? _pickedLocation;
  bool _isSubmitting = false;

  // Pick address from map
  Future<void> _pickAddressOnMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        _pickedLocation = result['latLng'];
        _addressController.text = result['address'];
      });
    }
  }

  // Pick date & time
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

  // Submit donation
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a pickup address.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_bestBefore == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select best before date and time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        await FirebaseFirestore.instance.collection('adddonation').add({
          'donorId': _currentDonorId,
          'donorName': _currentDonorName,
          'status': 'Pending',
          'foodName': _foodNameController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'foodType': _foodType,
          'bestBefore': _bestBefore, // DateTime object (will be stored as Timestamp in Firestore)
          'deliveryMethod': _deliveryMethod,
          'phoneNumber': _phoneController.text.trim(),
          'pickupAddress': _addressController.text.trim(),
          'pickupLocation': GeoPoint(
              _pickedLocation!.latitude, _pickedLocation!.longitude),
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation Submitted Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _foodNameController.clear();
    _quantityController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() {
      _foodType = 'Veg';
      _bestBefore = null;
      _deliveryMethod = 'NGO will come and collect the food';
      _pickedLocation = null;
    });
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // 🟢 Header Container Added Here
  Widget _buildAppHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 45, bottom: 16),
      color: Colors.green[700],
      child: Column(
        children: const [
          Text(
            'Excess Food Share',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add Donation',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDateTime = _bestBefore == null
        ? 'Select Date & Time'
        : DateFormat('dd/MM/yyyy hh:mm a').format(_bestBefore!);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            _buildAppHeader(), // 🟢 Added Header Here
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _foodNameController,
                        decoration:
                        const InputDecoration(labelText: 'Food Name'),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter food name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration:
                        const InputDecoration(labelText: 'Food Quantity'),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter quantity' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _foodType,
                        decoration:
                        const InputDecoration(labelText: 'Food Type'),
                        items: const [
                          DropdownMenuItem(value: 'Veg', child: Text('Veg')),
                          DropdownMenuItem(
                              value: 'Non-Veg', child: Text('Non-Veg')),
                        ],
                        onChanged: (newValue) =>
                            setState(() => _foodType = newValue!),
                      ),
                      const SizedBox(height: 16),
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
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Pickup Address',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map, color: Colors.green),
                            onPressed: _pickAddressOnMap,
                          ),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Please select address' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _deliveryMethod,
                        decoration: const InputDecoration(
                            labelText: 'Delivery Method'),
                        items: const [
                          DropdownMenuItem(
                            value: 'NGO will come and collect the food',
                            child: Text('NGO will come and collect the food'),
                          ),
                        ],
                        onChanged: (newValue) =>
                            setState(() => _deliveryMethod = newValue!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                        const InputDecoration(labelText: 'Phone Number'),
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
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          "Donate",
                          style: TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- MapScreen Widget (Unchanged) ---
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  String _selectedAddress = "Tap on the map to select a location";
  bool _isLoading = true;

  CameraPosition _initialCameraPosition =
  const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5.0);

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      _onMapTapped(currentLatLng);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15.0));
      setState(() {
        _isLoading = false;
        _initialCameraPosition = CameraPosition(target: currentLatLng, zoom: 15.0);
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress = "${place.name}, ${place.locality}, ${place.country}";
        });
      }
    } catch (_) {
      setState(() {
        _selectedAddress = "Address not found";
      });
    }
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _selectedMarker = Marker(
        markerId: const MarkerId('selected-location'),
        position: latLng,
      );
      _getAddressFromLatLng(latLng);
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latLng': _selectedLocation,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header for Map Screen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.green[700],
            child: Column(
              children: const [
                Text(
                  'Excess Food Share',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select Pickup Address',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
                : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: _initialCameraPosition,
                  onTap: _onMapTapped,
                  markers:
                  _selectedMarker != null ? {_selectedMarker!} : {},
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            _selectedAddress,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _confirmLocation,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text("Confirm Location",
                                style:
                                TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}