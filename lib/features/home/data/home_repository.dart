// Example using a remote data source
import 'package:expense_tracker/features/home/data/home_remote_data_source.dart';

class HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepository({HomeRemoteDataSource? remoteDataSource}) :
        _remoteDataSource = remoteDataSource ?? HomeRemoteDataSource();

  Future<dynamic> fetchHomeData() async {
    try {
      return await _remoteDataSource.getHomeData();
    } catch (e) {
      throw Exception('Failed to fetch home data: $e');
    }
  }
}

// Example remote data source:
class HomeRemoteDataSource {
  Future<dynamic> getHomeData() async {
    // Simulate fetching data (replace with your actual API call)
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return {'message': 'Home data from API'}; // Replace with your actual data
  }
}