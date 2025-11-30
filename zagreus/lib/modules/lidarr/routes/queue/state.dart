import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/api/lidarr/models/queue/queue.dart';

class LidarrQueueState extends ChangeNotifier {
  LidarrQueueState(BuildContext context) {
    fetchQueue(context);
  }

  late Future<LidarrQueuePage> _queue;
  Future<LidarrQueuePage> get queue => _queue;

  Future<void> fetchQueue(BuildContext context) async {
    if (!ZagProfile.current.lidarrEnabled) return;
    _queue = LidarrAPI.from(ZagProfile.current).getQueue(pageSize: 50);
    notifyListeners();
  }
}
