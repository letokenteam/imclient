
import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';
import 'package:imclient/model/friend.dart';

import 'imclient_platform_interface.dart';
import 'message/card_message_content.dart';
import 'message/composite_message_content.dart';
import 'message/file_message_content.dart';
import 'message/image_message_content.dart';
import 'message/link_message_content.dart';
import 'message/location_message_content.dart';
import 'message/message.dart';
import 'message/message_content.dart';
import 'message/notification/delete_message_content.dart';
import 'message/notification/friend_added_message_content.dart';
import 'message/notification/friend_greeting_message_content.dart';
import 'message/notification/group/add_group_member_notification_content.dart';
import 'message/notification/group/change_group_name_notification_content.dart';
import 'message/notification/group/change_group_portrait_notification_content.dart';
import 'message/notification/group/create_group_notification_content.dart';
import 'message/notification/group/dismiss_group_notification_content.dart';
import 'message/notification/group/group_join_type_notification_content.dart';
import 'message/notification/group/group_member_allow_notification_content.dart';
import 'message/notification/group/group_member_mute_notification_content.dart';
import 'message/notification/group/group_mute_notification_content.dart';
import 'message/notification/group/group_private_chat_notification_content.dart';
import 'message/notification/group/group_set_manager_notification_content.dart';
import 'message/notification/group/kickoff_group_member_notification_content.dart';
import 'message/notification/group/modify_group_member_alias_notification_content.dart';
import 'message/notification/group/quit_group_notification_content.dart';
import 'message/notification/group/transfer_group_owner_notification_content.dart';
import 'message/notification/recall_notificiation_content.dart';
import 'message/notification/tip_notificiation_content.dart';
import 'message/pclogin_request_message_content.dart';
import 'message/ptext_message_content.dart';
import 'message/sound_message_content.dart';
import 'message/sticker_message_content.dart';
import 'message/text_message_content.dart';
import 'message/typing_message_content.dart';
import 'message/unknown_message_content.dart';
import 'message/video_message_content.dart';
import 'model/channel_info.dart';
import 'model/chatroom_info.dart';
import 'model/chatroom_member_info.dart';
import 'model/conversation.dart';
import 'model/conversation_info.dart';
import 'model/conversation_search_info.dart';
import 'model/file_record.dart';
import 'model/friend_request.dart';
import 'model/group_info.dart';
import 'model/group_member.dart';
import 'model/group_search_info.dart';
import 'model/im_constant.dart';
import 'model/message_payload.dart';
import 'model/online_info.dart';
import 'model/read_report.dart';
import 'model/unread_count.dart';
import 'model/user_info.dart';


typedef void ConnectionStatusChangedCallback(int status);
typedef void ReceiveMessageCallback(List<Message> messages, bool hasMore);

typedef void SendMessageSuccessCallback(int messageUid, int timestamp);
typedef void SendMediaMessageProgressCallback(int uploaded, int total);
typedef void SendMediaMessageUploadedCallback(String remoteUrl);

typedef void RecallMessageCallback(int messageUid);
typedef void DeleteMessageCallback(int messageUid);

typedef void MessageDeliveriedCallback(Map<String, int> deliveryMap);
typedef void MessageReadedCallback(List<ReadReport> readReports);

typedef void GroupInfoUpdatedCallback(List<GroupInfo> groupInfos);
typedef void GroupMemberUpdatedCallback(
    String groupId, List<GroupMember> members);
typedef void UserInfoUpdatedCallback(List<UserInfo> userInfos);

typedef void FriendListUpdatedCallback(List<String> newFriends);
typedef void FriendRequestListUpdatedCallback(List<String> newRequests);

typedef void UserSettingsUpdatedCallback();

typedef void ChannelInfoUpdatedCallback(List<ChannelInfo> channelInfos);

typedef void OperationFailureCallback(int errorCode);
typedef void OperationSuccessVoidCallback();
typedef void OperationSuccessIntCallback(int i);
typedef void OperationSuccessIntPairCallback(int first, int second);
typedef void OperationSuccessStringCallback(String strValue);
typedef void OperationSuccessMessagesCallback(List<Message> messages);
typedef void OperationSuccessMessageCallback(Message message);
typedef void OperationSuccessUserInfosCallback(List<UserInfo> userInfos);
typedef void OperationSuccessUserInfoCallback(UserInfo userInfo);
typedef void OperationSuccessGroupMembersCallback(List<GroupMember> members);
typedef void OperationSuccessGroupInfoCallback(GroupInfo groupInfo);
typedef void OperationSuccessChannelInfoCallback(ChannelInfo channelInfo);
typedef void OperationSuccessChannelInfosCallback(
    List<ChannelInfo> channelInfos);
typedef void OperationSuccessFilesCallback(List<FileRecord> files);
typedef void OperationSuccessChatroomInfoCallback(ChatroomInfo chatroomInfo);
typedef void OperationSuccessChatroomMemberInfoCallback(
    ChatroomMemberInfo memberInfo);
typedef void OperationSuccessStringListCallback(List<String> strValues);

typedef void GetUploadUrlSuccessCallback(String uploadUrl, String downloadUrl, backupUploadUrl, int type);

/// ????????????????????????clientId???????????????????????????im?????????token???im??????????????????????????????????????????????????????
/// ????????????????????????????????????????????????
const int kConnectionStatusSecretKeyMismatch = -6;

/// token??????
/// ????????????????????????????????????????????????
const int kConnectionStatusTokenIncorrect = -5;

/// IM???????????????
const int kConnectionStatusServerDown = -4;

