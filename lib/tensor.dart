import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteModel {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('lib/asset/model.tflite');
  }

  // Define a method for inference
  Future<List<dynamic>> runModelInference(List<dynamic> input) async {
    final output = List.filled(1, 0)
        .reshape([1, 20]); // Adjust based on your model's output
    _interpreter?.run(input, output);
    return output;
  }
}
