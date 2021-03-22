import 'package:flutter/material.dart';
import 'package:ihikepakistan/MapState.dart';
import 'package:ihikepakistan/main.dart';
import 'package:ihikepakistan/purchase.dart';
import 'package:provider/provider.dart';

class StatsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapState>(
      builder: (context, mapState, _) => Container(
        color: Color(0xfffff3d6),
        height: 100,
        child: isPro()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoCard(
                      title: 'Climb:', statistic: '${mapState.climb.toInt()}m'),
                  _infoCard(
                      title: 'Distance:',
                      statistic: '${mapState.totalDistance.toInt()}m'),
                  _infoCard(
                      title: 'Av Speed:',
                      statistic: mapState.startTime == null
                          ? '0km/h'
                          : '${(mapState.totalDistance / DateTime.now().difference(mapState.startTime).inSeconds * 3.6).toStringAsFixed(1)}km/h'),
                  _infoCard(
                      title: 'Time:',
                      statistic: mapState.startTime == null
                          ? '00:00:00'
                          : '${_printDuration(
                              DateTime.now().difference(mapState.startTime),
                            )}'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Center(
                  child: ListTile(
                    title: Text(
                        'To see all statistics and trace yourself on the map, Click Here to Upgrade to Ihike Pakistan Pro.'),
                    onTap: () {
                      purchase();
                    },
                  ),
                ),
              ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _infoCard({String title, String statistic}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title),
        Text(
          statistic,
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
