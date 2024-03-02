import 'package:flutter/material.dart';
import 'package:secure_alert/service/firebase.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  bool isSwitched = false;
  String? url;
  /*
  var val;
   @override
  void initState(){
    super.initState();
    if(Global.instance.user!.isLoggedIn){
      url = Global.instance.user!.avatar!;
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction){
        NotficationController.onActionReceivedMethod(receivedAction);
        return val;
      }
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Global.instance.user!.isLoggedIn ? customAppBarAction(
        title: "Account",
        actions: IconButton(onPressed: () {
          signOut();
          setState(() {
            Navigator.of(context).pushReplacementNamed("/home");
          });
        }, icon: const Icon(Icons.logout))
      ) : customAppBar(
        title: "Account"
      ),
      body: Global.instance.user!.isLoggedIn ?
      Container(
        color: Colors.grey.shade200,
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10 ),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getAvatar(),
                  Padding(padding: const EdgeInsets.only(top: 2.0, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Global.instance.user!.firstName!, style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                      ) ,),
                      TextButton(onPressed: (){
                        Navigator.pushNamed(context, '/editProfile');
                      }, child: Row(
                        children: [
                          Text("Edit Profile", style: TextStyle(
                            fontSize: 18,
                            color: Colors.red.shade900
                          ),),
                          Icon(Icons.chevron_right,
                          color: Colors.red.shade900,
                          size: 25,)
                        ],
                      ))
                    ],
                  ),)
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getHeaderText("General"),
                  getTextButton(
                    text: "Help Center",
                    onTap: (){
                      Navigator.of(context).pushNamed('/helpCenter');
                    }
                  ),
                  getTextButton(
                      text: "My Post",
                      onTap: (){
                        Navigator.of(context).pushNamed('/myPost');
                      }),
                  getTextButton(
                      text: "Send Feedback",
                      onTap: (){
                        getSendFeedbackPopUp();
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20,),

            
          ],
        ),
      )
    );
  }
}