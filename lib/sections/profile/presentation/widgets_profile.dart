import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class widgets_Profile{

 Widget getWidgetNameSurName(String name, String surname){
    return  Text(
              '${name.replaceAll('}', '')} ${surname.replaceAll('}', '')}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: ThemeController.to.getButtonBlue(),
                letterSpacing: 0.5,
              ),
            );
  }

  Widget getWidgetCode(String code){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeController.to.getSurfaceColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeController.to.getButtonBlue().withOpacity(0.3)),
      ),
      child: Text(
        'Código: $code',
        style: TextStyle(
          fontSize: 16,
          color: ThemeController.to.getTextColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget getIconHospital(){
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ThemeController.to.getErrorRed().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.local_hospital,
        color: ThemeController.to.getErrorRed(),
        size: 30,
      ),
    );
  }

  Widget getNameHospital(String hospital){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeController.to.getErrorRed().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeController.to.getErrorRed().withOpacity(0.3)),
      ),
      child: Text(
        hospital,
        style: TextStyle(
          fontSize: 16,
          color: ThemeController.to.getErrorRed(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget getAvatar(){
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            ThemeController.to.getButtonBlue(),
            ThemeController.to.getButtonBlue().withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeController.to.getButtonBlue().withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.medical_services_outlined,
          size: 50,
          color: ThemeController.to.getButtonBlue(),
        ),
      ),
    );
  }
}