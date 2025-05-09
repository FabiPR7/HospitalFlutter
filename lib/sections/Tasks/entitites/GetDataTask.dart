import 'package:mi_hospital/main.dart';

class GetDataTask {
  final patientsList = GetData().getPatients();
  final staffList = GetData().getStaffList();

  String convertDnitoNamePatient(String dni){
    for (var patient in patientsList) {
        if(dni == patient["dni"]){
          return patient["name"];
        }
    }
    return "";
  }

   String convertCodetoNameStaff(String code){
    if(code.isNotEmpty){
    for (var staff in staffList) {
        if(code == staff["codigo"]){
          return staff["name"];
        }
    }
    }
    return "Sin asingar";
  }
}