import 'package:dio/dio.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/domain/network/dio_provider.dart';

final exerciseService = ExerciseService();

class ExerciseService {
  Future<bool> train(int exerciseId, int repetitions) async {
    final Response response = await dio.post('/exercise/train/$exerciseId', data: {"repetitions": repetitions});
    return response.statusCode == 200;
  }

  Future<List<Exercise>> listExercises() async {
    final Response<List<dynamic>> exerciseResponse = await dio.get('/exercises');
    final exercises = exerciseResponse.data!.map((exercise) => Exercise.fromJson(exercise)).toList();
    return exercises;
  }
}
