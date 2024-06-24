import 'package:flutter/material.dart';
import 'history_screen.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/last_update.dart';
import '../widgets/popular.dart';
import '../widgets/manhwa.dart' as manhwa_widgets;
import '../widgets/manga.dart' as manga_widgets;
import '../widgets/manhua.dart';
import 'package:startapp_sdk/startapp.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();
    loadBannerAd();
  }

  loadBannerAd() {
    // TODO make sure to comment out this line before release
    startAppSdk.setTestAdsEnabled(false);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((value) {
      setState(() {
        bannerAd = value;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KomikApp'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          if (bannerAd != null)
            Center(
              child: Column(
                children: [StartAppBanner(bannerAd!)],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            custom_widgets.SearchBar(),
            SizedBox(height: 20),
            LastUpdate(),
            SizedBox(height: 20),
            Popular(),
            SizedBox(height: 20),
            manhwa_widgets.Manhwa(),
            SizedBox(height: 20),
            manga_widgets.Manga(),
            SizedBox(height: 20),
            Manhua(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
