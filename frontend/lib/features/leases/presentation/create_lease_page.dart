import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rental_requests/models/rental_request_model.dart';
import '../providers/lease_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../properties/providers/property_provider.dart';
import '../../rental_requests/providers/rental_request_provider.dart';
import '../../rent/providers/rent_provider.dart';

class CreateLeasePage extends ConsumerStatefulWidget {
  final RentalRequestModel rentalRequest;

  const CreateLeasePage({
    super.key,
    required this.rentalRequest,
  });

  @override
  ConsumerState<CreateLeasePage> createState() =>
      _CreateLeasePageState();
}

class _CreateLeasePageState
    extends ConsumerState<CreateLeasePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _rentController;
  late final TextEditingController _depositController;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _rentController = TextEditingController();
    _depositController = TextEditingController();
  }

  @override
  void dispose() {
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;

      if (_endDate != null &&
          !_endDate!.isAfter(selected)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select the lease start date first.',
          ),
        ),
      );
      return;
    }

    final minimumDate =
        _startDate!.add(const Duration(days: 1));

    final selected = await showDatePicker(
      context: context,
      initialDate: minimumDate,
      firstDate: minimumDate,
      lastDate: DateTime(
        _startDate!.year + 10,
      ),
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _createLease() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select both start and end dates.',
          ),
        ),
      );
      return;
    }

    final monthlyRent =
        double.tryParse(_rentController.text.trim());

    if (monthlyRent == null || monthlyRent <= 0) {
      return;
    }

    double? securityDeposit;

    if (_depositController.text.trim().isNotEmpty) {
      securityDeposit =
          double.tryParse(
            _depositController.text.trim(),
          );

      if (securityDeposit == null ||
          securityDeposit < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enter a valid security deposit.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository =
          ref.read(leaseRepositoryProvider);

      await repository.createLease(
        rentalRequestId:
            widget.rentalRequest.id,
        startDate:
            _formatDate(_startDate),
        endDate:
            _formatDate(_endDate),
        monthlyRent: monthlyRent,
        securityDeposit: securityDeposit,
      );

      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.invalidate(ownerPropertiesProvider(user.id));
      }
      ref.invalidate(ownerRentalRequestsProvider);
      ref.invalidate(ownerLeasesProvider);
      ref.invalidate(ownerRentChargesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lease created successfully.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create lease: $e',
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
    final request = widget.rentalRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lease'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Request',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      request.displayPropertyTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tenant: ${request.displayApplicantName}',
                    ),
                    if (request.applicantEmail != null) ...[
                      const SizedBox(height: 6),
                      Text('Email: ${request.applicantEmail}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Lease Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _rentController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly Rent',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Monthly rent is required';
                }

                final amount =
                    double.tryParse(value.trim());

                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _depositController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Security Deposit',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return null;
                }

                final amount =
                    double.tryParse(value.trim());

                if (amount == null || amount < 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            _DateSelector(
              label: 'Lease Start Date',
              value: _formatDate(_startDate),
              onPressed: _selectStartDate,
            ),

            const SizedBox(height: 12),

            _DateSelector(
              label: 'Lease End Date',
              value: _formatDate(_endDate),
              onPressed: _selectEndDate,
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed:
                    _isSubmitting ? null : _createLease,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Lease',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onPressed;

  const _DateSelector({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon:
              const Icon(Icons.calendar_today),
        ),
        child: Text(value),
      ),
    );
  }
}