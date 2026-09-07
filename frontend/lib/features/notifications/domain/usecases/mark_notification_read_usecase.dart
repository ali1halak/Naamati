import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

@lazySingleton
class MarkNotificationReadUseCase
    implements UseCase<AppNotification, MarkNotificationReadParams> {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, AppNotification>> call(
    MarkNotificationReadParams params,
  ) {
    return repository.markRead(params.id);
  }
}

class MarkNotificationReadParams extends Equatable {
  final int id;

  const MarkNotificationReadParams(this.id);

  @override
  List<Object?> get props => [id];
}
