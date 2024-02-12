import 'package:cloud_firestore/cloud_firestore.dart';

class FirestroreService {
  //obter a coleção de produtos
  final CollectionReference produtos =
      FirebaseFirestore.instance.collection('produtos');

  //Create : adicionar um novo produto
  Future<void> addProduto(
    String produto,
    String preco,
  ) {
    return produtos.add({
      'nome': produto,
      'preco': preco,
    });
  }

  //read: pegar os produtos do banco
  Stream<QuerySnapshot> buscaProduto() {
    final produtoStream =
        produtos.orderBy('nome', descending: true).snapshots();

    return produtoStream;
  }

  //update: atualizar os produtos de acordo com ID
  Future<void> atualizaProduto(
      String docID, String newProduto, String newPreco) {
    return produtos.doc(docID).update({
      'nome': newProduto,
      'preco': newPreco,
    });
  }

  //delete: deletar produtos de acordo com o respectivo ID
  Future<void> deletaProduto(String docID) {
    return produtos.doc(docID).delete();
  }
}