/// ?????????????????? ????????????????????????????????????????????????
const int kConnectionStatusRejected = -3;

/// ?????????????????????
const int kConnectionStatusLogout = -2;

/// ???????????????
const int kConnectionStatusUnconnected = -1;

/// ?????????
const int kConnectionStatusConnecting = 0;

/// ??????????????????????????????????????????????????????
const int kConnectionStatusConnected = 1;

/// ????????????????????????????????????????????????????????????
const int kConnectionStatusReceiving = 2;

class ConnectionStatusChangedEvent {
  int connectionStatus;

  ConnectionStatusChangedEvent(this.connectionStatus);
}

class UserSettingUpdatedEvent {}

class ReceiveMessagesEvent {
  List<Message> messages;
  bool hasMore;

  ReceiveMessagesEvent(this.messages, this.hasMore);
}

class RecallMessageEvent {
  int messageUid;

  RecallMessageEvent(this.messageUid);
}

class DeleteMessageEvent {
  int messageUid;

  DeleteMessageEvent(this.messageUid);
}

class MessageDeliveriedEvent {
  Map<String, int> deliveryMap;

  MessageDeliveriedEvent(this.deliveryMap);
}

class MessageReadedEvent {
  List<ReadReport> readedReports;

  MessageReadedEvent(this.readedReports);
}

class GroupInfoUpdatedEvent {
  List<GroupInfo> groupInfos;

  GroupInfoUpdatedEvent(this.groupInfos);
}

class GroupMembersUpdatedEvent {
  String groupId;
  List<GroupMember> members;

  GroupMembersUpdatedEvent(this.groupId, this.members);
}

class UserInfoUpdatedEvent {
  List<UserInfo> userInfos;

  UserInfoUpdatedEvent(this.userInfos);
}

class FriendUpdateEvent {
  List<String> newUsers;

  FriendUpdateEvent(this.newUsers);
}

class FriendRequestUpdateEvent {
  List<String> newUserRequests;

  FriendRequestUpdateEvent(this.newUserRequests);
}

class ChannelInfoUpdateEvent {
  List<ChannelInfo> channelInfos;

  ChannelInfoUpdateEvent(this.channelInfos);
}

class ClearConversationUnreadEvent {
  Conversation conversation;

  ClearConversationUnreadEvent(this.conversation);
}

class ClearConversationsUnreadEvent {
  List<ConversationType> types;
  List<int> lines;

  ClearConversationsUnreadEvent(this.types, this.lines);
}

class ClearFriendRequestUnreadEvent {}


class Imclient {
  static EventBus get IMEventBus {
    return ImclientPlatform.instance.IMEventBus;
  }

  ///?????????ID????????????????????????????????????IM Token?????????????????????????????????ID?????????????????????????????????
  static Future<String> get clientId async {
    return ImclientPlatform.instance.clientId;
  }

  ///????????????????????????connect
  static Future<bool> get isLogined async {
    return ImclientPlatform.instance.isLogined;
  }

  ///????????????
  static Future<int> get connectionStatus async {
    return ImclientPlatform.instance.connectionStatus;
  }

  ///????????????ID
  static Future<String> get currentUserId async {
    return ImclientPlatform.instance.currentUserId;
  }

  ///???????????????????????????????????????????????????????????????????????????????????????????????????
  static Future<int> get serverDeltaTime async {
    return ImclientPlatform.instance.serverDeltaTime;
  }

  ///?????????????????????
  static void startLog() async {
    ImclientPlatform.instance.startLog();
  }

  ///?????????????????????
  static void stopLog() async {
    ImclientPlatform.instance.stopLog();
  }

  ///????????????????????????????????????????????????????????????????????????????????????????????????????????????
  static void setSendLogCommand(String sendLogCmd) async {
    ImclientPlatform.instance.setSendLogCommand(sendLogCmd);
  }

  ///???????????????????????????????????????IM?????????????????????????????????????????????
  static void useSM4() async {
    ImclientPlatform.instance.useSM4();
  }

  ///??????lite?????????lite?????????????????????????????????????????????????????????????????????
  static Future<void> setLiteMode(bool liteMode) async {
    ImclientPlatform.instance.setLiteMode(liteMode);
  }

  ///????????????token????????????iOS???????????????0???android???????????????????????????
  static Future<void> setDeviceToken(int pushType, String deviceToken) async {
    ImclientPlatform.instance.setDeviceToken(pushType, deviceToken);
  }

  ///??????voip??????token????????????iOS??????
  static Future<void> setVoipDeviceToken(String voipToken) async {
    ImclientPlatform.instance.setVoipDeviceToken(voipToken);
  }

  ///?????????????????????????????????????????????????????????https://docs.wildfirechat.cn/blogs/??????????????????????????????.html
  static Future<void> setBackupAddressStrategy(int strategy) async {
    ImclientPlatform.instance.setBackupAddressStrategy(strategy);
  }

  ///???????????????????????????????????????????????????
  static Future<void> setBackupAddress(String host, int port) async {
    ImclientPlatform.instance.setBackupAddress(host, port);
  }

  ///??????HTTP User Agent
  static Future<void> setProtoUserAgent(String agent) async {
    ImclientPlatform.instance.setProtoUserAgent(agent);
  }

  ///Http ??????header?????????????????????
  static Future<void> addHttpHeader(String header, String value) async {
    ImclientPlatform.instance.addHttpHeader(header, value);
  }

