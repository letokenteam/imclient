import 'dart:convert';
import 'dart:typed_data';

import '../../../imclient.dart';
import '../../../model/message_payload.dart';
import '../../../model/user_info.dart';
import '../../message.dart';
import '../../message_content.dart';
import '../notification_message_content.dart';

// ignore: non_constant_identifier_names
MessageContent ChangeGroupPortraitNotificationContentCreator() {
  return new ChangeGroupPortraitNotificationContent();
}

const changeGroupPortraitNotificationContentMeta = MessageContentMeta(
    MESSAGE_CONTENT_TYPE_CHANGE_GROUP_PORTRAIT,
    MessageFlag.PERSIST,
    ChangeGroupPortraitNotificationContentCreator);

class ChangeGroupPortraitNotificationContent
    extends NotificationMessageContent {
  String groupId;
  String operateUser;

  @override
  void decode(MessagePayload payload) {
    super.decode(payload);
    Map<dynamic, dynamic> map = json.decode(utf8.decode(payload.binaryContent));
    operateUser = map['o'];
    groupId = map['g'];
  }

  @override
  Future<String> digest(Message message) async {
    return formatNotification(message);
  }

  @override
  Future<MessagePayload> encode() async {
    MessagePayload payload = await super.encode();
    Map<String, dynamic> map = new Map();
    map['o'] = operateUser;
    map['g'] = groupId;
    payload.binaryContent = new Uint8List.fromList(json.encode(map).codeUnits);
    return payload;
  }

  @override
  Future<String> formatNotification(Message message) async {
    if (operateUser == await Imclient.currentUserId) {
      return '你 修改了群头像';
    } else {
      UserInfo userInfo =
          await Imclient.getUserInfo(operateUser, groupId: groupId);
      if (userInfo != null) {
        if (userInfo.friendAlias != null && userInfo.friendAlias.isNotEmpty) {
          return '${userInfo.friendAlias} 修改了群头像';
        } else if (userInfo.groupAlias != null &&
            userInfo.groupAlias.isNotEmpty) {
          return '${userInfo.groupAlias} 修改了群头像';
        } else if (userInfo.displayName != null &&
            userInfo.displayName.isNotEmpty) {
          return '${userInfo.displayName} 修改了群头像';
        } else {
          return '$operateUser 修改了群头像';
        }
      } else {
        return '$operateUser 修改了群头像';
      }
    }
  }

  @override
  MessageContentMeta get meta => changeGroupPortraitNotificationContentMeta;
}
