// ===== home.dart ==============================
import 'package:app/utilities/structures.dart';

Device id2device(String id) {
  if (id == "DEV::123456") {
    return Device("2", Profile("Yuval Cohen", "yuvalc@walla.co.il", "054-631-1200"));
  } else
  if (id == "DEV::1a2b3c") {
    return Device('1', Profile("David Molina", "davidm@gmail.com", "054-123-4567"));
  } else {
    return Device("2", Profile("Re'em Kishinevsky", "reem.kishinevsky@gmail.com", "054-642-1200"));
  }
}