  ///????????????
  static Future<void> setProxyInfo(String host, String ip, int port, String userName, String password) async {
    ImclientPlatform.instance.setProxyInfo(host, ip, port, userName, password);
  }

  ///???????????????
  static Future<String> get protoRevision async {
    return ImclientPlatform.instance.protoRevision;
  }


  ///?????????????????????????????????
  static Future<List<String>> get logFilesPath async {
    return ImclientPlatform.instance.logFilesPath;
  }

  ///?????????SDK????????????????????????????????????????????????????????????????????????????????????????????????
  static void init(
      ConnectionStatusChangedCallback connectionStatusChangedCallback,
      ReceiveMessageCallback receiveMessageCallback,
      RecallMessageCallback recallMessageCallback,
      DeleteMessageCallback deleteMessageCallback,
      {MessageDeliveriedCallback messageDeliveriedCallback,
        MessageReadedCallback messageReadedCallback,
        GroupInfoUpdatedCallback groupInfoUpdatedCallback,
        GroupMemberUpdatedCallback groupMemberUpdatedCallback,
        UserInfoUpdatedCallback userInfoUpdatedCallback,
        FriendListUpdatedCallback friendListUpdatedCallback,
        FriendRequestListUpdatedCallback friendRequestListUpdatedCallback,
        UserSettingsUpdatedCallback userSettingsUpdatedCallback,
        ChannelInfoUpdatedCallback channelInfoUpdatedCallback}) async {

    registerMessageContent(addGroupMemberNotificationContentMeta);
    registerMessageContent(changeGroupNameNotificationContentMeta);
    registerMessageContent(changeGroupPortraitNotificationContentMeta);
    registerMessageContent(createGroupNotificationContentMeta);
    registerMessageContent(dismissGroupNotificationContentMeta);
    registerMessageContent(groupJoinTypeNotificationContentMeta);
    registerMessageContent(groupMemberAllowNotificationContentMeta);
    registerMessageContent(groupMemberMuteNotificationContentMeta);
    registerMessageContent(groupMuteNotificationContentMeta);
    registerMessageContent(groupPrivateChatNotificationContentMeta);
    registerMessageContent(groupSetManagerNotificationContentMeta);
    registerMessageContent(kickoffGroupMemberNotificationContentMeta);
    registerMessageContent(modifyGroupMemberAliasNotificationContentMeta);
    registerMessageContent(quitGroupNotificationContentMeta);
    registerMessageContent(transferGroupOwnerNotificationContentMeta);

    registerMessageContent(recallNotificationContentMeta);
    registerMessageContent(tipNotificationContentMeta);

    registerMessageContent(cardContentMeta);
    registerMessageContent(compositeContentMeta);
    registerMessageContent(deleteMessageContentMeta);
    registerMessageContent(fileContentMeta);
    registerMessageContent(friendAddedContentMeta);
    registerMessageContent(friendGreetingContentMeta);
    registerMessageContent(imageContentMeta);
    registerMessageContent(linkContentMeta);
    registerMessageContent(locationMessageContentMeta);
    registerMessageContent(pcLoginContentMeta);
    registerMessageContent(ptextContentMeta);
    registerMessageContent(soundContentMeta);
    registerMessageContent(stickerContentMeta);
    registerMessageContent(textContentMeta);
    registerMessageContent(typingContentMeta);
    registerMessageContent(videoContentMeta);

    ImclientPlatform.instance.init(connectionStatusChangedCallback,
        receiveMessageCallback,
        recallMessageCallback,
        deleteMessageCallback,
        messageDeliveriedCallback: messageDeliveriedCallback,
        messageReadedCallback: messageReadedCallback,
        groupInfoUpdatedCallback: groupInfoUpdatedCallback,
        groupMemberUpdatedCallback: groupMemberUpdatedCallback,
        userInfoUpdatedCallback: userInfoUpdatedCallback,
        friendListUpdatedCallback: friendListUpdatedCallback,
        friendRequestListUpdatedCallback: friendRequestListUpdatedCallback,
        userSettingsUpdatedCallback: userSettingsUpdatedCallback,
        channelInfoUpdatedCallback: channelInfoUpdatedCallback);
  }

  ///??????????????????????????????????????????????????????????????????????????????????????????
  static void registerMessageContent(MessageContentMeta contentMeta) {
    ImclientPlatform.instance.registerMessage(contentMeta);
  }

  /// ??????IM???????????????????????????????????????????????????????????????????????????????????????????????????????????????
  /// [host]???IM???????????????IP?????????im.example.com???114.144.114.144?????????http???????????????
  static Future<bool> connect(String host, String userId, String token) async {
    return ImclientPlatform.instance.connect(host, userId, token);
  }

  ///??????IM???????????????
  /// * disablePush ???????????????????????????
  /// * clearSession ????????????session
  static Future<void> disconnect(
      {bool disablePush = false, bool clearSession = false}) async {
    return ImclientPlatform.instance.disconnect(disablePush: disablePush, clearSession: clearSession);
  }

  ///??????????????????
  static Future<List<ConversationInfo>> getConversationInfos(
      List<ConversationType> types, List<int> lines) async {
    return ImclientPlatform.instance.getConversationInfos(types, lines);
  }

  ///??????????????????
  static Future<ConversationInfo> getConversationInfo(
      Conversation conversation) async {
    return ImclientPlatform.instance.getConversationInfo(conversation);
  }

  ///??????????????????
  static Future<List<ConversationSearchInfo>> searchConversation(
      String keyword, List<ConversationType> types, List<int> lines) async {
    return ImclientPlatform.instance.searchConversation(keyword, types, lines);
  }

