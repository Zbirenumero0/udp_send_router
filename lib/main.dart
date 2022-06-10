import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';


Future<String> getRouterIP () async {
  WidgetsFlutterBinding.ensureInitialized();
  //if unused, WifiInfoPlugin.wifiDetails returns null and a platform error
  WifiInfoWrapper? wifiDeviceInfoObjectLUL;
  try {
    wifiDeviceInfoObjectLUL = await WifiInfoPlugin.wifiDetails;
  } on PlatformException {}
  //returns the address of the router
  return wifiDeviceInfoObjectLUL != null ? wifiDeviceInfoObjectLUL.routerIp.toString() : "WifiInfoPlugin.wifiDetails returned null";
}

void udpSender (String address, int port) {
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((RawDatagramSocket socket){
    //sending a hello to the RouterIP with UDP
    var destinationAddress = InternetAddress(address);
    String message = String.fromCharCodes("hello".codeUnits);
    socket.send(message.codeUnits, destinationAddress, port);
    print('ENVOI Send Message to $address:$port // Message is : ${message.trim()}');
  });
}

void udpreceiver (String address, int port){
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 62526).then((RawDatagramSocket socket){
    socket.listen((RawSocketEvent e){
      Datagram? d = socket.receive();
      if (d == null) return;
      String message = String.fromCharCodes(d.data);
      print('RECEPTION Received Message from $address:$port // Message is : ${message.trim()}');
    });
  });
}

void udpRouterHello () async{
  //Hardcoded Router 62526
  int portRouter = 62526;
  //Getting the Router IP
  String addressRouter = "No IP";
  addressRouter = await getRouterIP();
  print('INFO Router Adress is : $addressRouter:$portRouter');

  RawDatagramSocket.bind(InternetAddress.anyIPv4, portRouter).then((RawDatagramSocket socket){
    udpreceiver(addressRouter, portRouter);
    udpSender(addressRouter, portRouter);
  });
}


void main() {
  udpRouterHello();
}