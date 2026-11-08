import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_constants.dart';
import '../models/perfil.dart';
import '../models/rol.dart';

class PerfilRemoteDataSource {
  final FirebaseFirestore firestore;

  PerfilRemoteDataSource(this.firestore);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      firestore.collection('users').doc(uid);

  Future<Perfil?> getPerfil(String uid) async {
    final snapshot = await _doc(uid).get().timeout(AppConstants.firestoreTimeout);
    final data = snapshot.data();
    return data == null ? null : Perfil.fromJson(data);
  }

  Future<Perfil> crearPerfilCliente({
    required String uid,
    required String email,
    required String nombre,
  }) async {
    await _doc(uid)
        .set({
          'uid': uid,
          'email': email,
          'nombre': nombre,
          'rol': Rol.cliente.value,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(AppConstants.firestoreTimeout);

    return Perfil(uid: uid, email: email, nombre: nombre, rol: Rol.cliente);
  }
}
