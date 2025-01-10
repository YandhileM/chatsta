import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../data/services/user_service.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _futureUsers;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _futureUsers = _userService.fetchUsers();
  }

  String getRandomAsset() {
    // Generate a random asset file name from 1.png to 10.png
    int assetNumber = _random.nextInt(20) + 1;
    return 'assets/$assetNumber.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello User',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
            ),
            Text(
              'Chatsta',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit_square,
                color: Colors.grey,
              ),
            ),
          )
        ],
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final asset = getRandomAsset();

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          onTap: () {
                            // Handle navigation to user details or chat
                          },
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(asset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            '${user['first_name']} ${user['last_name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(user['username']),
                          trailing: const Icon(Icons.add),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}
