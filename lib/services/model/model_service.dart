import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TextClassifier {
  final _modelFile = 'assets/model.tflite';
  final _wordFile = 'assets/word_index.txt';

  final int _sentenceLen = 256;

  final String start = '<START>';
  final String pad = '<PAD>';
  final String unk = '<UNKNOWN>';

  late Map<String, int> _dict;

  late Interpreter _interpreter;

  TextClassifier() {
    _loadModel();
    _loadDictionary();
  }

  void _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelFile);

      // Print input and output tensor details
      var inputTensor = _interpreter.getInputTensor(0);
      print(
          "Input tensor shape: ${inputTensor.shape} and type: ${inputTensor.type}");

      var outputTensor = _interpreter.getOutputTensor(0);
      print(
          "Output tensor shape: ${outputTensor.shape} and type: ${outputTensor.type}");

      print('Interpreter loaded successfully');
    } catch (e) {
      print('Error loading the model: $e');
    }
  }

  void _loadDictionary() async {
    final vocab = await rootBundle.loadString(_wordFile);
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    _dict = dict;
    print('Dictionary loaded successfully');
  }

  List<List<double>> tokenize(String text) {
    List<String> words = text.toLowerCase().split(' ');
    List<double> tokens = words.map((word) {
      double token = _dict[word]?.toDouble() ?? 0.0;
      print("Wort: $word, Token: $token");
      return token;
    }).toList();

    List<List<double>> tensorInput = [];
    if (tokens.length >= _sentenceLen) {
      tensorInput.add(tokens.sublist(0, _sentenceLen));
    } else {
      List<double> paddedTokens =
          List<double>.filled(_sentenceLen - tokens.length, 0.0, growable: true)
            ..addAll(tokens);
      tensorInput.add(paddedTokens);
    }
    return tensorInput;
  }

  List<double> classify(String rawText) {
    var tensorInput = tokenize(rawText);

    List<Float32List> listOfFloat32Lists = tensorInput.map((list) {
      return Float32List.fromList(list);
    }).toList();

    List<Float32List> outputBuffer =
        List.generate(1, (index) => Float32List(3));

    print("outputBuffer length: ${outputBuffer.runtimeType}");

    try {
      _interpreter.run(listOfFloat32Lists, outputBuffer);
      print("Model run successfully");
    } catch (e) {
      print("Run failed: $e");
    }

    var output = outputBuffer;
    print("Output: $output");

    return [output[0][0], output[0][1], output[0][2]];
  }

  List<List<double>> tokenizeInputText(String text) {
    final toks = text.split(' ');

    var vec = List<double>.filled(_sentenceLen, _dict[pad]!.toDouble());

    var index = 0;
    if (_dict.containsKey(start)) {
      vec[index++] = _dict[start]!.toDouble();
    }

    for (var tok in toks) {
      if (index > _sentenceLen) {
        break;
      }
      vec[index++] = _dict.containsKey(tok)
          ? _dict[tok]!.toDouble()
          : _dict[unk]!.toDouble();
    }

    return [vec];
  }
}

// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:tflite_v2/tflite_v2.dart';

// class MyModelService {
//   late Map<String, int> wordIndex;

//   MyModelService();

//   void setWordIndex(Map<String, int> newIndex) {
//     wordIndex = newIndex;
//   }

//   Future<void> loadModel() async {
//     String? res = await Tflite.loadModel(
//         model: "assets/saved_model.tflite",
//         labels: "assets/labels.txt",
//         numThreads: 1,
//         isAsset: true,
//         useGpuDelegate: false);
//     print("Model loaded. $res");
//   }

//   Future<List<dynamic>> runModelOnInputData(String inputText) async {
//     print("runModelOnInputData reached.");
//     Uint8List inputData = processText(inputText.toLowerCase());
//     List<int> intInputData = inputData.toList();

//     List<int> reshapedData = List.filled(20, 0);
//     reshapedData.setRange(0, intInputData.length, intInputData);
//     printUint8List(inputData);
//     var output =
//         await Tflite.runModelOnBinary(binary: Uint8List.fromList(reshapedData));

//     print(output);
//     return output ?? [];
//   }

//   bool checkIfTextIsInappropriate(List<dynamic> modelOutput) {
//     if (modelOutput.isNotEmpty) {
//       final double probabilityOfHateSpeech = modelOutput[0][0];
//       final double probabilityOfOffensiveLanguage = modelOutput[0][1];
//       const threshold = 0.5;

//       return probabilityOfHateSpeech > threshold ||
//           probabilityOfOffensiveLanguage > threshold;
//     }
//     return false;
//   }

//   String uint8ListToString(Uint8List uint8List) {
//     return uint8List.map((e) => e.toString()).join(", ");
//   }

//   void printUint8List(Uint8List uint8List) {
//     String formattedString = uint8ListToString(uint8List);
//     print("Inputdata: [$formattedString]");
//   }

//   Uint8List processText(String inputText) {
//     List<int> tokenized = tokenize(inputText);
//     List<int> padded = padSequence(tokenized, 20);

//     print("Tokenized: $tokenized");
//     print("Padded: $padded");

//     Uint8List uintData = Uint8List.fromList(padded);

//     return uintData;
//   }

//   List<int> tokenize(String text) {
//     List<String> words = text.toLowerCase().split(' ');
//     List<int> tokens = words.map((word) => wordIndex[word] ?? 0).toList();
//     return tokens;
//   }

//   List<int> padSequence(List<int> sequence, int length) {
//     if (sequence.length >= length) {
//       return sequence.sublist(0, length);
//     } else {
//       return List<int>.filled(length - sequence.length, 0, growable: true)
//         ..addAll(sequence);
//     }
//   }
// }
