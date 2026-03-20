import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../data/datasources/reel_remote_datasource.dart';
import '../../data/repositories/reel_repository_impl.dart';
import '../../domain/repositories/reel_repository.dart';
import '../../domain/usecases/get_reels_usecase.dart';
import '../../presentation/controllers/reel_controller.dart';
import '../constants/app_constants.dart';

class AppInjection {
  AppInjection._();

  static void init() {
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance,
      fenix: true,
    );

    Get.lazyPut<CacheManager>(
          () => CacheManager(
        Config(
          'reels_cache',
          stalePeriod: const Duration(days: AppConstants.cacheStalePeriod),
          maxNrOfCacheObjects: 30,
        ),
      ),
      fenix: true,
    );

    // Data layer
    Get.lazyPut<ReelRemoteDataSource>(() => ReelRemoteDataSourceImpl(Get.find<FirebaseFirestore>()),
      fenix: true,
    );

    Get.lazyPut<ReelRepository>(
          () => ReelRepositoryImpl(Get.find<ReelRemoteDataSource>()),
      fenix: true,
    );

    // Domain layer
    Get.lazyPut<GetReelsUseCase>(
            () => GetReelsUseCase(Get.find<ReelRepository>()),
      fenix: true,
    );

    // Presentation layer
    Get.lazyPut<ReelController>(
          () => ReelController(Get.find<GetReelsUseCase>(), Get.find<CacheManager>()),
      fenix: true,
    );
  }
}
