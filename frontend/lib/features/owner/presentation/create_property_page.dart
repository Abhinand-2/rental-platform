import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/models/create_property_request.dart';
import '../../properties/providers/property_provider.dart';

class CreatePropertyPage extends ConsumerStatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  ConsumerState<CreatePropertyPage> createState() =>
      _CreatePropertyPageState();
}

class _CreatePropertyPageState
    extends ConsumerState<CreatePropertyPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _type = 'APARTMENT';
  bool _isSubmitting = false;

  final List<String> _propertyTypes = [
    'APARTMENT',
    'HOUSE',
    'VILLA',
    'STUDIO',
    'PG',
    'OTHER',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  double? _doubleValue(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  int? _intValue(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rent = double.tryParse(
      _rentController.text.trim(),
    );

    if (rent == null || rent <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid monthly rent'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreatePropertyRequest(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        type: _type,
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        latitude: _doubleValue(
          _latitudeController.text,
        ),
        longitude: _doubleValue(
          _longitudeController.text,
        ),
        bedrooms: _intValue(
          _bedroomsController.text,
        ),
        bathrooms: _intValue(
          _bathroomsController.text,
        ),
        areaSqFt: _doubleValue(
          _areaController.text,
        ),
        monthlyRent: rent,
        securityDeposit: _doubleValue(
          _depositController.text,
        ),
      );

      await ref
          .read(propertyRepositoryProvider)
          .createProperty(request);

     

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Property created successfully. Awaiting approval.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create property: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  String? _requiredValidator(
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Property Information',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: _decoration('Property title'),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _type,
              decoration: _decoration('Property type'),
              items: _propertyTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: _decoration('Description'),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            Text(
              'Location',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: _decoration('Address'),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: _decoration('City'),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stateController,
              decoration: _decoration('State'),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _postalCodeController,
              decoration: _decoration('Postal code'),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 24),

            Text(
              'Property Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration:
                        _decoration('Bedrooms'),
                    keyboardType:
                        TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    decoration:
                        _decoration('Bathrooms'),
                    keyboardType:
                        TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _areaController,
              decoration:
                  _decoration('Area (sq.ft)'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Pricing',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _rentController,
              decoration:
                  _decoration('Monthly rent'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _requiredValidator,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _depositController,
              decoration:
                  _decoration('Security deposit'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Coordinates (optional)',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration:
                        _decoration('Latitude'),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration:
                        _decoration('Longitude'),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Property',
                      ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'New properties are submitted for admin approval before they can be published.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}