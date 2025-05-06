import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class widgets_Profile{

 Widget getWidgetNameSurName(String name, String surname){
    return  Text(
              '$name $surname',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            );
  }

  Widget getWidgetCode(String code){
    return  Text(
              'Código: $code',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            );
  }

  Widget getIconHospital(){
    return Icon(
                  Icons.local_hospital,
                  color: Color.fromARGB(255, 255, 0, 0),
                  size: 30,
                );
  }

  Widget getNameHospital(String hospital){
    return Text(
                  hospital,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                );
  }

  Widget getAvatar(){
    return CircleAvatar(
              radius: 50,
              backgroundColor: Colors.lightBlue,
              child: Icon(
                Icons.medical_services_outlined,
                size: 50,
                color: Colors.white,
              ),
            );
  }
}