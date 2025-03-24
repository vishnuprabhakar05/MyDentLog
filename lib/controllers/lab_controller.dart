import 'package:get/get.dart';
import '../models/lab_model.dart';

class LabController extends GetxController {
  var labs = <LabModel>[].obs;

  void addLab(LabModel lab) {
    labs.add(lab);
  }
}
