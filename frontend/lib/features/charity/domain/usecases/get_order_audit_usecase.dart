import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/charity_order_audit.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class GetOrderAuditUseCase
    implements UseCase<CharityOrderAudit, GetOrderAuditParams> {
  final CharityRepository repository;

  GetOrderAuditUseCase(this.repository);

  @override
  Future<Either<Failure, CharityOrderAudit>> call(GetOrderAuditParams params) {
    return repository.getOrderAudit(params.id);
  }
}

class GetOrderAuditParams extends Equatable {
  final int id;

  const GetOrderAuditParams({required this.id});

  @override
  List<Object?> get props => [id];
}
