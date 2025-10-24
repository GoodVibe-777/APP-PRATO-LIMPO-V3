import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();

  Future<String?> scanFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    final inputImage = InputImage.fromFilePath(image.path);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<String?> scanFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    final inputImage = InputImage.fromFilePath(image.path);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  void dispose() {
    _recognizer.close();
  }
}
