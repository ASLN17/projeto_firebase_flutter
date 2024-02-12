import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_firebase/services/firestore.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestroreService firestroreService = FirestroreService();

  final TextEditingController textController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // abrir caixa de dialogo para adicionar um produto
  void abrirProdutoBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicione seu produto!'),
        content: Form(
          key: _formKey,
          child: SizedBox(
            height: 175,
            width: 200,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 9.0),
                  child: TextFormField(
                    controller: precoController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]+'))
                    ],
                    decoration: const InputDecoration(labelText: 'Preço'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo preço é obrigatório';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Valida o formulário antes de prosseguir
              if (_formKey.currentState!.validate()) {
                // Adicionar novo produto
                if (docID == null) {
                  firestroreService.addProduto(
                      textController.text, precoController.text);
                } else {
                  // Atualizar produto
                  firestroreService.atualizaProduto(
                      docID, textController.text, precoController.text);
                }

                // Limpar campos e fechar diálogo
                textController.clear();
                precoController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Adicionar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Banco'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 30.0,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirProdutoBox,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            await firestroreService.buscaProduto();
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: firestroreService.buscaProduto(),
            builder: (context, snapshot) {
              // se existe data, pegue todos os documentos
              if (snapshot.hasData) {
                List produtosList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: produtosList.length,
                  itemBuilder: (context, index) {
                    // buscar os documentos individuais
                    DocumentSnapshot document = produtosList[index];
                    String docID = document.id;

                    // buscar produto de cada documento
                    Map<String, dynamic> dados =
                        document.data() as Map<String, dynamic>;
                    String produtoText = dados["nome"].toString();
                    String precoText = dados["preco"].toString();

                    //mostrar como um list tile
                    return ListTile(
                        title: Text(produtoText),
                        subtitle: Text(precoText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //botao update
                            IconButton(
                              onPressed: () => abrirProdutoBox(docID: docID),
                              icon: const Icon(Icons.settings_rounded),
                            ),

                            //botao delete
                            IconButton(
                              onPressed: () =>
                                  firestroreService.deletaProduto(docID),
                              icon: const Icon(Icons.delete_forever),
                            )
                          ],
                        ));
                  },
                );
              }

              // se não ouver dados
              else {
                return const Text("sem produtos");
              }
            },
          )),
    );
  }
}
