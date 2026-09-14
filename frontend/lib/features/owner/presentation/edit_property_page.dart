import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/models/property_model.dart';
import '../../properties/models/update_property_request.dart';
import '../../properties/providers/property_provider.dart';

class EditPropertyPage extends ConsumerStatefulWidget {
  final PropertyModel property;

  const EditPropertyPage({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<EditPropertyPage> createState() =>
      _EditPropertyPageState();
}

class _EditPropertyPageState
    extends ConsumerState<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _areaController;
  late final TextEditingController _rentController;
  late final TextEditingController _depositController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late String _type;
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
  void initState() {
    super.initState();

    final property = widget.property;

    _titleController =
        TextEditingController(text: property.title);
    _descriptionController =
        TextEditingController(text: property.description ?? '');
    _addressController =
        TextEditingController(text: property.addressLine);
    _cityController =
        TextEditingController(text: property.city);
    _stateController =
        TextEditingController(text: property.state);
    _postalCodeController =
        TextEditingController(text: property.postalCode);

    _bedroomsController = TextEditingController(
      text: property.bedrooms?.toString() ?? '',
    );

    _bathroomsController = TextEditingController(
      text: property.bathrooms?.toString() ?? '',
    );

    _areaController = TextEditingController(
      text: property.areaSqFt?.toString() ?? '',
    );

    _rentController = TextEditingController(
      text: property.monthlyRent.toString(),
    );

    _depositController = TextEditingController(
      text: property.securityDeposit?.toString() ?? '',
    );

    _latitudeController = TextEditingController(
      text: property.latitude?.toString() ?? '',
    );

    _longitudeController = TextEditingController(
      text: property.longitude?.toString() ?? '',
    );

    _type = property.type;
  }

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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rent =
        double.tryParse(_rentController.text.trim());

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
      final request = UpdatePropertyRequest(
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
        latitude:
            _doubleValue(_latitudeController.text),
        longitude:
            _doubleValue(_longitudeController.text),
        bedrooms:
            _intValue(_bedroomsController.text),
        bathrooms:
            _intValue(_bathroomsController.text),
        areaSqFt:
            _doubleValue(_areaController.text),
        monthlyRent: rent,
        securityDeposit:
            _doubleValue(_depositController.text),
      );

      await ref
          .read(propertyRepositoryProvider)
          .updateProperty(
            widget.property.id,
            request,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property updated successfully'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update property: $e',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: _decoration('Property title'),
              validator: _required,
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

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: _decoration('Address'),
              validator: _required,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: _decoration('City'),
              validator: _required,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _stateController,
              decoration: _decoration('State'),
              validator: _required,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _postalCodeController,
              decoration: _decoration('Postal code'),
              validator: _required,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration: _decoration('Bedrooms'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    decoration: _decoration('Bathrooms'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _areaController,
              decoration: _decoration('Area (sq.ft)'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _rentController,
              decoration: _decoration('Monthly rent'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _required,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _depositController,
              decoration: _decoration('Security deposit'),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: _decoration('Latitude'),
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
                    decoration: _decoration('Longitude'),
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
                    _isSubmitting ? null : _update,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}