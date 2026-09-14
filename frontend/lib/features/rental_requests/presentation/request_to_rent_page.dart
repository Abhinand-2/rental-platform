import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/create_rental_request.dart';
import '../providers/rental_request_provider.dart';

class RequestToRentPage extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const RequestToRentPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  ConsumerState<RequestToRentPage> createState() =>
      _RequestToRentPageState();
}

class _RequestToRentPageState
    extends ConsumerState<RequestToRentPage> {
  final _formKey = GlobalKey<FormState>();

  final _messageController = TextEditingController();

  DateTime? _requestedStartDate;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 2,
        now.month,
        now.day,
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _requestedStartDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_requestedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your requested start date.',
          ),
        ),
      );
      return;
    }

    await ref
        .read(rentalRequestNotifierProvider.notifier)
        .create(
          CreateRentalRequest(
            propertyId: widget.propertyId,
            message:
                _messageController.text.trim().isEmpty
                    ? null
                    : _messageController.text.trim(),
            requestedStartDate: _requestedStartDate!,
          ),
        );

    if (!mounted) {
      return;
    }

    final requestState =
        ref.read(rentalRequestNotifierProvider);

    if (requestState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requestState.error.toString(),
          ),
        ),
      );

      return;
    }

    if (requestState.value != null) {
      ref.invalidate(myRentalRequestsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Rental request submitted successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestState =
        ref.watch(rentalRequestNotifierProvider);

    final isLoading = requestState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request to Rent'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                widget.propertyTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 24),

              Text(
                'Requested Start Date',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: isLoading
                    ? null
                    : _selectDate,
                borderRadius:
                    BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _requestedStartDate == null
                        ? 'Select date'
                        : '${_requestedStartDate!.day.toString().padLeft(2, '0')}/'
                            '${_requestedStartDate!.month.toString().padLeft(2, '0')}/'
                            '${_requestedStartDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Message',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 500,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText:
                      'Tell the owner anything relevant about your rental request...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Rental Request',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}