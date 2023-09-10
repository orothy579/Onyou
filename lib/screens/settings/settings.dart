import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isOnline = false;
  bool receivePushNotification = false;
  bool receiveEmailNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("프로필 설정"),
            leading: Icon(Icons.person),
            trailing: CircleAvatar(
              // 여기에 프로필 이미지 URL을 넣을 수 있습니다.
              backgroundImage: NetworkImage('https://example.com/profile.jpg'),
            ),
            onTap: () {
              // 프로필 설정 페이지로 이동
            },
          ),
          SwitchListTile(
            title: Text("온라인 상태 표시"),
            value: isOnline,
            onChanged: (bool value) {
              setState(() {
                isOnline = value;
              });
            },
          ),
          ListTile(
            title: Text("개인/보안 관련"),
            onTap: () {
              // 개인/보안 관련 페이지로 이동
            },
          ),
          SwitchListTile(
            title: Text("푸시 알림 받기"),
            value: receivePushNotification,
            onChanged: (bool value) {
              setState(() {
                receivePushNotification = value;
              });
            },
          ),
          ListTile(
            title: Text("새글 알림, 댓글 알림, 일정 알림, 사진첩 알림, notice 알림"),
            // 추가 설정을 위한 로직을 여기에 넣을 수 있습니다.
          ),
          SwitchListTile(
            title: Text("이메일 알림 받기"),
            value: receiveEmailNotification,
            onChanged: (bool value) {
              setState(() {
                receiveEmailNotification = value;
              });
            },
          ),
          ListTile(
            title: Text("어플 탈퇴"),
            onTap: () {
              // 탈퇴 로직을 여기에 넣을 수 있습니다.
            },
          ),
          ListTile(
            title: Text("앱 관리"),
            onTap: () {
              // 앱 관리 페이지로 이동
            },
          ),
        ],
      ),
    );
  }
}
