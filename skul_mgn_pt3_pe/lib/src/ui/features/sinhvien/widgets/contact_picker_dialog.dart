import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Dialog to pick a contact from phone contacts
class ContactPickerDialog extends StatefulWidget {
  const ContactPickerDialog({super.key});

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  List<Contact>? _contacts;
  List<Contact>? _filteredContacts;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Request permission
      final status = await Permission.contacts.request();

      if (status.isGranted) {
        // Load contacts with name and phone numbers
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        // Sort by display name
        contacts.sort(
          (a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),
        );

        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
          _isLoading = false;
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _error =
              'Quyền truy cập danh bạ bị từ chối vĩnh viễn.\nVui lòng mở Cài đặt để cấp quyền.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Cần quyền truy cập danh bạ để sử dụng tính năng này.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải danh bạ: $e';
        _isLoading = false;
      });
    }
  }

  void _filterContacts(String query) {
    if (_contacts == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts!.where((contact) {
          final nameLower = contact.displayName.toLowerCase();
          final queryLower = query.toLowerCase();

          // Search in name
          if (nameLower.contains(queryLower)) return true;

          // Search in phone numbers
          for (final phone in contact.phones) {
            if (phone.number.contains(query)) return true;
          }

          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.contacts,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn từ danh bạ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            if (!_isLoading && _contacts != null)
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc số điện thoại...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterContacts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _filterContacts,
              ),

            const SizedBox(height: 16),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh bạ...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error!.contains('vĩnh viễn'))
                  FilledButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Mở Cài đặt'),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _loadContacts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_filteredContacts == null || _filteredContacts!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Danh bạ trống'
                  : 'Không tìm thấy liên hệ phù hợp',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Contact list
    return ListView.builder(
      itemCount: _filteredContacts!.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts![index];
        return _ContactListTile(
          contact: contact,
          onTap: () => Navigator.of(context).pop(contact),
        );
      },
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const _ContactListTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryPhone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : null;
    final primaryEmail = contact.emails.isNotEmpty
        ? contact.emails.first.address
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            contact.displayName.isNotEmpty
                ? contact.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (primaryPhone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      primaryPhone,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (primaryEmail != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      primaryEmail,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (contact.phones.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${contact.phones.length - 1} số khác',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Result of contact selection with specific phone/email
class ContactSelectionResult {
  final String name;
  final String? phone;
  final String? email;

  ContactSelectionResult({required this.name, this.phone, this.email});
}

/// Show contact picker dialog and allow selection of specific phone/email
Future<ContactSelectionResult?> showContactPicker(BuildContext context) async {
  final contact = await showDialog<Contact>(
    context: context,
    builder: (context) => const ContactPickerDialog(),
  );

  if (contact == null) return null;

  // If contact has multiple phones/emails, let user choose
  if (!context.mounted) return null;

  String? selectedPhone;
  String? selectedEmail;

  // Select phone if available
  if (contact.phones.isNotEmpty) {
    if (contact.phones.length == 1) {
      selectedPhone = contact.phones.first.number;
    } else {
      selectedPhone = await showDialog<String>(
        context: context,
        builder: (context) => _PhonePickerDialog(phones: contact.phones),
      );
    }
  }

  // Select email if available
  if (contact.emails.isNotEmpty) {
    if (contact.emails.length == 1) {
      selectedEmail = contact.emails.first.address;
    } else {
      if (!context.mounted) return null;
      selectedEmail = await showDialog<String>(
        context: context,
        builder: (context) => _EmailPickerDialog(emails: contact.emails),
      );
    }
  }

  return ContactSelectionResult(
    name: contact.displayName,
    phone: selectedPhone,
    email: selectedEmail,
  );
}

class _PhonePickerDialog extends StatelessWidget {
  final List<Phone> phones;

  const _PhonePickerDialog({required this.phones});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn số điện thoại'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: phones.map((phone) {
            return ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone.number),
              subtitle: phone.label.name.isNotEmpty
                  ? Text(phone.label.name)
                  : null,
              onTap: () => Navigator.of(context).pop(phone.number),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}

class _EmailPickerDialog extends StatelessWidget {
  final List<Email> emails;

  const _EmailPickerDialog({required this.emails});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn email'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: emails.map((email) {
            return ListTile(
              leading: const Icon(Icons.email),
              title: Text(email.address),
              subtitle: email.label.name.isNotEmpty
                  ? Text(email.label.name)
                  : null,
              onTap: () => Navigator.of(context).pop(email.address),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}