  ///????????????
  static Future<void> removeConversation(
      Conversation conversation, bool clearMessage) async {
    return ImclientPlatform.instance.removeConversation(conversation, clearMessage);
  }

  ///??????/??????????????????
  static Future<void> setConversationTop(
      Conversation conversation,
      bool isTop,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setConversationTop(conversation, isTop, successCallback, errorCallback);
  }

  ///??????/?????????????????????
  static Future<void> setConversationSilent(
      Conversation conversation,
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setConversationSilent(conversation, isSilent, successCallback, errorCallback);
  }

  ///????????????
  static Future<void> setConversationDraft(
      Conversation conversation, String draft) async {
    return ImclientPlatform.instance.setConversationDraft(conversation, draft);
  }

  ///?????????????????????
  static Future<void> setConversationTimestamp(
      Conversation conversation, int timestamp) async {
    return ImclientPlatform.instance.setConversationTimestamp(conversation, timestamp);
  }

  ///????????????????????????????????????ID
  static Future<int> getFirstUnreadMessageId(Conversation conversation) async {
    return ImclientPlatform.instance.getFirstUnreadMessageId(conversation);
  }

  ///????????????????????????
  static Future<UnreadCount> getConversationUnreadCount(
      Conversation conversation) async {
    return ImclientPlatform.instance.getConversationUnreadCount(conversation);
  }

  ///????????????????????????????????????
  static Future<UnreadCount> getConversationsUnreadCount(
      List<ConversationType> types, List<int> lines) async {
    return ImclientPlatform.instance.getConversationsUnreadCount(types, lines);
  }

  ///?????????????????????????????????
  static Future<bool> clearConversationUnreadStatus(
      Conversation conversation) async {
    return ImclientPlatform.instance.clearConversationUnreadStatus(conversation);
  }

  ///???????????????????????????????????????
  static Future<bool> clearConversationsUnreadStatus(
      List<ConversationType> types, List<int> lines) async {
    return ImclientPlatform.instance.clearConversationsUnreadStatus(types, lines);
  }

  static Future<bool> clearMessageUnreadStatus(int messageId) async {
    return ImclientPlatform.instance.clearMessageUnreadStatus(messageId);
  }

  static Future<bool> markAsUnRead(Conversation conversation, bool syncToOtherClient) async {
    return ImclientPlatform.instance.markAsUnRead(conversation, syncToOtherClient);
  }

  ///???????????????????????????
  static Future<Map<String, int>> getConversationRead(
      Conversation conversation) async {
    return ImclientPlatform.instance.getConversationRead(conversation);
  }

  ///?????????????????????????????????
  static Future<Map<String, int>> getMessageDelivery(
      Conversation conversation) async {
    return ImclientPlatform.instance.getMessageDelivery(conversation);
  }

  static MessageContent decodeMessageContent(MessagePayload payload) {
    return ImclientPlatform.instance.decodeMessageContent(payload);
  }
  ///???????????????????????????
  static Future<List<Message>> getMessages(
      Conversation conversation, int fromIndex, int count,
      {List<int> contentTypes, String withUser}) async {
    return ImclientPlatform.instance.getMessages(conversation, fromIndex, count, contentTypes: contentTypes, withUser: withUser);
  }

  ///?????????????????????????????????????????????
  static Future<List<Message>> getMessagesByStatus(Conversation conversation,
      int fromIndex, int count, List<MessageStatus> messageStatus,
      {String withUser}) async {
    return ImclientPlatform.instance.getMessagesByStatus(conversation, fromIndex, count, messageStatus);
  }

  ///???????????????????????????????????????
  static Future<List<Message>> getConversationsMessages(
      List<ConversationType> types, List<int> lines, int fromIndex, int count,
      {List<int> contentTypes, String withUser}) async {
    return ImclientPlatform.instance.getConversationsMessages(types, lines, fromIndex, count, contentTypes: contentTypes, withUser: withUser);
  }

  ///?????????????????????????????????????????????????????????
  static Future<List<Message>> getConversationsMessageByStatus(
      List<ConversationType> types,
      List<int> lines,
      int fromIndex,
      int count,
      List<MessageStatus> messageStatus,
      {String withUser}) async {
    return ImclientPlatform.instance.getConversationsMessageByStatus(types, lines, fromIndex, count, messageStatus, withUser: withUser);
  }

