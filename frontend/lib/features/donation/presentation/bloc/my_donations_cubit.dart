import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_status.dart';
import '../../domain/usecases/get_my_donations_usecase.dart';
import 'my_donations_state.dart';

@injectable
class MyDonationsCubit extends Cubit<MyDonationsState> {
  final GetMyDonationsUseCase _getMyDonationsUseCase;

  MyDonationsCubit(this._getMyDonationsUseCase) : super(const MyDonationsState());

  /// Loads (or reloads) the donor's donations list.
  Future<void> loadDonations({DonationStatus? status}) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getMyDonationsUseCase(GetMyDonationsParams(status: status));

    result.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, errorMessage: failure.message)),
      (donations) => emit(state.copyWith(status: BlocStatus.success, donations: donations)),
    );
  }
}
