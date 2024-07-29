import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:movemore/domain/statistic/statistic.dart';
import 'package:movemore/general/timeframe/timeframe.dart';
import 'package:movemore/domain/network/dio_provider.dart';

final statisticService = StatisticService();

class StatisticService {
  Future<List<StatisticPacket>> getStatisticPacket({
    required int exerciseId,
    required StatisticTimeframe timeframe,
    required int comparedUserId,
    DateTime? firstKnown,
  }) async {
    final queryParameters = {
      'timespan': timeframe.technicalName,
      'comparedUser': comparedUserId,
    };
    if (firstKnown != null) {
      queryParameters['firstKnown'] = DateFormat('y-MM-dd').format(firstKnown);
    }

    final Response<List<dynamic>> statisticPacketResponse = await dio.get('/statistic/$exerciseId', queryParameters: queryParameters);
    return statisticPacketResponse.data!.map((statisticPacket) => StatisticPacket.fromJson(statisticPacket)).toList();
  }
}
