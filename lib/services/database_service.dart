import 'package:mongo_dart/mongo_dart.dart';
import '../models/emergency_service.dart';
import '../config/api_config.dart';

/// Сервис для работы с MongoDB
class DatabaseService {
  static Db? _db;
  static DbCollection? _servicesCollection;
  
  /// Инициализация подключения к MongoDB
  static Future<void> connect() async {
    if (!ApiConfig.hasMongodbUri) {
      throw Exception('MongoDB URI not configured');
    }

    try {
      _db = await Db.create(ApiConfig.mongodbUri);
      await _db!.open();
      
      _servicesCollection = _db!.collection('emergency_services');
      
      // Создание индекса для геолокации
      await _servicesCollection!.createIndex(
        keys: {'latitude': 1, 'longitude': 1},
      );
      
      print('✅ Connected to MongoDB');
    } catch (e) {
      print('❌ MongoDB connection error: $e');
      throw Exception('Failed to connect to MongoDB: $e');
    }
  }

  /// Закрыть подключение к MongoDB
  static Future<void> close() async {
    await _db?.close();
    _db = null;
    _servicesCollection = null;
  }

  /// Проверка подключения
  static bool get isConnected => _db != null && _db!.isConnected;

  /// Сохранить экстренную службу
  static Future<void> saveService(EmergencyService service) async {
    if (!isConnected) await connect();
    
    try {
      await _servicesCollection!.replaceOne(
        where.eq('_id', service.id),
        service.toMongoJson(),
        upsert: true,
      );
    } catch (e) {
      print('Error saving service: $e');
      throw Exception('Failed to save service: $e');
    }
  }

  /// Сохранить несколько служб
  static Future<void> saveServices(List<EmergencyService> services) async {
    if (!isConnected) await connect();
    
    try {
      // Выполняем upsert для каждой службы по очереди
      for (final service in services) {
        await _servicesCollection!.replaceOne(
          where.eq('_id', service.id),
          service.toMongoJson(),
          upsert: true,
        );
      }
    } catch (e) {
      print('Error saving services: $e');
      throw Exception('Failed to save services: $e');
    }
  }

  /// Получить службу по ID
  static Future<EmergencyService?> getService(String id) async {
    if (!isConnected) await connect();
    
    try {
      final result = await _servicesCollection!.findOne(where.eq('_id', id));
      if (result == null) return null;
      
      return EmergencyService.fromMongoJson(result);
    } catch (e) {
      print('Error fetching service: $e');
      return null;
    }
  }

  /// Получить все службы определенного типа
  static Future<List<EmergencyService>> getServicesByType(String type) async {
    if (!isConnected) await connect();
    
    try {
      final results = await _servicesCollection!
          .find(where.eq('type', type))
          .toList();
      
      return results
          .map((json) => EmergencyService.fromMongoJson(json))
          .toList();
    } catch (e) {
      print('Error fetching services by type: $e');
      return [];
    }
  }

  /// Получить ближайшие службы
  /// 
  /// Примечание: Для точного геопространственного поиска нужно использовать
  /// MongoDB геопространственные индексы. Это упрощенная версия.
  static Future<List<EmergencyService>> getNearbyServices({
    required double latitude,
    required double longitude,
    String? type,
    int limit = 10,
  }) async {
    if (!isConnected) await connect();
    
    try {
      var query = where;
      
      if (type != null) {
        query = query.eq('type', type);
      }
      
      // Получаем все службы и сортируем по расстоянию в памяти
      // Для production лучше использовать $near или $geoNear
      final results = await _servicesCollection!.find(query).toList();
      
      final services = results
          .map((json) => EmergencyService.fromMongoJson(json))
          .toList();
      
      // Сортировка по расстоянию
      services.sort((a, b) {
        final distA = a.distanceTo(latitude, longitude);
        final distB = b.distanceTo(latitude, longitude);
        return distA.compareTo(distB);
      });
      
      return services.take(limit).toList();
    } catch (e) {
      print('Error fetching nearby services: $e');
      return [];
    }
  }

  /// Получить все службы
  static Future<List<EmergencyService>> getAllServices() async {
    if (!isConnected) await connect();
    
    try {
      final results = await _servicesCollection!.find().toList();
      
      return results
          .map((json) => EmergencyService.fromMongoJson(json))
          .toList();
    } catch (e) {
      print('Error fetching all services: $e');
      return [];
    }
  }

  /// Удалить службу по ID
  static Future<bool> deleteService(String id) async {
    if (!isConnected) await connect();
    
    try {
      final result = await _servicesCollection!.deleteOne(where.eq('_id', id));
      final deleted = result.nRemoved;
      return deleted > 0;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  /// Удалить все службы
  static Future<void> deleteAllServices() async {
    if (!isConnected) await connect();
    
    try {
      await _servicesCollection!.deleteMany(where);
    } catch (e) {
      print('Error deleting all services: $e');
      throw Exception('Failed to delete services: $e');
    }
  }

  /// Обновить статус службы (открыта/закрыта)
  static Future<void> updateServiceStatus(String id, bool isOpen) async {
    if (!isConnected) await connect();
    
    try {
      await _servicesCollection!.updateOne(
        where.eq('_id', id),
        modify.set('isOpen', isOpen).set('updatedAt', DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Error updating service status: $e');
      throw Exception('Failed to update service: $e');
    }
  }

  /// Получить статистику по типам служб
  static Future<Map<String, int>> getServiceStats() async {
    if (!isConnected) await connect();
    
    try {
      final pipeline = [
        {
          '\$group': {
            '_id': '\$type',
            'count': {'\$sum': 1}
          }
        }
      ];
      
      final results = await _servicesCollection!.aggregateToStream(pipeline).toList();
      
      final stats = <String, int>{};
      for (final result in results) {
        stats[result['_id'] as String] = result['count'] as int;
      }
      
      return stats;
    } catch (e) {
      print('Error fetching stats: $e');
      return {};
    }
  }
}
