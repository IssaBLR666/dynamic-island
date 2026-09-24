import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void main() => runApp(const MyApp());

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: IslandOverlayWidget()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const MainControlScreen());
}

class MainControlScreen extends StatefulWidget {
  const MainControlScreen({super.key});
  @override
  State<MainControlScreen> createState() => _MainControlScreenState();
}

class _MainControlScreenState extends State<MainControlScreen> {
  bool _hasPermission = false;
  @override
  void initState() { super.initState(); _checkPermission(); }
  void _checkPermission() async {
    final status = await FlutterOverlayWindow.isPermissionGranted();
    setState(() { _hasPermission = status; });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dynamic Island Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_hasPermission ? '✅ Разрешение получено' : '❌ Требуется разрешение', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: _hasPermission ? Colors.green : Colors.red)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () async { await FlutterOverlayWindow.requestPermission(); _checkPermission(); }, child: const Text('1. Дать разрешение оверлея')),
            const SizedBox(height: 15),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () async {
              if (await FlutterOverlayWindow.isPermissionGranted()) {
                await FlutterOverlayWindow.showOverlay(enableDrag: false, overlayTitle: "Dynamic Island", alignment: OverlayAlignment.topCenter, flag: OverlayFlag.defaultFlag);
              }
            }, child: const Text('2. Включить Остров')),
            const SizedBox(height: 15),
            TextButton(onPressed: () => FlutterOverlayWindow.closeOverlay(), child: const Text('Выключить Остров', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}

class IslandOverlayWidget extends StatefulWidget {
  const IslandOverlayWidget({super.key});
  @override
  State<IslandOverlayWidget> createState() => _IslandOverlayWidgetState();
}

class _IslandOverlayWidgetState extends State<IslandOverlayWidget> {
  String _currentView = 'compact';
  double _offsetTop = 10.0;
  double _compactWidth = 110.0;
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    double width = _compactWidth; double height = 30.0;
    if (_currentView == 'call' || _currentView == 'music' || _currentView == 'notify') {
      width = MediaQuery.of(context).size.width * 0.92; if (width > 350) width = 350;
    } else if (_currentView == 'battery') { width = 240.0; } else if (_currentView == 'lock') { width = 50.0; }

    if (_currentView == 'call') height = 75.0;
    if (_currentView == 'music') height = 175.0;
    if (_currentView == 'battery') height = 38.0;
    if (_currentView == 'lock') height = 35.0;
    if (_currentView == 'notify') height = 65.0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: _offsetTop, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () { if (_currentView != 'compact') setState(() { _currentView = 'compact'; }); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400), curve: Curves.elasticOut,
                  width: width, height: height,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(_currentView == 'music' ? 32 : 20)),
                  child: _buildIslandContent(),
                ),
              ),
            ),
          ),
          Positioned(bottom: 20, left: 15, right: 15, child: _buildSystemControls()),
        ],
      ),
    );
  }

  Widget _buildIslandContent() {
    switch (_currentView) {
      case 'compact':
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 15), decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle))]);
      case 'music':
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: const DecorationImage(image: NetworkImage('https://unsplash.com'), fit: BoxFit.cover))),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Blinding Lights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text('The Weeknd', style: TextStyle(color: Colors.grey, fontSize: 12))])),
                  Icon(Icons.bar_chart, color: _isPlaying ? Colors.green : Colors.grey),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                  IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: () => setState(() { _isPlaying = !_isPlaying; })),
                  IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: () {}),
                ],
              )
            ],
          ),
        );
      case 'battery':
        return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.between, children: [Text('Зарядка', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), Row(children: [Text('75%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.battery_charging_full, color: Colors.green, size: 20)])]));
      case 'notify':
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFF2481CC), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.send, color: Colors.white, size: 16)), const SizedBox(width: 12), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Telegram', style: TextStyle(color: Color(0xFF2481CC), fontWeight: FontWeight.bold, fontSize: 13)), Text('Привет! Изменения применились! 🔥', style: TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1)]))]));
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildSystemControls() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(children: [const SizedBox(width: 100, child: Text('Вверх/Вниз:', style: TextStyle(fontSize: 12))), Expanded(child: Slider(value: _offsetTop, min: 0, max: 80, onChanged: (val) => setState(() { _offsetTop = val; })))]),
            Row(children: [const SizedBox(width: 100, child: Text('Ширина:', style: TextStyle(fontSize: 12))), Expanded(child: Slider(value: _compactWidth, min: 80, max: 200, onChanged: (val) => setState(() { _compactWidth = val; })))]),
          ]),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          _btn('Звонок', () => setState(() { _currentView = 'call'; })),
          _btn('Музыка', () => setState(() { _currentView = 'music'; })),
          _btn('Зарядка', () => setState(() { _currentView = 'battery'; })),
          _btn('Пуш', () => setState(() { _currentView = 'notify'; })),
          _btn('Свернуть', () => setState(() { _currentView = 'compact'; })),
        ])
      ],
    );
  }
  Widget _btn(String l, VoidCallback a) => ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white12), onPressed: a, child: Text(l, style: const TextStyle(fontSize: 12)));
}
