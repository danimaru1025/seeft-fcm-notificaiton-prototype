import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Web Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;
  String? _lastMessage;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // 通知権限のリクエスト
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('通知権限が許可されました');
      
      // VAPID キーを設定（Firebase Console で取得したキー）
      String? token = await messaging.getToken(
        vapidKey: 'BIBgivxxjDb9O73BehR99dGOIPMJ-xfYzFMrdugfb7BxRyf3nVynQAQ1Ek6C9MY8c5z4gUVIUK3Do7MrVnXWTTM', // ← ここに VAPID キーを設定
      );
      
      setState(() {
        _token = token;
      });
      print('FCM Token: $token');
      
      // フォアグラウンド通知の受信
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('フォアグラウンド通知受信: ${message.notification?.title}');
        setState(() {
          _lastMessage = message.notification?.title ?? 'タイトルなし';
          _messages.insert(0, 
            '${message.notification?.title}: ${message.notification?.body}');
        });
        
        // ブラウザ通知を表示（オプション）
        _showBrowserNotification(message);
      });
      
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('仮の通知権限が許可されました');
    } else {
      print('通知権限が拒否されました');
    }
  }

  void _showBrowserNotification(RemoteMessage message) {
    // Web では自動的に通知が表示されないため、手動で表示
    if (message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${message.notification!.title}\n${message.notification!.body}',
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '閉じる',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Web Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _token ?? '取得中...',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '最後に受信した通知:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _lastMessage ?? 'まだ通知がありません',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              '通知履歴:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text('通知履歴がありません'),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(_messages[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}