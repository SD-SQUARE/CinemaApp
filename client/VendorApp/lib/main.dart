
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vendorapp/services/notification_service.dart';
import 'package:vendorapp/services/supabase_client.dart';
import 'package:vendorapp/utils/permission_handler.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VendorApp',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('VendorApp'),
        ),
        body: Center(
          child: InkWell(
             onTap: ()async{
               // Test notification and supabase
               print("notification sent");
               var data = await SupabaseService.client.from("test").select("message");
               NotificationService.showNotification(id: Random().nextInt(99), title: "Hello", body: data.toList()[0].toString());
             },
              child: const Text('Flutter Home Page')),
        ),
      )
    );
  }
}
