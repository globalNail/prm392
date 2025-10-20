import 'package:flutter_contacts/flutter_contacts.dart';
import '../../common/result.dart';
import '../../common/app_logger.dart';

/// Repository for contacts operations
class ContactsRepository {
  static final _logger = AppLogger('ContactsRepository');

  /// Check if contacts permission is granted
  Future<bool> hasPermission() async {
    try {
      return await FlutterContacts.requestPermission();
    } catch (e, stackTrace) {
      _logger.error('Error checking contacts permission', e, stackTrace);
      return false;
    }
  }

  /// Request contacts permission
  Future<bool> requestPermission() async {
    try {
      return await FlutterContacts.requestPermission();
    } catch (e, stackTrace) {
      _logger.error('Error requesting contacts permission', e, stackTrace);
      return false;
    }
  }

  /// Get all contacts
  Future<Result<List<Contact>>> getContacts() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return const Failure('Không có quyền truy cập danh bạ');
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      _logger.info('Loaded ${contacts.length} contacts');
      return Success(contacts);
    } catch (e, stackTrace) {
      _logger.error('Error getting contacts', e, stackTrace);
      return Failure('Không thể tải danh bạ', error: e, stackTrace: stackTrace);
    }
  }

  /// Search contacts by query
  Future<Result<List<Contact>>> searchContacts(String query) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return const Failure('Không có quyền truy cập danh bạ');
      }

      final allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final filteredContacts = allContacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery);
      }).toList();

      _logger.info(
        'Found ${filteredContacts.length} contacts matching "$query"',
      );
      return Success(filteredContacts);
    } catch (e, stackTrace) {
      _logger.error('Error searching contacts', e, stackTrace);
      return Failure(
        'Không thể tìm kiếm danh bạ',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