  ///????????????????????????
  static Future<void> getRemoteMessages(
      Conversation conversation,
      int beforeMessageUid,
      int count,
      OperationSuccessMessagesCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> contentTypes}) async {
    return ImclientPlatform.instance.getRemoteMessages(conversation, beforeMessageUid, count, successCallback, errorCallback, contentTypes: contentTypes);
  }

  static Future<void> getRemoteMessage(
      int messageUid,
      OperationSuccessMessageCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getRemoteMessage(messageUid, successCallback, errorCallback);
  }


  ///????????????Id????????????
  static Future<Message> getMessage(int messageId) async {
    return ImclientPlatform.instance.getMessage(messageId);
  }

  ///????????????Uid????????????
  static Future<Message> getMessageByUid(int messageUid) async {
    return ImclientPlatform.instance.getMessageByUid(messageUid);
  }

  ///???????????????????????????
  static Future<List<Message>> searchMessages(Conversation conversation,
      String keyword, bool order, int limit, int offset) async {
    return ImclientPlatform.instance.searchMessages(conversation, keyword, order, limit, offset);
  }

  ///??????????????????????????????
  static Future<List<Message>> searchConversationsMessages(
      List<ConversationType> types,
      List<int> lines,
      String keyword,
      int fromIndex,
      int count, {
        List<int> contentTypes,
      }) async {
    return ImclientPlatform.instance.searchConversationsMessages(types, lines, keyword, fromIndex, count, contentTypes: contentTypes);
  }

  ///????????????
  static Future<Message> sendMessage(
      Conversation conversation, MessageContent content,
      {List<String> toUsers,
        int expireDuration = 0,
        SendMessageSuccessCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    return sendMediaMessage(conversation, content,
        toUsers: toUsers,
        expireDuration: expireDuration,
        successCallback: successCallback,
        errorCallback: errorCallback);
  }

  ///????????????????????????
  static Future<Message> sendMediaMessage(
      Conversation conversation, MessageContent content,
      {List<String> toUsers,
        int expireDuration,
        SendMessageSuccessCallback successCallback,
        OperationFailureCallback errorCallback,
        SendMediaMessageProgressCallback progressCallback,
        SendMediaMessageUploadedCallback uploadedCallback}) async {
    return ImclientPlatform.instance.sendMediaMessage(conversation, content, toUsers: toUsers, expireDuration: expireDuration, successCallback: successCallback, errorCallback: errorCallback, progressCallback: progressCallback, uploadedCallback: uploadedCallback);
  }

  ///?????????????????????
  static Future<bool> sendSavedMessage(int messageId,
      {int expireDuration,
        SendMessageSuccessCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    return ImclientPlatform.instance.sendSavedMessage(messageId, expireDuration: expireDuration, successCallback: successCallback, errorCallback: errorCallback);
  }

  static Future<bool> cancelSendingMessage(int messageId) async {
    return ImclientPlatform.instance.cancelSendingMessage(messageId);
  }

  ///????????????
  static Future<void> recallMessage(
      int messageUid,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.recallMessage(messageUid, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> uploadMedia(
      String fileName,
      Uint8List mediaData,
      int mediaType,
      OperationSuccessStringCallback successCallback,
      SendMediaMessageProgressCallback progressCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.uploadMedia(fileName, mediaData, mediaType, successCallback, progressCallback, errorCallback);
  }

  static Future<void> getMediaUploadUrl(
      String fileName,
      int mediaType,
      String contentType,
      GetUploadUrlSuccessCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getMediaUploadUrl(fileName, mediaType, contentType, successCallback, errorCallback);
  }

  static Future<bool> isSupportBigFilesUpload() async {
    return ImclientPlatform.instance.isSupportBigFilesUpload();
  }

  ///????????????
  static Future<bool> deleteMessage(int messageId) async {
    return ImclientPlatform.instance.deleteMessage(messageId);
  }

  static Future<bool> batchDeleteMessages(List<int> messageUids) async {
    return ImclientPlatform.instance.batchDeleteMessages(messageUids);
  }

  static Future<void> deleteRemoteMessage(int messageUid,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.deleteRemoteMessage(messageUid, successCallback, errorCallback);
  }

  ///?????????????????????
  static Future<bool> clearMessages(Conversation conversation,
      {int before = 0}) async {
    return ImclientPlatform.instance.clearMessages(conversation, before: before);
  }

  ///??????/?????????????????????
  static Future<void> clearRemoteConversationMessage(Conversation conversation,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.clearRemoteConversationMessage(conversation, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> setMediaMessagePlayed(int messageId) async {
    return ImclientPlatform.instance.setMediaMessagePlayed(messageId);
  }

  static Future<bool> setMessageLocalExtra(int messageId, String localExtra) async {
    return ImclientPlatform.instance.setMessageLocalExtra(messageId, localExtra);
  }

  ///????????????
  static Future<Message> insertMessage(Conversation conversation, String sender,
      MessageContent content, int status, int serverTime) async {
    return ImclientPlatform.instance.insertMessage(conversation, sender, content, status, serverTime);
  }

  ///??????????????????
  static Future<void> updateMessage(
      int messageId, MessageContent content) async {
    return ImclientPlatform.instance.updateMessage(messageId, content);
  }

  static Future<void> updateRemoteMessageContent(
      int messageUid, MessageContent content, bool distribute, bool updateLocal,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.updateRemoteMessageContent(messageUid, content, distribute, updateLocal, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> updateMessageStatus(
      int messageId, MessageStatus status) async {
    return ImclientPlatform.instance.updateMessageStatus(messageId, status);
  }

  ///???????????????????????????
  static Future<int> getMessageCount(Conversation conversation) async {
    return ImclientPlatform.instance.getMessageCount(conversation);
  }

  ///??????????????????
  static Future<UserInfo> getUserInfo(String userId,
      {String groupId, bool refresh = false}) async {
    return ImclientPlatform.instance.getUserInfo(userId, groupId: groupId, refresh: refresh);
  }

  ///????????????????????????
  static Future<List<UserInfo>> getUserInfos(List<String> userIds,
      {String groupId}) async {
    return ImclientPlatform.instance.getUserInfos(userIds, groupId: groupId);
  }

  ///????????????
  static Future<void> searchUser(
      String keyword,
      int searchType,
      int page,
      OperationSuccessUserInfosCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.searchUser(keyword, searchType, page, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> getUserInfoAsync(
      String userId,
      OperationSuccessUserInfoCallback successCallback,
      OperationFailureCallback errorCallback,
      {bool refresh = false}) async {
    return ImclientPlatform.instance.getUserInfoAsync(userId, successCallback, errorCallback, refresh: refresh);
  }

  ///???????????????
  static Future<bool> isMyFriend(String userId) async {
    return ImclientPlatform.instance.isMyFriend(userId);
  }

  ///??????????????????
  static Future<List<String>> getMyFriendList({bool refresh = false}) async {
    return ImclientPlatform.instance.getMyFriendList(refresh: refresh);
  }

  ///????????????
  static Future<List<UserInfo>> searchFriends(String keyword) async {
    return ImclientPlatform.instance.searchFriends(keyword);
  }

  static Future<List<Friend>> getFriends({bool refresh = false}) async {
    return ImclientPlatform.instance.getFriends(refresh);
  }

  ///????????????
  static Future<List<GroupSearchInfo>> searchGroups(String keyword) async {
    return ImclientPlatform.instance.searchGroups(keyword);
  }

  ///?????????????????????????????????
  static Future<List<FriendRequest>> getIncommingFriendRequest() async {
    return ImclientPlatform.instance.getIncommingFriendRequest();
  }

  ///????????????????????????????????????
  static Future<List<FriendRequest>> getOutgoingFriendRequest() async {
    return ImclientPlatform.instance.getOutgoingFriendRequest();
  }

  ///???????????????????????????????????????
  static Future<FriendRequest> getFriendRequest(
      String userId, FriendRequestDirection direction) async {
    return ImclientPlatform.instance.getFriendRequest(userId, direction);
  }

  ///??????????????????????????????
  static Future<void> loadFriendRequestFromRemote() async {
    return ImclientPlatform.instance.loadFriendRequestFromRemote();
  }

  ///???????????????????????????
  static Future<int> getUnreadFriendRequestStatus() async {
    return ImclientPlatform.instance.getUnreadFriendRequestStatus();
  }

  ///??????????????????????????????
  static Future<bool> clearUnreadFriendRequestStatus() async {
    return ImclientPlatform.instance.clearUnreadFriendRequestStatus();
  }

  ///????????????
  static Future<void> deleteFriend(
      String userId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.deleteFriend(userId, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> sendFriendRequest(
      String userId,
      String reason,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.sendFriendRequest(userId, reason, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> handleFriendRequest(
      String userId,
      bool accept,
      String extra,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.handleFriendRequest(userId, accept, extra, successCallback, errorCallback);
  }

  ///?????????????????????
  static Future<String> getFriendAlias(String userId) async {
    return ImclientPlatform.instance.getFriendAlias(userId);
  }

  ///?????????????????????
  static Future<void> setFriendAlias(
      String friendId,
      String alias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setFriendAlias(friendId, alias, successCallback, errorCallback);
  }

  ///????????????extra??????
  static Future<String> getFriendExtra(String userId) async {
    return ImclientPlatform.instance.getFriendExtra(userId);
  }

  ///????????????????????????
  static Future<bool> isBlackListed(String userId) async {
    return ImclientPlatform.instance.isBlackListed(userId);
  }

  ///?????????????????????
  static Future<List<String>> getBlackList({bool refresh = false}) async {
    return ImclientPlatform.instance.getBlackList(refresh: refresh);
  }

  ///??????/?????????????????????
  static Future<void> setBlackList(
      String userId,
      bool isBlackListed,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setBlackList(userId, isBlackListed, successCallback, errorCallback);
  }

  ///?????????????????????
  static Future<List<GroupMember>> getGroupMembers(String groupId,
      {bool refresh = false}) async {
    return ImclientPlatform.instance.getGroupMembers(groupId, refresh: refresh);
  }

  ///??????????????????????????????????????????
  static Future<List<GroupMember>> getGroupMembersByTypes(
      String groupId, GroupMemberType memberType) async {
    return ImclientPlatform.instance.getGroupMembersByTypes(groupId, memberType);
  }

  ///???????????????????????????
  static Future<void> getGroupMembersAsync(String groupId,
      {bool refresh = false,
        OperationSuccessGroupMembersCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    return ImclientPlatform.instance.getGroupMembersAsync(groupId, refresh: refresh, successCallback: successCallback, errorCallback: errorCallback);
  }

  ///???????????????
  static Future<GroupInfo> getGroupInfo(String groupId,
      {bool refresh = false}) async {
    return ImclientPlatform.instance.getGroupInfo(groupId, refresh: refresh);
  }

  ///?????????????????????
  static Future<void> getGroupInfoAsync(String groupId,
      {bool refresh = false,
        OperationSuccessGroupInfoCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    return ImclientPlatform.instance.getGroupInfoAsync(groupId, refresh: refresh, successCallback: successCallback, errorCallback: errorCallback);
  }

  ///???????????????????????????
  static Future<GroupMember> getGroupMember(
      String groupId, String memberId) async {
    return ImclientPlatform.instance.getGroupMember(groupId, memberId);
  }

  ///???????????????groupId???????????????
  static Future<void> createGroup(
      String groupId,
      String groupName,
      String groupPortrait,
      int type,
      List<String> members,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.createGroup(groupId, groupName, groupPortrait, type, members, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///???????????????
  static Future<void> addGroupMembers(
      String groupId,
      List<String> members,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.addGroupMembers(groupId, members, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///???????????????
  static Future<void> kickoffGroupMembers(
      String groupId,
      List<String> members,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.kickoffGroupMembers(groupId, members, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///????????????
  static Future<void> quitGroup(
      String groupId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.quitGroup(groupId, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///????????????
  static Future<void> dismissGroup(
      String groupId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.dismissGroup(groupId, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///??????????????????
  static Future<void> modifyGroupInfo(
      String groupId,
      ModifyGroupInfoType modifyType,
      String newValue,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.modifyGroupInfo(groupId, modifyType, newValue, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///????????????????????????
  static Future<void> modifyGroupAlias(
      String groupId,
      String newAlias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.modifyGroupAlias(groupId, newAlias, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///???????????????????????????
  static Future<void> modifyGroupMemberAlias(
      String groupId,
      String memberId,
      String newAlias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.modifyGroupMemberAlias(groupId, memberId, newAlias, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///????????????
  static Future<void> transferGroup(
      String groupId,
      String newOwner,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.transferGroup(groupId, newOwner, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///??????/??????????????????
  static Future<void> setGroupManager(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.setGroupManager(groupId, isSet, memberIds, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///??????/?????????????????????
  static Future<void> muteGroupMember(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.muteGroupMember(groupId, isSet, memberIds, successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  ///??????/??????????????????
  static Future<void> allowGroupMember(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    return ImclientPlatform.instance.allowGroupMember(groupId, isSet, memberIds,
        successCallback, errorCallback, notifyLines: notifyLines, notifyContent: notifyContent);
  }

  static Future<String> getGroupRemark(String groupId) async {
    return ImclientPlatform.instance.getGroupRemark(groupId);
  }

  static Future<void> setGroupRemark(String groupId, String remark,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setGroupRemark(groupId, remark,
        successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<List<String>> getFavGroups() async {
    return ImclientPlatform.instance.getFavGroups();
  }

  ///??????????????????
  static Future<bool> isFavGroup(String groupId) async {
    return ImclientPlatform.instance.isFavGroup(groupId);
  }

  ///??????/??????????????????
  static Future<void> setFavGroup(
      String groupId,
      bool isFav,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setFavGroup(groupId, isFav, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<String> getUserSetting(int scope, String value) async {
    return ImclientPlatform.instance.getUserSetting(scope, value);
  }

  ///????????????????????????
  static Future<Map<String, String>> getUserSettings(int scope) async {
    return ImclientPlatform.instance.getUserSettings(scope);
  }

  ///??????????????????
  static Future<void> setUserSetting(
      int scope,
      String key,
      String value,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setUserSetting(scope, key, value, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> modifyMyInfo(
      Map<ModifyMyInfoType, String> values,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.modifyMyInfo(values, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<bool> isGlobalSilent() async {
    return ImclientPlatform.instance.isGlobalSilent();
  }

  ///??????/??????????????????
  static Future<void> setGlobalSilent(
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setGlobalSilent(isSilent, successCallback, errorCallback);
  }

  static Future<bool> isVoipNotificationSilent() async {
    return ImclientPlatform.instance.isVoipNotificationSilent();
  }

  static Future<void> setVoipNotificationSilent(
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setVoipNotificationSilent(isSilent, successCallback, errorCallback);
  }

  static Future<bool> isEnableSyncDraft() async {
    return ImclientPlatform.instance.isEnableSyncDraft();
  }

  static Future<void> setEnableSyncDraft(
      bool enable,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setEnableSyncDraft(enable, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> getNoDisturbingTimes(
      OperationSuccessIntPairCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getNoDisturbingTimes(successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> setNoDisturbingTimes(
      int startMins,
      int endMins,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setNoDisturbingTimes(startMins, endMins, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> clearNoDisturbingTimes(
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.clearNoDisturbingTimes(successCallback, errorCallback);
  }

  static Future<bool> isNoDisturbing() async {
    return await ImclientPlatform.instance.isNoDisturbing();
  }

  ///????????????????????????
  static Future<bool> isHiddenNotificationDetail() async {
    return ImclientPlatform.instance.isHiddenNotificationDetail();
  }

  ///????????????????????????
  static Future<void> setHiddenNotificationDetail(
      bool isHidden,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setHiddenNotificationDetail(isHidden, successCallback, errorCallback);
  }

  ///???????????????????????????
  static Future<bool> isHiddenGroupMemberName(String groupId) async {
    return ImclientPlatform.instance.isHiddenGroupMemberName(groupId);
  }

  ///?????????????????????????????????
  static Future<void> setHiddenGroupMemberName(
      bool isHidden,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setHiddenGroupMemberName(isHidden, successCallback, errorCallback);
  }

  static Future<void> getMyGroups(
      OperationSuccessStringListCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getMyGroups(successCallback, errorCallback);
  }

  static Future<void> getCommonGroups(String userId,
      OperationSuccessStringListCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getCommonGroups(userId, successCallback, errorCallback);
  }


  ///????????????????????????????????????
  static Future<bool> isUserEnableReceipt() async {
    return ImclientPlatform.instance.isUserEnableReceipt();
  }

  ///?????????????????????????????????????????????????????????????????????????????????
  static Future<void> setUserEnableReceipt(
      bool isEnable,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setUserEnableReceipt(isEnable, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<List<String>> getFavUsers() async {
    return ImclientPlatform.instance.getFavUsers();
  }

  ///?????????????????????
  static Future<bool> isFavUser(String userId) async {
    return ImclientPlatform.instance.isFavUser(userId);
  }

  ///??????????????????
  static Future<void> setFavUser(
      String userId,
      bool isFav,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.setFavUser(userId, isFav, successCallback, errorCallback);
  }

  ///???????????????
  static Future<void> joinChatroom(
      String chatroomId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.joinChatroom(chatroomId, successCallback, errorCallback);
  }

  ///???????????????
  static Future<void> quitChatroom(
      String chatroomId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.quitChatroom(chatroomId, successCallback, errorCallback);
  }

  ///?????????????????????
  static Future<void> getChatroomInfo(
      String chatroomId,
      int updateDt,
      OperationSuccessChatroomInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getChatroomInfo(chatroomId, updateDt, successCallback, errorCallback);
  }

  ///???????????????????????????
  static Future<void> getChatroomMemberInfo(
      String chatroomId,
      OperationSuccessChatroomMemberInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getChatroomMemberInfo(chatroomId, successCallback, errorCallback);
  }

  ///????????????
  static Future<void> createChannel(
      String channelName,
      String channelPortrait,
      int status,
      String desc,
      String extra,
      OperationSuccessChannelInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.createChannel(channelName, channelPortrait, status, desc, extra, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<ChannelInfo> getChannelInfo(String channelId,
      {bool refresh = false}) async {
    return ImclientPlatform.instance.getChannelInfo(channelId, refresh: refresh);
  }

  ///??????????????????
  static Future<void> modifyChannelInfo(
      String channelId,
      ModifyChannelInfoType modifyType,
      String newValue,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.modifyChannelInfo(channelId, modifyType, newValue, successCallback, errorCallback);
  }

  ///????????????
  static Future<void> searchChannel(
      String keyword,
      OperationSuccessChannelInfosCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.searchChannel(keyword, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<bool> isListenedChannel(String channelId) async {
    return ImclientPlatform.instance.isListenedChannel(channelId);
  }

  ///??????/??????????????????
  static Future<void> listenChannel(
      String channelId,
      bool isListen,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.listenChannel(channelId, isListen, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<List<String>> getMyChannels() async {
    return ImclientPlatform.instance.getMyChannels();
  }

  ///????????????????????????
  static Future<List<String>> getListenedChannels() async {
    return ImclientPlatform.instance.getListenedChannels();
  }

  ///????????????
  static Future<void> destroyChannel(
      String channelId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.destroyChannel(channelId, successCallback, errorCallback);
  }

  ///??????PC???????????????
  static Future<List<OnlineInfo>> getOnlineInfos() async {
    return ImclientPlatform.instance.getOnlineInfos();
  }

  ///??????PC?????????
  static Future<void> kickoffPCClient(
      String clientId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.kickoffPCClient(clientId, successCallback, errorCallback);
  }

  ///???????????????PC???????????????????????????
  static Future<bool> isMuteNotificationWhenPcOnline() async {
    return ImclientPlatform.instance.isMuteNotificationWhenPcOnline();
  }

  ///??????/???????????????PC???????????????????????????
  static Future<void> muteNotificationWhenPcOnline(
      bool isMute,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.muteNotificationWhenPcOnline(isMute, successCallback, errorCallback);
  }

  ///????????????????????????
  static Future<void> getConversationFiles(
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback,
      {Conversation conversation,
        String fromUser}) async {
    return ImclientPlatform.instance.getConversationFiles(beforeMessageUid, count, successCallback, errorCallback, conversation: conversation, fromUser: fromUser);
  }

  ///????????????????????????
  static Future<void> getMyFiles(
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getMyFiles(beforeMessageUid, count, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> deleteFileRecord(
      int messageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.deleteFileRecord(messageUid, count, successCallback, errorCallback);
  }

  ///??????????????????
  static Future<void> searchFiles(
      String keyword,
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback,
      {Conversation conversation,
        String fromUser}) async {
    return ImclientPlatform.instance.searchFiles(keyword, beforeMessageUid, count, successCallback, errorCallback, conversation: conversation, fromUser: fromUser);
  }

  ///????????????????????????
  static Future<void> searchMyFiles(
      String keyword,
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.searchMyFiles(keyword, beforeMessageUid, count, successCallback, errorCallback);
  }

  ///?????????????????????????????????
  static Future<void> getAuthorizedMediaUrl(
      String mediaPath,
      int messageUid,
      int mediaType,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getAuthorizedMediaUrl(mediaPath, messageUid, mediaType, successCallback, errorCallback);
  }

  static Future<void> getAuthCode(
      String applicationId,
      int type,
      String host,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.getAuthCode(applicationId, type, host, successCallback, errorCallback);
  }

  static Future<void> configApplication(
      String applicationId,
      int type,
      int timestamp,
      String nonce,
      String signature,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    return ImclientPlatform.instance.configApplication(applicationId, type, timestamp, nonce, signature, successCallback, errorCallback);
  }

  ///??????amr?????????wav???????????????iOS????????????
  static Future<Uint8List> getWavData(String amrPath) async {
    return ImclientPlatform.instance.getWavData(amrPath);
  }

  ///???????????????????????????????????????????????????????????????
  static Future<bool> beginTransaction() async {
    return ImclientPlatform.instance.beginTransaction();
  }

  ///???????????????????????????????????????????????????????????????
  static Future<bool> commitTransaction() async {
    return ImclientPlatform.instance.commitTransaction();
  }

  ///???????????????????????????????????????????????????????????????
  static Future<bool> rollbackTransaction() async {
    return ImclientPlatform.instance.rollbackTransaction();
  }


  ///??????????????????
  static Future<bool> isCommercialServer() async {
    return ImclientPlatform.instance.isCommercialServer();
  }

  ///??????????????????????????????
  static Future<bool> isReceiptEnabled() async {
    return ImclientPlatform.instance.isReceiptEnabled();
  }

  static Future<bool> isGlobalDisableSyncDraft() async {
    return ImclientPlatform.instance.isGlobalDisableSyncDraft();
  }
}
