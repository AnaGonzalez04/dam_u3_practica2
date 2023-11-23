import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

var baseRemota = FirebaseFirestore.instance;

class DB{
  static Future insertarPiloto(Map<String, dynamic> piloto) async {
    return await baseRemota.collection("pilotos").add(piloto);
  }

  static Future<List> mostrarPilotos() async {
    var baseRemota = FirebaseFirestore.instance;
    List temp = [];
    var query = await baseRemota.collection("pilotos").get();
    query.docs.forEach((element) {
      Map<String, dynamic> dato = element.data();
      dato.addAll({'id': element.id});
      temp.add(dato);
    });
    return temp;
  }

  static Future eliminarPiloto(String id) async{
    return await baseRemota.collection("pilotos").doc(id).delete();
  }

  static Future actualizar(Map<String, dynamic> pilotos) async{
    String idActualizar = pilotos['id'];
    pilotos.remove('id');
    return await baseRemota.collection("pilotos").doc(idActualizar).update(pilotos);
  }

  static Future<Map<String, dynamic>> mostrarActualizado(String id) async {
    var doc = await baseRemota.collection("pilotos").doc(id).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data()!;
      data.addAll({'id': doc.id});
      return data;
    } else {
      return {};
    }
  }

}