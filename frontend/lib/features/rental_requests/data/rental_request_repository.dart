import '../models/create_rental_request.dart';
import '../models/rental_request_model.dart';
import 'rental_request_api.dart';

class RentalRequestRepository {
  final RentalRequestApi rentalRequestApi;

  RentalRequestRepository(this.rentalRequestApi);

  Future<RentalRequestModel> createRentalRequest(
    CreateRentalRequest request,
  ) async {
    return await rentalRequestApi.createRentalRequest(
      request,
    );
  }

Future<List<RentalRequestModel>> getOwnerRentalRequests() {
  return rentalRequestApi.getOwnerRentalRequests();
}

Future<RentalRequestModel> approveRentalRequest(
  String requestId,
) {
  return rentalRequestApi.approveRentalRequest(requestId);
}

Future<RentalRequestModel> rejectRentalRequest(
  String requestId,
) {
  return rentalRequestApi.rejectRentalRequest(requestId);
}

  Future<List<RentalRequestModel>>
      getMyRentalRequests() async {
    return await rentalRequestApi
        .getMyRentalRequests();
  }
}