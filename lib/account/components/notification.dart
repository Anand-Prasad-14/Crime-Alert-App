import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';

import '../../service/global.dart';
import '../../service/firebase.dart';
import '../models/info_model.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreateMethod(ReceivedNotification receivedNotification) async {

  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayMethod(ReceivedNotification receivedNotification) async {

  }
  
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceiveMethod(ReceivedAction receivedAction) async {

  }
  
  @pragma("vm:entry-point")
  static Future<void> dismissNotification()  async {
    AwesomeNotifications().dismiss(1);
  }
  
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async{
    if (receivedAction.buttonKeyPressed == "fire") {
      _sendSMS(2);
    } else if (receivedAction.buttonKeyPressed == "police") {
      _sendSMS(1);
    } else if (receivedAction.buttonKeyPressed == "alarm") {
      FlutterRingtonePlayer.play(fromAsset: "");
      alarmKey = 'stop';
      alarmVal = 'stop';
    } else if (receivedAction.buttonKeyPressed == "stop") {
      FlutterRingtonePlayer.stop();
      alarmKey = "alarm";
      alarmVal = "Ring";
    }
    createSOSNotification();
  }

  static String alarmKey = 'alarm';
  static String alarmVal = 'Ring';

  static Future<void> createSOSNotification() async {
    await AwesomeNotifications().createNotification(content: NotificationContent(id: 1, channelKey: 'basic_channel', locked: true, title: 'SOS Menu Bar', notificationLayout: NotificationLayout.Default),
    actionButtons: [
      NotificationActionButton(key: 'fire', label: '${Emojis.wheater_fire} Fire SOS'),
      NotificationActionButton(key: 'police', label:'${Emojis.symbols_sos_button} 911 SOS'),
      NotificationActionButton(key: alarmKey, label: '${Emojis.sound_loudspeaker} $alarmVal Alarm')
    ]);
  }

  //--SOS Message
  static String message = "";
  static String initialMessage = "";
  static String addtionalInfo = "";
  static List<String> contacts = [];

  static Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied){
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever){
      throw Exception('Location permission are permanently denied');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static Future<void> getMessage(int type) async {
    if (type == 1) {
      initialMessage = "SOS! Immediate Help required.";
    } else {
      initialMessage = "Fire SOS Alert! Immediate Help required.";
    }

    bool _result = await canSendSMS();
    String location = await getLocation();
    message = "\nName: ${Global.instance.user!.firstName!} \n$location";
  }

  static Future<String> getLocation() async {
    final position = await _determinePosition();
    return "Longitude: ${position.longitude} and Latitude: ${position.latitude}";
  }

  static Future getInfo()async{
    addtionalInfo = "";
    var data = await getSOSData(Global.instance.user!.uId!);
    print(data);
    List<Info> infoList = [];
    if(data != null) {
      if (data["info"] != null) {
        data["info"].forEach((dt) {
          Map info = dt;
          infoList.add(Info(info.keys.first, info.values.first));
        });
        for (var i in infoList) {
          addtionalInfo += "\n${i.type}: "
              "\n${i.description}";
        }
      }
      if (data["setting"] != null) {
        if (data["setting"]["messageContact"] == true) {
          contacts = await getRecipientContact(Global.instance.user!.uId!);
          print(contacts);
        }
      }
    }
  }

  static Future<void> _sendSMS(int type) async {
    List<String> recipents = ["+60163774255", "+601111954216"];

    await getMessage(type).whenComplete(() {
      getInfo()
.whenComplete(() async {
  recipents.addAll(contacts);
  try {
    String _result = await sendSMS(
      message: "$initialMessage \n$message \n$addtionalInfo",
      recipients: recipents,
      sendDirect: true
    );
    print(_result);
  } catch (onError) {
    print(onError);
  };
});  
  });
  }
}