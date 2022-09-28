import 'package:wonderjoys/constants.dart';
import 'package:wonderjoys/models/AppReview.dart';
import 'package:wonderjoys/services/authentification/authentification_service.dart';
import 'package:wonderjoys/services/database/app_review_database_helper.dart';
import 'package:wonderjoys/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:wonderjoys/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_review_dialog.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(screenPadding),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "Informazioni sullo sviluppatore",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(50)),
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/developer.png'),
                  radius: SizeConfig.screenWidth! * 0.3,
                  backgroundColor: kTextColor.withOpacity(0.75),
                ),

                SizedBox(height: getProportionateScreenHeight(30)),
                Text(
                  'Mario J Landi',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Giuseppe Limoli in arte Mario J Landi,"
                      " Imprenditore, Motivatore, Blogger,"
                      " Scrittore, Comico, Rapper, Instagrammer,"
                      " Tik Tokker aggiungerei qualcos'altro ma rischierei di non avere tempo per la meditazione",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/tiktok_logo.svg",
                        color: kTextColor.withOpacity(0.75),
                      ),
                      color: kTextColor.withOpacity(0.75),
                      iconSize: 40,
                      padding: EdgeInsets.all(16),
                      onPressed: () async {
                        const String tiktokUrl = "https://www.tiktok.com/@mariojlandi?lang=it-IT";
                        await launchUrl(tiktokUrl);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/facebook-2.svg",
                        color: kTextColor.withOpacity(0.75),
                      ),
                      iconSize: 40,
                      padding: EdgeInsets.all(16),
                      onPressed: () async {
                        const String facebookUrl =
                            "https://www.facebook.com/mariojlandi";
                        await launchUrl(facebookUrl);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset("assets/icons/instagram_icon.svg",
                          color: kTextColor.withOpacity(0.75)),
                      iconSize: 40,
                      padding: EdgeInsets.all(16),
                      onPressed: () async {
                        const String instaUrl =
                            "https://www.instagram.com/mariojlandi";
                        await launchUrl(instaUrl);
                      },
                    ),
                    IconButton(
                      icon: SvgPicture.asset("assets/icons/web.svg",
                          color: kTextColor.withOpacity(0.75)),
                      iconSize: 40,
                      padding: EdgeInsets.all(16),
                      onPressed: () async {
                        const String webUrl =
                            "www.mariojlandi.com";
                        await launchUrl(webUrl);
                      },
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(50)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      color: kTextColor.withOpacity(0.75),
                      iconSize: 50,
                      padding: EdgeInsets.all(16),
                      onPressed: () {
                        submitAppReview(context, liked: true);
                      },
                    ),
                    Text(
                      "Ti è piaciuta l'app?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      padding: EdgeInsets.all(16),
                      color: kTextColor.withOpacity(0.75),
                      iconSize: 50,
                      onPressed: () {
                        submitAppReview(context, liked: false);
                      },
                    ),
                    Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeveloperAvatar() {
    return FutureBuilder<String>(
        future: FirestoreFilesAccess().getDeveloperImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final url = snapshot.data;
            return CircleAvatar(
              radius: SizeConfig.screenWidth! * 0.3,
              backgroundColor: kTextColor.withOpacity(0.75),
              backgroundImage: NetworkImage(url!),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error.toString();
            Logger().e(error);
          }
          return CircleAvatar(
            radius: SizeConfig.screenWidth! * 0.3,
            backgroundColor: kTextColor.withOpacity(0.75),
          );
        });
  }

  Future<void> launchUrl(String? url) async {
    try {
      if (await canLaunch(url!)) {
        await launchUrl;
      } else {
        Logger().i("Impossibile avviare l'URL di Instagram");
      }
    } catch (e) {
      Logger().e("Eccezione durante l'avvio dell'URL: $e");
    }
  }

  Future<void> submitAppReview(BuildContext context,
      {bool liked = true}) async {
    AppReview? prevReview;
    try {
      prevReview = await AppReviewDatabaseHelper().getAppReviewOfCurrentUser();
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
    } catch (e) {
      Logger().w("Unknown Exception: $e");
    } finally {
      if (prevReview == null) {
        prevReview = AppReview(
          AuthentificationService().currentUser.uid,
          liked: liked,
          feedback: "",
        );
      }
    }

    final AppReview result = await showDialog(
      context: context,
      builder: (context) {
        return AppReviewDialog(
          appReview: prevReview,
        );
      },
    );
    if (result != null) {
      result.liked = liked;
      bool? reviewAdded = false;
      String? snackbarMessage;
      try {
        reviewAdded = await AppReviewDatabaseHelper().editAppReview(result);
        if (reviewAdded == true) {
          snackbarMessage = "Feedback inviato con successo";
        } else {
          throw "Impossibile aggiungere il feedback per motivi sconosciuti";
        }
      } on FirebaseException catch (e) {
        Logger().w("Firebase Exception: $e");
        snackbarMessage = e.toString();
      } catch (e) {
        Logger().w("Unknown Exception: $e");
        snackbarMessage = e.toString();
      } finally {
        Logger().i(snackbarMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage!),
          ),
        );
      }
    }
  }
}
