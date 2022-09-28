import 'package:wonderjoys/services/authentification/authentification_service.dart';
import 'package:wonderjoys/services/database/user_database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../utils.dart';

class AddToCartFAB extends StatelessWidget {
  const AddToCartFAB({
    Key? key,
    @required this.productId,
  }) : super(key: key);

  final String? productId;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        bool allowed = AuthentificationService().currentUserVerified;
        if (!allowed) {
          final reverify = await showConfirmationDialog(context,
              "Non hai verificato il tuo indirizzo email. Questa azione è consentita solo per gli utenti verificati.",
              positiveResponse: "Invia nuovamente email di verifica",
              negativeResponse: "Torna indietro");
          if (reverify) {
            final future =
                AuthentificationService().sendVerificationEmailToCurrentUser();
            await showDialog(
              context: context,
              builder: (context) {
                return FutureProgressDialog(
                  future,
                  message: Text("Reinvio dell'email di verifica"),
                );
              },
            );
          }
          return;
        }
        bool? addedSuccessfully = false;
        String? snackbarMessage;
        try {
          addedSuccessfully =
              await UserDatabaseHelper().addProductToCart(productId!);
          if (addedSuccessfully == true) {
            snackbarMessage = "Prodotto aggiunto con successo";
          } else {
            throw "Impossibile Aggiungere il Prodotto per Motivi Sconosciuti";
          }
        } on FirebaseException catch (e) {
          Logger().w("Firebase Exception: $e");
          snackbarMessage = "Qualcosa è andato storto";
        } catch (e) {
          Logger().w("Unknown Exception: $e");
          snackbarMessage = "Qualcosa è andato storto";
        } finally {
          Logger().i(snackbarMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarMessage!),
            ),
          );
        }
      },
      label: Text(
        "Aggiungi Al Carrello",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      icon: Icon(
        Icons.shopping_cart,
      ),
    );
  }
}
