import 'package:flutter/material.dart';
import '../../../../../data/services/user_service.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _userService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text('${user['first_name']} ${user['last_name']}'),
                  subtitle: Text(user['username']),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    // Handle item click
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}
