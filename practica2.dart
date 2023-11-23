import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'basededatos.dart';

List<String> escuderias = <String>[
  "Escuderia",
  "RED BULL",
  "FERRARI",
  "MERCEDES",
  "MCLAREN",
  "ALPINE",
  "ASTON MARTIN",
  "ALPHATAURI",
  "ALFA ROMEO",
  "WILLIAMS",
  "HAAS"
];

class AppPractica2 extends StatefulWidget {
  const AppPractica2({super.key});
  @override
  State<AppPractica2> createState() => _AppPractica2State();
}

class _AppPractica2State extends State<AppPractica2> {
  String titulo = "Unidad 3 - Practica 2";
  String subtitulo = "Ingregse un piloto:";
  String reporte = "Mostrandose todos";
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${titulo}"),
            centerTitle: true,
            backgroundColor: Colors.teal,
            bottom: TabBar(tabs: [
              Text("Lista"),
              Text("Agregar"),
            ],
              indicatorColor: Colors.yellow,
              labelStyle: TextStyle(fontSize: 20),
            ),
          ),
          body: TabBarView(
              children: [
                listaVista(),
                agregar(),
              ]
          ),
        ));
  }

  Widget listaVista() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, left: 150, right: 150, bottom: 20),
              child: Text(
                "Pilotos",
                style: TextStyle(fontSize: 20),
              ),
              decoration: BoxDecoration(color: Colors.orange[200]),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              height: 500,
              child: FutureBuilder(
                  future: DB.mostrarPilotos(),
                  builder: (context, lista) {
                    if (lista.hasData) {
                      return ListView.builder(
                          itemCount: lista.data?.length,
                          itemBuilder: (context, indice) {
                            return ListTile(
                              title: Text("${lista.data?[indice]['nombre']}"),
                              subtitle: Text("${lista.data?[indice]['escuderia']}"),
                              leading: Text("${(lista.data?[indice]['numero']).toString()}"),
                              autofocus: true,
                              trailing: IconButton(
                                  onPressed: (){
                                    showDialog(
                                        context: context,
                                        builder: (builder){
                                          return AlertDialog(
                                            title: Text("¿Seguro que quieres eliminar?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    DB.eliminarPiloto(lista.data?[indice]['id']).then((value) {
                                                      setState(() {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text("Se eliminó el piloto"))
                                                        );
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  },
                                                  child: Text("Si")
                                              ),
                                              TextButton(
                                                  onPressed: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No")
                                              ),
                                            ],
                                          );
                                        }
                                    );
                                  },
                                  icon: Icon(Icons.delete)
                              ),
                              onTap: (){
                                String idPiloto = lista.data?[indice]['id'];
                                actualizar(idPiloto);
                              },
                            );
                          }
                      );
                    }
                    return Container(
                      child: CircularProgressIndicator(),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  final nombre = TextEditingController();
  final edad = TextEditingController();
  final numero = TextEditingController();
  final lugarNacimiento = TextEditingController();
  String equipo = escuderias.first;

  Widget agregar() {
    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${subtitulo}",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                      labelText: "Nombre:"
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                    controller: edad,
                    decoration: InputDecoration(
                        labelText: "Edad:"
                    ),
                    keyboardType: TextInputType.number
                ),
                SizedBox(height: 20,),
                DropdownButtonFormField(
                    value: equipo,
                    items: escuderias.map((e) {
                      return DropdownMenuItem(child: Text(e), value: e,);
                    }).toList(),
                    onChanged: (item){
                      setState(() {
                        equipo = item.toString();
                      });
                    }
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: numero,
                  decoration: InputDecoration(
                      labelText: "Número:"
                  ),
                    keyboardType: TextInputType.number
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: lugarNacimiento,
                  decoration: InputDecoration(
                      labelText: "Lugar nacimiento:"
                  ),
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: (){
                      var basedatos = FirebaseFirestore.instance;

                      basedatos.collection("pilotos").add({
                        'nombre': nombre.text,
                        'edad': int.parse(edad.text),
                        'escuderia':equipo,
                        'numero': numero.text,
                        'lugarNacimiento': lugarNacimiento.text
                      }).then((value){
                        setState(() {
                          subtitulo = "SE INSERTÓ";
                        });
                      });
                      nombre.clear();
                      edad.clear();
                      numero.clear();
                      lugarNacimiento.clear();
                    },
                    child: const Text("Registrar")
                )
              ],
            ),
          ),
        )
    );
  }

  void actualizar(String id) async{
    var datosPiloto = await DB.mostrarActualizado(id);

    if (datosPiloto.isNotEmpty) {
      setState(() {
        nombre.text = datosPiloto['nombre'];
        edad.text = datosPiloto['edad'].toString();
        numero.text = datosPiloto['numero'].toString();
        equipo = datosPiloto['escuderia'];
        lugarNacimiento.text = datosPiloto['lugarNacimiento'];
      });
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        builder: (builder){
          return Container(
            padding: EdgeInsets.only(
                top: 15,
                left: 30,
                right: 30,
                bottom: MediaQuery.of(context).viewInsets.bottom+50
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Actualice el piloto",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 30,),
                TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                      labelText: "Nombre:"
                  ),
                ),
                SizedBox(height: 20,),
                TextField(
                    controller: edad,
                    decoration: InputDecoration(
                        labelText: "Edad:"
                    ),
                    keyboardType: TextInputType.number
                ),
                SizedBox(height: 20,),
                DropdownButtonFormField(
                    value: equipo = escuderias[0],
                    items: escuderias.map((e) {
                      return DropdownMenuItem(child: Text(e), value: e,);
                    }).toList(),
                    onChanged: (item){
                      setState(() {
                        equipo = item.toString();
                      });
                    }
                ),
                SizedBox(height: 20,),
                TextField(
                    controller: numero,
                    decoration: InputDecoration(
                        labelText: "Número:"
                    ),
                    keyboardType: TextInputType.number
                ),
                SizedBox(height: 20,),
                TextField(
                  controller: lugarNacimiento,
                  decoration: InputDecoration(
                      labelText: "Lugar nacimiento:"
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: (){
                          var temporal={
                            'id':id,
                            'nombre': nombre.text,
                            'edad':int.parse(edad.text),
                            'escuderia': equipo,
                            'numero': int.parse(numero.text),
                            'lugarNacimiento': lugarNacimiento.text,
                          };

                          DB.actualizar(temporal).then((value) {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Se actualizó el piloto"))
                              );
                              Navigator.pop(context);
                            });
                          });

                          nombre.clear();
                          edad.clear();
                          numero.clear();
                          lugarNacimiento.clear();
                        },
                        child: const Text("ACTUALIZAR")
                    ),
                    ElevatedButton(
                        onPressed: (){
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: Text("CANCELAR")
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );
  }
}


