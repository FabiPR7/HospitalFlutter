import 'package:mi_hospital/appConfig/domain/Firebase/HospitalFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/sections/Patients/entities/PatientsFirebase.dart';
import 'package:mi_hospital/sections/Staff/entities/StaffFirebase.dart';

class LoadData{

var userLogin = null;
var hospitalCode = null;
var staffList = null;
var patientsList = null;
var nameHospital = null;

dynamic data() async{
  userLogin = await DatabaseHelper().getFirstUser() ;
  hospitalCode = await DatabaseHelper().getHospitalCode();
  staffList = await StaffFirebase().getUsersWithSamePrefix(hospitalCode) ;
  patientsList = await PatientsFirebase().getPatients(hospitalCode);
  nameHospital = await HospitalFirebase().obtenerNombrePorCodigo(hospitalCode);
  return {"userLogin" : userLogin, "hospitalCode" : hospitalCode, "staffList" : staffList, "patientsList" : patientsList, "hospitalName" : nameHospital};
}


}