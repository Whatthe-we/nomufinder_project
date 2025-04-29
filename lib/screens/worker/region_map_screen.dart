import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_nomufinder/screens/lawyer_search/lawyer_list_screen.dart';
import 'package:project_nomufinder/services/lawyer_data_loader.dart';

class RegionMapScreen extends StatefulWidget {
  const RegionMapScreen({Key? key}) : super(key: key);

  @override
  _RegionMapScreenState createState() => _RegionMapScreenState();
}

class _RegionMapScreenState extends State<RegionMapScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(36.5, 127.5); // 대한민국 중심

  final Map<String, LatLng> regionMarkers = {
    '서울': LatLng(37.5665, 126.9780),
    '경기': LatLng(37.4138, 127.5183),
    '인천/부천': LatLng(37.4563, 126.7052),
    '춘천/강원': LatLng(37.8813, 127.7298),
    '대전/충남/세종': LatLng(36.3504, 127.3845),
    '전주/전북/광주/전남': LatLng(35.8210, 127.1480),
    '부산/울산/경남': LatLng(35.1796, 129.0756),
    '대구/경북': LatLng(35.8722, 128.6025),
    '제주': LatLng(33.4996, 126.5312),
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지역 선택 지도')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 7.0,
        ),
        markers: regionMarkers.entries.map((entry) {
          return Marker(
            markerId: MarkerId(entry.key),
            position: entry.value,
            infoWindow: InfoWindow(
              title: entry.key,
              onTap: () {
                final lawyers = lawyersByRegion[entry.key] ?? [];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerListScreen(
                      title: entry.key,
                      category: entry.key,
                      lawyers: lawyers,
                    ),
                  ),
                );
              },
            ),
          );
        }).toSet(),
      ),
    );
  }
}