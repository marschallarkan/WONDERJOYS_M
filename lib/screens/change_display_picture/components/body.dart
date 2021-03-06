import 'dart:io';
import 'package:wonderjoys/components/default_button.dart';
import 'package:wonderjoys/constants.dart';
import 'package:wonderjoys/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:wonderjoys/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:wonderjoys/services/database/user_database_helper.dart';
import 'package:wonderjoys/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:wonderjoys/services/local_files_access/local_files_access_service.dart';
import 'package:wonderjoys/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../provider_models/body_model.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChosenImage(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<ChosenImage>(
                builder: (context, bodyState, child) {
                  return Column(
                    children: [
                      Text(
                        "Cambia Avatar",
                        style: headingStyle,
                      ),
                      SizedBox(height: getProportionateScreenHeight(40)),
                      GestureDetector(
                        child: buildDisplayPictureAvatar(context, bodyState),
                        onTap: () {
                          getImageFromUser(context, bodyState);
                        },
                      ),
                      SizedBox(height: getProportionateScreenHeight(80)),
                      buildChosePictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      buildUploadPictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      buildRemovePictureButton(context, bodyState),
                      SizedBox(height: getProportionateScreenHeight(80)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDisplayPictureAvatar(
      BuildContext context, ChosenImage bodyState) {
    return Container(
      child: StreamBuilder(
        stream: UserDatabaseHelper().currentUserDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
          }
          ImageProvider backImage;
          if (bodyState.chosenImage != null) {
            backImage = MemoryImage(bodyState.chosenImage.readAsBytesSync());
          } else if (snapshot.hasData && snapshot.data.data != null) {
            final String url = snapshot.data.data()[UserDatabaseHelper.DP_KEY];
            if (url != null) backImage = NetworkImage(url);
          }
          return CircleAvatar(
            radius: SizeConfig.screenWidth * 0.3,
            backgroundColor: kTextColor.withOpacity(0.5),
            backgroundImage: backImage ?? null,
          );
        },
      ),
    );
  }

  void getImageFromUser(BuildContext context, ChosenImage bodyState) async {
    String path;
    String snackbarMessage;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("LocalFileHandlingException: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("LocalFileHandlingException: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == null) {
      return;
    }
    bodyState.setChosenImage = File(path);
  }

  Widget buildChosePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Scegli immagine",
      press: () {
        getImageFromUser(context, bodyState);
      },
    );
  }

  Widget buildUploadPictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Carica l'immagine",
      press: () {
        final Future uploadFuture =
            uploadImageToFirestorage(context, bodyState);
        showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Aggiornamento dell'immagine visualizzata"),
            );
          },
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Immagine del Display Aggiornata")));
      },
    );
  }

  Future<void> uploadImageToFirestorage(
      BuildContext context, ChosenImage bodyState) async {
    bool uploadDisplayPictureStatus = false;
    String snackbarMessage;
    try {
      final downloadUrl = await FirestoreFilesAccess().uploadFileToPath(
          bodyState.chosenImage,
          UserDatabaseHelper().getPathForCurrentUserDisplayPicture());

      uploadDisplayPictureStatus = await UserDatabaseHelper()
          .uploadDisplayPictureForCurrentUser(downloadUrl);
      if (uploadDisplayPictureStatus == true) {
        snackbarMessage = "Visualizza immagine aggiornata correttamente";
      } else {
        throw "Impossibile aggiornare l'immagine visualizzata per motivi sconosciuti";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Qualcosa ?? andato storto";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Qualcosa ?? andato storto";
    } finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
  }

  Widget buildRemovePictureButton(BuildContext context, ChosenImage bodyState) {
    return DefaultButton(
      text: "Rimuovi Immagine",
      press: () async {
        final Future uploadFuture =
            removeImageFromFirestore(context, bodyState);
        await showDialog(
          context: context,
          builder: (context) {
            return FutureProgressDialog(
              uploadFuture,
              message: Text("Eliminazione dell'immagine visualizzata"),
            );
          },
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Immagine del display rimossa")));
        Navigator.pop(context);
      },
    );
  }

  Future<void> removeImageFromFirestore(
      BuildContext context, ChosenImage bodyState) async {
    bool status = false;
    String snackbarMessage;
    try {
      bool fileDeletedFromFirestore = false;
      fileDeletedFromFirestore = await FirestoreFilesAccess()
          .deleteFileFromPath(
              UserDatabaseHelper().getPathForCurrentUserDisplayPicture());
      if (fileDeletedFromFirestore == false) {
        throw "Impossibile eliminare il file dallo spazio di archiviazione, riprova";
      }
      status = await UserDatabaseHelper().removeDisplayPictureForCurrentUser();
      if (status == true) {
        snackbarMessage = "Immagine rimossa con successo";
      } else {
        throw "Impossibile rimuovere per motivi sconosciuti";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Qualcosa ?? andato storto";
    }  finally {
      Logger().i(snackbarMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
  }
}
