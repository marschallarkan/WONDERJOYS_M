import 'package:wonderjoys/components/custom_suffix_icon.dart';
import 'package:wonderjoys/components/default_button.dart';
import 'package:wonderjoys/exceptions/firebaseauth/credential_actions_exceptions.dart';
import 'package:wonderjoys/exceptions/firebaseauth/messeged_firebaseauth_exception.dart';

import 'package:wonderjoys/services/authentification/authentification_service.dart';
import 'package:wonderjoys/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';

class ChangeEmailForm extends StatefulWidget {
  @override
  _ChangeEmailFormState createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentEmailController = TextEditingController();
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    currentEmailController.dispose();
    newEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(screenPadding)),
        child: Column(
          children: [
            buildCurrentEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildNewEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(40)),
            DefaultButton(
              text: "Cambia Email",
              press: () {
                final updateFuture = changeEmailButtonCallback();
                showDialog(
                  context: context,
                  builder: (context) {
                    return FutureProgressDialog(
                      updateFuture,
                      message: Text("Aggiornamento della posta elettronica"),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );

    return form;
  }

  Widget buildPasswordFormField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Password",
        labelText: "Inserire la password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Lock.svg",
        ),
      ),
      validator: (value) {
        if (passwordController.text.isEmpty) {
          return "La password non può essere vuota";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildCurrentEmailFormField() {
    return StreamBuilder<User>(
      stream: AuthentificationService().userChanges,
      builder: (context, snapshot) {
        String currentEmail;
        if (snapshot.hasData && snapshot.data != null)
          currentEmail = snapshot.data.email;
        final textField = TextFormField(
          controller: currentEmailController,
          decoration: InputDecoration(
            hintText: "Email corrente",
            labelText: "Email corrente",
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: CustomSuffixIcon(
              svgIcon: "assets/icons/Mail.svg",
            ),
          ),
          readOnly: true,
        );
        if (currentEmail != null) currentEmailController.text = currentEmail;
        return textField;
      },
    );
  }

  Widget buildNewEmailFormField() {
    return TextFormField(
      controller: newEmailController,
      decoration: InputDecoration(
        hintText: "Inserisci Nuova Email",
        labelText: "Nuova Email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          svgIcon: "assets/icons/Mail.svg",
        ),
      ),
      validator: (value) {
        if (newEmailController.text.isEmpty) {
          return kEmailNullError;
        } else if (!emailValidatorRegExp.hasMatch(newEmailController.text)) {
          return kInvalidEmailError;
        } else if (newEmailController.text == currentEmailController.text) {
          return "L'Email è già Collegata All'Account";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> changeEmailButtonCallback() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final AuthentificationService authService = AuthentificationService();
      bool passwordValidation =
          await authService.verifyCurrentUserPassword(passwordController.text);
      if (passwordValidation) {
        bool updationStatus = false;
        String snackbarMessage;
        try {
          updationStatus = await authService.changeEmailForCurrentUser(
              newEmail: newEmailController.text);
          if (updationStatus == true) {
            snackbarMessage =
                "Email di verifica inviata. Verifica la tua nuova email";
          } else {
            throw FirebaseCredentialActionAuthUnknownReasonFailureException(
                message:
                    "Impossibile elaborare la tua richiesta ora. Per favore riprova più tardi");
          }
        } on MessagedFirebaseAuthException catch (e) {
          snackbarMessage = e.message;
        } catch (e) {
          snackbarMessage = e.toString();
        } finally {
          Logger().i(snackbarMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarMessage),
            ),
          );
        }
      }
    }
  }
}
