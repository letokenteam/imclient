import 'dart:convert';
import 'dart:typed_data';

import '../../../imclient.dart';
import '../../../model/message_payload.dart';
import '../../../model/user_info.dart';
import '../../message.dart';
import '../../message_content.dart';
import '../notification_message_content.dart';

// ignore: non_constant_identifier_names
MessageContent TransferGroupOwnerNotificationContentCreator() {
  return new TransferGroupOwnerNotificationContent();
}

const transferGroupOwnerNotificationContentMeta = MessageContentMeta(
    MESSAGE_CONTENT_TYPE_ADD_GROUP_MEMBER,
    MessageFlag.PERSIST,
    TransferGroupOwnerNotificationContentCreator);

class TransferGroupOwnerNotificationContent extends NotificationMessageContent {
  String groupId;
  String operateUser;
  String owner;

  @override
  void decode(MessagePayload payload) {
    super.decode(payload);
    Map<dynamic, dynamic> map = json.decode(utf8.decode(payload.binaryContent));
    operateUser = map['o'];
    groupId = map['g'];
    owner = map['m'];
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
    map['m'] = owner;
    payload.binaryContent = new Uint8List.fromList(json.encode(map).codeUnits);
    return payload;
  }

  @override
  Future<String> formatNotification(Message message) async {
    String formatMsg;
    if (operateUser == await Imclient.currentUserId) {
      formatMsg = '你';
    } else {
      UserInfo userInfo =
          await Imclient.getUserInfo(operateUser, groupId: groupId);
      if (userInfo != null) {
        if (userInfo.friendAlias != null && userInfo.friendAlias.isNotEmpty) {
          formatMsg = '${userInfo.friendAlias}';
        } else if (userInfo.groupAlias != null &&
            userInfo.groupAlias.isNotEmpty) {
          formatMsg = '${userInfo.groupAlias}';
        } else if (userInfo.displayName != null &&
            userInfo.displayName.isNotEmpty) {
          formatMsg = '${userInfo.displayName}';
        } else {
          formatMsg = '$operateUser';
        }
      } else {
        formatMsg = '$operateUser';
      }
    }

    formatMsg = '$formatMsg 把群组转让给了';

    if (owner == await Imclient.currentUserId) {
      formatMsg = '$formatMsg 你';
    } else {
      UserInfo userInfo =
          await Imclient.getUserInfo(owner, groupId: groupId);
      if (userInfo != null) {
        if (userInfo.friendAlias != null && userInfo.friendAlias.isNotEmpty) {
          formatMsg = '$formatMsg ${userInfo.friendAlias}';
        } else if (userInfo.groupAlias != null &&
            userInfo.groupAlias.isNotEmpty) {
          formatMsg = '$formatMsg ${userInfo.groupAlias}';
        } else if (userInfo.displayName != null &&
            userInfo.displayName.isNotEmpty) {
          formatMsg = '$formatMsg ${userInfo.displayName}';
        } else {
          formatMsg = '$formatMsg $operateUser';
        }
      } else {
        formatMsg = '$formatMsg $operateUser';
      }
    }

    return formatMsg;
  }

  @override
  MessageContentMeta get meta => transferGroupOwnerNotificationContentMeta;
}
