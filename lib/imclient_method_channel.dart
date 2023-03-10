import 'dart:convert';
import 'dart:ffi';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:imclient/tools.dart';

import 'imclient.dart';
import 'imclient_platform_interface.dart';
import 'message/message.dart';
import 'message/message_content.dart';
import 'message/unknown_message_content.dart';
import 'model/channel_info.dart';
import 'model/chatroom_info.dart';
import 'model/chatroom_member_info.dart';
import 'model/conversation.dart';
import 'model/conversation_info.dart';
import 'model/conversation_search_info.dart';
import 'model/file_record.dart';
import 'model/friend.dart';
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

/// An implementation of [ImclientPlatform] that uses method channels.
class MethodChannelImclient extends ImclientPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('imclient');

  static ConnectionStatusChangedCallback _connectionStatusChangedCallback;
  static ReceiveMessageCallback _receiveMessageCallback;
  static RecallMessageCallback _recallMessageCallback;
  static DeleteMessageCallback _deleteMessageCallback;
  static MessageDeliveriedCallback _messageDeliveriedCallback;
  static MessageReadedCallback _messageReadedCallback;
  static GroupInfoUpdatedCallback _groupInfoUpdatedCallback;
  static GroupMemberUpdatedCallback _groupMemberUpdatedCallback;
  static UserInfoUpdatedCallback _userInfoUpdatedCallback;
  static FriendListUpdatedCallback _friendListUpdatedCallback;
  static FriendRequestListUpdatedCallback _friendRequestListUpdatedCallback;
  static UserSettingsUpdatedCallback _userSettingsUpdatedCallback;
  static ChannelInfoUpdatedCallback _channelInfoUpdatedCallback;


  static int _requestId = 0;
  static final Map<int, SendMessageSuccessCallback> _sendMessageSuccessCallbackMap =
  {};
  static final Map<int, OperationFailureCallback> _errorCallbackMap = {};
  static final Map<int, SendMediaMessageProgressCallback>
  _sendMediaMessageProgressCallbackMap = {};
  static final Map<int, SendMediaMessageUploadedCallback>
  _sendMediaMessageUploadedCallbackMap = {};

  static final Map<int, dynamic> _operationSuccessCallbackMap = {};


  static final EventBus _eventBus = EventBus();

  // ignore: non_constant_identifier_names
  @override
  EventBus get IMEventBus {
    return _eventBus;
  }

  ///?????????ID????????????????????????????????????IM Token?????????????????????????????????ID?????????????????????????????????
  @override
  Future<String> get clientId async {
    return await methodChannel.invokeMethod('getClientId');
  }

  ///????????????????????????connect
  @override
  Future<bool> get isLogined async {
    return await methodChannel.invokeMethod('isLogined');
  }

  ///????????????
  @override
  Future<int> get connectionStatus async {
    return await methodChannel.invokeMethod('connectionStatus');
  }

  ///????????????ID
  @override
  Future<String> get currentUserId async {
    return await methodChannel.invokeMethod('currentUserId');
  }

  ///???????????????????????????????????????????????????????????????????????????????????????????????????
  @override
  Future<int> get serverDeltaTime async {
    return await methodChannel.invokeMethod('serverDeltaTime');
  }

  ///?????????????????????
  @override
  void startLog() async {
    methodChannel.invokeMethod('startLog');
  }

  ///?????????????????????
  @override
  void stopLog() async {
    methodChannel.invokeMethod('stopLog');
  }

  @override
  void setSendLogCommand(String sendLogCmd) async {
    methodChannel.invokeMethod('setSendLogCommand', {"cmd":sendLogCmd});
  }

  @override
  void useSM4() async {
    methodChannel.invokeMethod('useSM4');
  }

  @override
  Future<void> setLiteMode(bool liteMode) async {
    return methodChannel.invokeMethod('setLiteMode', {"liteMode":liteMode});
  }

  @override
  Future<void> setDeviceToken(int pushType, String deviceToken) async {
    return methodChannel.invokeMethod('setDeviceToken', {"pushType":pushType, "deviceToken":deviceToken});
  }

  @override
  Future<void> setVoipDeviceToken(String voipToken) async {
    return methodChannel.invokeMethod('setVoipDeviceToken', {"voipToken":voipToken});
  }

  @override
  Future<void> setBackupAddressStrategy(int strategy) async {
    return methodChannel.invokeMethod('setBackupAddressStrategy', {"strategy":strategy});
  }

  @override
  Future<void> setBackupAddress(String host, int port) async {
    return methodChannel.invokeMethod('setBackupAddress', {"host":host, "port":port});
  }

  @override
  Future<void> setProtoUserAgent(String agent) async {
    return methodChannel.invokeMethod('setProtoUserAgent', {"agent":agent});
  }

  @override
  Future<void> addHttpHeader(String header, String value) async {
    return methodChannel.invokeMethod('addHttpHeader', {"header":header, "value":value});
  }

  @override
  Future<void> setProxyInfo(String host, String ip, int port, String userName, String password) async {
    return methodChannel.invokeMethod('setProxyInfo', {"host":host, "ip":ip, "port":port, "userName":userName, "password":password});
  }

  @override
  Future<String> get protoRevision async {
    return await methodChannel.invokeMethod('getProtoRevision');
  }

  ///?????????????????????????????????
  @override
  Future<List<String>> get logFilesPath async {
    return Tools.convertDynamicList(await methodChannel.invokeMethod('getLogFilesPath'));
  }

  @override
  void init(
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
    _connectionStatusChangedCallback = connectionStatusChangedCallback;
    _receiveMessageCallback = receiveMessageCallback;
    _recallMessageCallback = recallMessageCallback;
    _deleteMessageCallback = deleteMessageCallback;
    _messageDeliveriedCallback = messageDeliveriedCallback;
    _messageReadedCallback = messageReadedCallback;
    _groupInfoUpdatedCallback = groupInfoUpdatedCallback;
    _groupMemberUpdatedCallback = groupMemberUpdatedCallback;
    _userInfoUpdatedCallback = userInfoUpdatedCallback;
    _friendListUpdatedCallback = friendListUpdatedCallback;
    _friendRequestListUpdatedCallback = friendRequestListUpdatedCallback;
    _userSettingsUpdatedCallback = userSettingsUpdatedCallback;
    _channelInfoUpdatedCallback = channelInfoUpdatedCallback;


    methodChannel.invokeMethod<Void>('initProto');

    methodChannel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'onConnectionStatusChanged':
          int status = call.arguments;
          if (_connectionStatusChangedCallback != null) {
            _connectionStatusChangedCallback(status);
          }
          _eventBus.fire(ConnectionStatusChangedEvent(status));
          break;
        case 'onReceiveMessage':
          Map<dynamic, dynamic> args = call.arguments;
          bool hasMore = args['hasMore'];
          List<dynamic> list = args['messages'];
          _convertProtoMessages(list).then((value) {
            if (_receiveMessageCallback != null) {
              _receiveMessageCallback(value, hasMore);
            }
            _eventBus.fire(ReceiveMessagesEvent(value, hasMore));
          });
          break;
        case 'onRecallMessage':
          Map<dynamic, dynamic> args = call.arguments;
          int messageUid = args['messageUid'];
          if (_recallMessageCallback != null) {
            _recallMessageCallback(messageUid);
          }
          _eventBus.fire(RecallMessageEvent(messageUid));
          break;
        case 'onDeleteMessage':
          Map<dynamic, dynamic> args = call.arguments;
          int messageUid = args['messageUid'];
          if (_deleteMessageCallback != null) {
            _deleteMessageCallback(messageUid);
          }
          _eventBus.fire(DeleteMessageEvent(messageUid));
          break;
        case 'onMessageDelivered':
          Map<dynamic, dynamic> args = call.arguments;
          Map<String, int> data = new Map();
          args.forEach((key, value) {
            data[key] = value;
          });
          if (_messageDeliveriedCallback != null) {
            _messageDeliveriedCallback(data);
          }
          _eventBus.fire(MessageDeliveriedEvent(data));
          break;
        case 'onMessageReaded':
          Map<dynamic, dynamic> args = call.arguments;
          List<dynamic> reads = args['readeds'];
          List<ReadReport> reports = new List();
          reads.forEach((element) {
            reports.add(_convertProtoReadEntry(element));
          });
          if (_messageReadedCallback != null) {
            _messageReadedCallback(reports);
          }
          _eventBus.fire(MessageReadedEvent(reports));
          break;
        case 'onConferenceEvent':
          break;
        case 'onGroupInfoUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          List<dynamic> groups = args['groups'];
          List<GroupInfo> data = new List();
          groups.forEach((element) {
            data.add(_convertProtoGroupInfo(element));
          });
          if (_groupInfoUpdatedCallback != null) {
            _groupInfoUpdatedCallback(data);
          }
          _eventBus.fire(GroupInfoUpdatedEvent(data));
          break;
        case 'onGroupMemberUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          String groupId = args['groupId'];
          List<dynamic> members = args['members'];
          List<GroupMember> data = new List();
          members.forEach((element) {
            data.add(_convertProtoGroupMember(element));
          });
          if (_groupMemberUpdatedCallback != null) {
            _groupMemberUpdatedCallback(groupId, data);
          }
          _eventBus.fire(GroupMembersUpdatedEvent(groupId, data));
          break;
        case 'onUserInfoUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          List<dynamic> users = args['users'];
          List<UserInfo> data = new List();
          users.forEach((element) {
            data.add(_convertProtoUserInfo(element));
          });
          if (_userInfoUpdatedCallback != null) {
            _userInfoUpdatedCallback(data);
          }
          _eventBus.fire(UserInfoUpdatedEvent(data));

          break;
        case 'onFriendListUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          List<dynamic> friendIdList = args['friends'];
          List<String> friends = List(0);
          friendIdList.forEach((element) => friends.add(element));
          if (_friendListUpdatedCallback != null) {
            _friendListUpdatedCallback(friends);
          }
          _eventBus.fire(FriendUpdateEvent(friends));
          break;
        case 'onFriendRequestUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          final friendRequestList = (args['requests'] as List).cast<String>();
          if (_friendRequestListUpdatedCallback != null) {
            _friendRequestListUpdatedCallback(friendRequestList);
          }
          _eventBus.fire(FriendRequestUpdateEvent(friendRequestList));
          break;
        case 'onSettingUpdated':
          if (_userSettingsUpdatedCallback != null) {
            _userSettingsUpdatedCallback();
          }
          _eventBus.fire(UserSettingUpdatedEvent());
          break;
        case 'onChannelInfoUpdated':
          Map<dynamic, dynamic> args = call.arguments;
          List<dynamic> channels = args['channels'];
          List<ChannelInfo> data = new List();
          channels.forEach((element) {
            data.add(_convertProtoChannelInfo(element));
          });
          if (_channelInfoUpdatedCallback != null) {
            _channelInfoUpdatedCallback(data);
          }
          _eventBus.fire(ChannelInfoUpdateEvent(data));
          break;
        case 'onSendMessageSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          int messageUid = args['messageUid'];
          int timestamp = args['timestamp'];
          var callback = _sendMessageSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(messageUid, timestamp);
          }
          _removeSendMessageCallback(requestId);
          break;
        case 'onSendMediaMessageProgress':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          int uploaded = args['uploaded'];
          int total = args['total'];
          var callback = _sendMediaMessageProgressCallbackMap[requestId];
          if (callback != null) {
            callback(uploaded, total);
          }
          break;
        case 'onSendMediaMessageUploaded':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          String remoteUrl = args['remoteUrl'];
          var callback = _sendMediaMessageUploadedCallbackMap[requestId];
          if (callback != null) {
            callback(remoteUrl);
          }
          break;
        case 'onOperationVoidSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback();
          }
          _removeOperationCallback(requestId);
          break;

        case 'onMessagesCallback':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<dynamic> datas = args['messages'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoMessages(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onMessageCallback':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map datas = args['message'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoMessage(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onGetUploadUrl':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          String uploadUrl = args['uploadUrl'];
          String downloadUrl = args['downloadUrl'];
          String backupUploadUrl = args['backupUploadUrl'];
          int type = args['type'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(uploadUrl, downloadUrl, backupUploadUrl, type);
          }
          _removeOperationCallback(requestId);
          break;
        case 'onSearchUserResult':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<dynamic> datas = args['users'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoUserInfos(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'getUserInfoAsyncCallback':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map<dynamic, dynamic> data = args['user'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoUserInfo(data));
          }
          _removeOperationCallback(requestId);
          break;
        case 'getGroupMembersAsyncCallback':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<dynamic> datas = args['members'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoGroupMembers(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'getGroupInfoAsyncCallback':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map<dynamic, dynamic> data = args['groupInfo'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoGroupInfo(data));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onOperationStringSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          String strValue = args['string'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(strValue);
          }
          _removeOperationCallback(requestId);
          break;
        case 'onOperationStringListSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<String> strList = args['strings'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(strList);
          }
          _removeOperationCallback(requestId);
          break;
        case 'onFilesResult':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<dynamic> datas = args['files'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoFileRecords(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onSearchChannelResult':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          List<dynamic> datas = args['channelInfos'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoChannelInfos(datas));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onCreateChannelSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map<dynamic, dynamic> data = args['channelInfo'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoChannelInfo(data));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onOperationIntPairSuccess':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          int first = args['first'];
          int second = args['second'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(first, second);
          }
          _removeOperationCallback(requestId);
          break;
        case 'onGetChatroomInfoResult':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map<dynamic, dynamic> data = args['chatroomInfo'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoChatroomInfo(data));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onGetChatroomMemberInfoResult':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          Map<dynamic, dynamic> data = args['chatroomMemberInfo'];
          var callback = _operationSuccessCallbackMap[requestId];
          if (callback != null) {
            callback(_convertProtoChatroomMemberInfo(data));
          }
          _removeOperationCallback(requestId);
          break;
        case 'onOperationFailure':
          Map<dynamic, dynamic> args = call.arguments;
          int requestId = args['requestId'];
          int errorCode = args['errorCode'];
          var callback = _errorCallbackMap[requestId];
          if (callback != null) {
            callback(errorCode);
          }
          _removeAllOperationCallback(requestId);
          break;
      }

      return Future(null);
    });
  }


  static void _removeSendMessageCallback(int requestId) {
    _sendMessageSuccessCallbackMap.remove(requestId);
    _errorCallbackMap.remove(requestId);
    _sendMediaMessageProgressCallbackMap.remove(requestId);
    _sendMediaMessageUploadedCallbackMap.remove(requestId);
  }

  static void _removeAllOperationCallback(int requestId) {
    _sendMessageSuccessCallbackMap.remove(requestId);
    _errorCallbackMap.remove(requestId);
    _sendMediaMessageProgressCallbackMap.remove(requestId);
    _sendMediaMessageUploadedCallbackMap.remove(requestId);
    _operationSuccessCallbackMap.remove(requestId);
  }

  static void _removeOperationCallback(int requestId) {
    _errorCallbackMap.remove(requestId);
    _operationSuccessCallbackMap.remove(requestId);
  }

  @override
  void registerMessage(MessageContentMeta contentMeta) {
    _contentMetaMap.putIfAbsent(contentMeta.type, () => contentMeta);
    Map<String, dynamic> map = new Map();
    map["type"] = contentMeta.type;
    map["flag"] = contentMeta.flag.index;
    methodChannel.invokeMethod('registerMessage', map);
  }


  Future<Message> _convertProtoMessage(Map<dynamic, dynamic> map) async {
    if (map == null) {
      return null;
    }

    Message msg = new Message();
    msg.messageId = map['messageId'];
    if(map['messageUid'] is String) {
      String str = map['messageUid'];
      str = str.replaceAll("L", "");
      msg.messageUid = int.tryParse(str);
    } else {
      msg.messageUid = map['messageUid'];
    }

    msg.conversation = _convertProtoConversation(map['conversation']);
    msg.fromUser = map['sender'];
    msg.toUsers = (map['toUsers'] as List)?.cast<String>();
    msg.content =
        decodeMessageContent(_convertProtoMessageContent(map['content']));
    msg.direction = MessageDirection.values[map['direction']];
    msg.status = MessageStatus.values[map['status']];
    msg.serverTime = map['serverTime'];
    msg.localExtra = map['localExtra'];
    return msg;
  }

  Future<List<Message>> _convertProtoMessages(
      List<dynamic> datas) async {
    if (datas.isEmpty) {
      return new List();
    }
    List<Message> messages = new List();
    for (int i = 0; i < datas.length; ++i) {
      var element = datas[i];
      Message msg = await _convertProtoMessage(element);
      messages.add(msg);
    }
    return messages;
  }

  static Conversation _convertProtoConversation(Map<dynamic, dynamic> map) {
    Conversation conversation = new Conversation();
    conversation.conversationType = ConversationType.values[map['type']];
    conversation.target = map['target'];
    if (map['line'] == null) {
      conversation.line = 0;
    } else {
      conversation.line = map['line'];
    }

    return conversation;
  }

  Future<List<ConversationInfo>> _convertProtoConversationInfos(
      List<dynamic> maps) async {
    if (maps == null || maps.isEmpty) {
      return new List();
    }
    List<ConversationInfo> infos = new List();
    for (int i = 0; i < maps.length; ++i) {
      var element = maps[i];
      infos.add(await _convertProtoConversationInfo(element));
    }

    return infos;
  }

  Future<ConversationInfo> _convertProtoConversationInfo(
      Map<dynamic, dynamic> map) async {
    ConversationInfo conversationInfo = new ConversationInfo();
    conversationInfo.conversation =
        _convertProtoConversation(map['conversation']);
    conversationInfo.lastMessage =
    await _convertProtoMessage(map['lastMessage']);
    conversationInfo.draft = map['draft'];
    if (map['timestamp'] != null) conversationInfo.timestamp = map['timestamp'];
    if (map['isTop'] != null) conversationInfo.isTop = map['isTop'];
    if (map['isSilent'] != null) conversationInfo.isSilent = map['isSilent'];
    conversationInfo.unreadCount = _convertProtoUnreadCount(map['unreadCount']);

    return conversationInfo;
  }

  Future<List<ConversationSearchInfo>>
  _convertProtoConversationSearchInfos(List<dynamic> maps) async {
    if (maps.isEmpty) {
      return new List();
    }

    List<ConversationSearchInfo> infos = new List();
    for (int i = 0; i < maps.length; i++) {
      var element = maps[i];
      infos.add(await _convertProtoConversationSearchInfo(element));
    }

    return infos;
  }

  Future<ConversationSearchInfo> _convertProtoConversationSearchInfo(
      Map<dynamic, dynamic> map) async {
    ConversationSearchInfo conversationInfo = new ConversationSearchInfo();
    conversationInfo.conversation =
        _convertProtoConversation(map['conversation']);
    conversationInfo.marchedMessage =
    await _convertProtoMessage(map['marchedMessage']);
    if (map['marchedCount'] != null) {
      conversationInfo.marchedCount = map['marchedCount'];
    }
    conversationInfo.timestamp = map['timestamp'];
    return conversationInfo;
  }

  static FriendRequest _convertProtoFriendRequest(Map<dynamic, dynamic> data) {
    FriendRequest friendRequest = new FriendRequest();
    friendRequest.target = data['target'];
    friendRequest.direction = FriendRequestDirection.values[data['direction']];
    friendRequest.reason = data['reason'];
    friendRequest.status = FriendRequestStatus.values[data['status']];
    friendRequest.readStatus =
    FriendRequestReadStatus.values[data['readStatus']];
    friendRequest.timestamp = data['timestamp'];
    return friendRequest;
  }

  static List<FriendRequest> _convertProtoFriendRequests(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }

    List<FriendRequest> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoFriendRequest(element));
    });
    return list;
  }

  static Friend _convertProtoFriend(Map<dynamic, dynamic> data) {
    Friend friend = Friend();
    friend.userId = data['userId'];
    friend.alias = data['alias'];
    friend.extra = data['extra'];
    friend.timestamp = data['timestamp'];
    return friend;
  }

  static List<Friend> _convertProtoFriends(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }

    List<Friend> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoFriend(element));
    });
    return list;
  }

  static List<GroupSearchInfo> _convertProtoGroupSearchInfos(
      List<dynamic> maps) {
    if (maps.isEmpty) {
      return new List();
    }

    List<GroupSearchInfo> infos = new List();
    maps.forEach((element) {
      infos.add(_convertProtoGroupSearchInfo(element));
    });

    return infos;
  }

  static GroupSearchInfo _convertProtoGroupSearchInfo(
      Map<dynamic, dynamic> map) {
    GroupSearchInfo groupSearchInfo = new GroupSearchInfo();
    groupSearchInfo.groupInfo = _convertProtoGroupInfo(map['groupInfo']);
    groupSearchInfo.marchType = GroupSearchResultType.values[map['marchType']];
    groupSearchInfo.marchedMemberNames = map['marchedMemberNames'];

    return groupSearchInfo;
  }

  static UnreadCount _convertProtoUnreadCount(Map<dynamic, dynamic> map) {
    if (map == null) {
      return null;
    }
    UnreadCount unreadCount = new UnreadCount();
    if (map['unread'] != null) unreadCount.unread = map['unread'];
    if (map['unreadMention'] != null)
      unreadCount.unreadMention = map['unreadMention'];
    if (map['unreadMentionAll'] != null)
      unreadCount.unreadMentionAll = map['unreadMentionAll'];
    return unreadCount;
  }

  static MessagePayload _convertProtoMessageContent(Map<dynamic, dynamic> map) {
    MessagePayload payload = new MessagePayload();
    payload.contentType = map['type'];
    payload.searchableContent = map['searchableContent'];
    payload.pushContent = map['pushContent'];
    payload.pushData = map['pushData'];
    payload.content = map['content'];
    String str = map['binaryContent'];
    if(str != null) {
      payload.binaryContent = base64Decode(str);
    }
    payload.localContent = map['localContent'];
    if (map['mentionedType'] != null)
      payload.mentionedType = map['mentionedType'];
    payload.mentionedTargets = Tools.convertDynamicList(map['mentionedTargets']);

    if (map['mediaType'] != null) {
      payload.mediaType = MediaType.values[map['mediaType']];
    }
    payload.remoteMediaUrl = map['remoteMediaUrl'];
    payload.localMediaPath = map['localMediaPath'];

    payload.extra = map['extra'];
    return payload;
  }

  static Map<String, dynamic> _convertConversation(Conversation conversation) {
    Map<String, dynamic> map = new Map();

    map['type'] = conversation.conversationType.index;
    map['target'] = conversation.target;
    map['line'] = conversation.line;
    return map;
  }

  static Future<Map<String, dynamic>> _convertMessageContent(
      MessageContent content) async {
    if (content == null) return null;

    Map<String, dynamic> map = new Map();
    MessagePayload payload = await content.encode();
    map['type'] = payload.contentType;
    if (payload.searchableContent != null)
      map['searchableContent'] = payload.searchableContent;
    if (payload.pushContent != null) map['pushContent'] = payload.pushContent;
    if (payload.pushData != null) map['pushData'] = payload.pushData;
    if (payload.content != null) map['content'] = payload.content;
    if (payload.binaryContent != null)
      map['binaryContent'] = payload.binaryContent;
    if (payload.localContent != null)
      map['localContent'] = payload.localContent;
    if (payload.mentionedType != null)
      map['mentionedType'] = payload.mentionedType;
    if (payload.mentionedTargets != null)
      map['mentionedTargets'] = payload.mentionedTargets;
    map['mediaType'] = payload.mediaType.index;
    if (payload.remoteMediaUrl != null)
      map['remoteMediaUrl'] = payload.remoteMediaUrl;
    if (payload.localMediaPath != null)
      map['localMediaPath'] = payload.localMediaPath;
    if (payload.extra != null) map['extra'] = payload.extra;
    return map;
  }

  static ReadReport _convertProtoReadEntry(Map<dynamic, dynamic> map) {
    ReadReport report = new ReadReport();
    report.conversation = _convertProtoConversation(map['conversation']);
    report.userId = map['userId'];
    report.readDt = map['readDt'];
    return report;
  }

  static GroupInfo _convertProtoGroupInfo(Map<dynamic, dynamic> map) {
    if (map == null) return null;

    GroupInfo groupInfo = new GroupInfo();
    groupInfo.type = GroupType.values[map['type']];
    groupInfo.target = map['target'];
    groupInfo.name = map['name'];
    groupInfo.extra = map['extra'];
    groupInfo.portrait = map['portrait'];
    groupInfo.owner = map['owner'];
    if (map['memberCount'] != null) groupInfo.memberCount = map['memberCount'];
    if (map['mute'] != null) groupInfo.mute = map['mute'];

    if (map['joinType'] != null) groupInfo.joinType = map['joinType'];
    if (map['privateChat'] != null) groupInfo.privateChat = map['privateChat'];
    if (map['searchable'] != null) groupInfo.searchable = map['searchable'];
    if (map['historyMessage'] != null)
      groupInfo.historyMessage = map['historyMessage'];
    if (map['updateDt'] != null) groupInfo.updateDt = map['updateDt'];
    return groupInfo;
  }

  static GroupMember _convertProtoGroupMember(Map<dynamic, dynamic> map) {
    GroupMember groupMember = new GroupMember();
    if (map['type'] != null)
      groupMember.type = GroupMemberType.values[map['type']];
    else
      groupMember.type = GroupMemberType.Normal;

    groupMember.groupId = map['groupId'];
    groupMember.memberId = map['memberId'];
    groupMember.alias = map['alias'];

    if (map['updateDt'] != null) groupMember.updateDt = map['updateDt'];
    if (map['createDt'] != null) groupMember.createDt = map['createDt'];

    return groupMember;
  }

  static List<GroupMember> _convertProtoGroupMembers(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }
    List<GroupMember> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoGroupMember(element));
    });
    return list;
  }

  static UserInfo _convertProtoUserInfo(Map<dynamic, dynamic> map) {
    if (map == null) {
      return null;
    }
    UserInfo userInfo = new UserInfo();
    userInfo.userId = map['uid'];
    userInfo.name = map['name'];
    userInfo.displayName = map['displayName'];
    if (map['gender'] != null) userInfo.gender = map['gender'];
    userInfo.portrait = map['portrait'];
    userInfo.mobile = map['mobile'];
    userInfo.email = map['email'];
    userInfo.address = map['address'];
    userInfo.company = map['company'];
    userInfo.social = map['social'];
    userInfo.extra = map['extra'];
    userInfo.friendAlias = map['friendAlias'];
    userInfo.groupAlias = map['groupAlias'];
    if (map['updateDt'] != null) userInfo.updateDt = map['updateDt'];
    if (map['type'] != null) userInfo.type = map['type'];
    if (map['deleted'] != null) userInfo.deleted = map['deleted'];
    return userInfo;
  }

  static List<UserInfo> _convertProtoUserInfos(List<dynamic> datas) {
    if (datas == null || datas.isEmpty) {
      return new List();
    }
    List<UserInfo> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoUserInfo(element));
    });
    return list;
  }

  static ChannelInfo _convertProtoChannelInfo(Map<dynamic, dynamic> map) {
    if(map == null) {
      return null;
    }
    ChannelInfo channelInfo = new ChannelInfo();
    channelInfo.channelId = map['channelId'];
    channelInfo.desc = map['desc'];
    channelInfo.extra = map['extra'];
    channelInfo.name = map['name'];
    channelInfo.portrait = map['portrait'];
    channelInfo.owner = map['owner'];
    channelInfo.secret = map['secret'];
    channelInfo.callback = map['callback'];
    if (map['status'] != null)
      channelInfo.status = ChannelStatus.values[map['status']];
    if (map['updateDt'] != null) channelInfo.updateDt = map['updateDt'];

    return channelInfo;
  }

  static List<ChannelInfo> _convertProtoChannelInfos(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }
    List<ChannelInfo> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoChannelInfo(element));
    });
    return list;
  }

  static ChatroomInfo _convertProtoChatroomInfo(Map<dynamic, dynamic> map) {
    ChatroomInfo chatroomInfo = new ChatroomInfo();
    chatroomInfo.chatroomId = map['chatroomId'];
    chatroomInfo.desc = map['desc'];
    chatroomInfo.extra = map['extra'];
    chatroomInfo.portrait = map['portrait'];
    chatroomInfo.title = map['title'];
    if (map['status'] != null)
      chatroomInfo.state = ChatroomState.values[map['state']];
    if (map['memberCount'] != null)
      chatroomInfo.memberCount = map['memberCount'];
    if (map['createDt'] != null) chatroomInfo.createDt = map['createDt'];
    if (map['updateDt'] != null) chatroomInfo.updateDt = map['updateDt'];

    return chatroomInfo;
  }

  static FileRecord _convertProtoFileRecord(Map<dynamic, dynamic> map) {
    FileRecord record = new FileRecord();
    Map<dynamic, dynamic> conversation = map['conversation'];
    record.conversation = _convertProtoConversation(conversation);
    record.userId = map['userId'];
    record.messageUid = map['messageUid'];
    record.name = map['name'];
    record.url = map['url'];
    record.size = map['size'];
    record.downloadCount = map['downloadCount'];
    record.timestamp = map['timestamp'];
    return record;
  }

  static List<FileRecord> _convertProtoFileRecords(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }
    List<FileRecord> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoFileRecord(element));
    });
    return list;
  }

  static ChatroomMemberInfo _convertProtoChatroomMemberInfo(
      Map<dynamic, dynamic> map) {
    ChatroomMemberInfo chatroomInfo = new ChatroomMemberInfo();
    chatroomInfo.members = map['members'];
    if (map['memberCount'] != null)
      chatroomInfo.memberCount = map['memberCount'];

    return chatroomInfo;
  }

  static OnlineInfo _convertProtoOnlineInfo(Map<dynamic, dynamic> data) {
    OnlineInfo info = new OnlineInfo();
    info.type = data['type'];
    info.isOnline = data['isOnline'];
    info.platform = data['platform'];
    info.clientId = data['clientId'];
    info.clientName = data['clientName'];
    info.timestamp = data['timestamp'];
    return info;
  }

  static List<OnlineInfo> _convertProtoOnlineInfos(List<dynamic> datas) {
    if (datas.isEmpty) {
      return new List();
    }
    List<OnlineInfo> list = new List();
    datas.forEach((element) {
      list.add(_convertProtoOnlineInfo(element));
    });
    return list;
  }

  static List<int> _convertMessageStatusList(List<MessageStatus> status) {
    if (status.isEmpty) {
      return new List();
    }
    List<int> list = new List();
    status.forEach((element) {
      list.add(element.index);
    });
    return list;
  }

  @override
  MessageContent decodeMessageContent(MessagePayload payload) {
    MessageContentMeta meta = _contentMetaMap[payload.contentType];
    MessageContent content;
    if (meta == null) {
      content = new UnknownMessageContent();
    } else {
      content = meta.creator();
    }
    content.decode(payload);
    return content;
  }

  static Map<int, MessageContentMeta> _contentMetaMap = {};

  /// ??????IM???????????????????????????????????????????????????????????????????????????????????????????????????????????????
  /// [host]???IM???????????????IP?????????im.example.com???114.144.114.144?????????http???????????????
  @override
  Future<bool> connect(String host, String userId, String token) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('host', () => host);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('token', () => token);
    final bool newDb = await methodChannel.invokeMethod('connect', args);
    return newDb;
  }

  ///??????IM???????????????
  /// * disablePush ???????????????????????????
  /// * clearSession ????????????session
  @override
  Future<void> disconnect(
      {bool disablePush = false, bool clearSession = false}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('disablePush', () => disablePush);
    args.putIfAbsent('clearSession', () => clearSession);
    await methodChannel.invokeMethod('disconnect', args);
  }

  ///??????????????????
  @override
  Future<List<ConversationInfo>> getConversationInfos(
      List<ConversationType> types, List<int> lines) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    List<dynamic> datas = await methodChannel.invokeMethod(
        'getConversationInfos', {'types': itypes, 'lines': lines});
    List<ConversationInfo> infos = await _convertProtoConversationInfos(datas);
    return infos;
  }

  ///??????????????????
  @override
  Future<ConversationInfo> getConversationInfo(
      Conversation conversation) async {
    var args = _convertConversation(conversation);
    Map<dynamic, dynamic> datas =
    await methodChannel.invokeMethod("getConversationInfo", args);
    ConversationInfo info = await _convertProtoConversationInfo(datas);
    return info;
  }

  ///??????????????????
  @override
  Future<List<ConversationSearchInfo>> searchConversation(
      String keyword, List<ConversationType> types, List<int> lines) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    List<dynamic> datas = await methodChannel.invokeMethod('searchConversation',
        {'keyword': keyword, 'types': itypes, 'lines': lines});
    List<ConversationSearchInfo> infos =
    await _convertProtoConversationSearchInfos(datas);
    return infos;
  }

  ///????????????
  @override
  Future<void> removeConversation(
      Conversation conversation, bool clearMessage) async {
    Map<String, dynamic> args = new Map();
    args['conversation'] = _convertConversation(conversation);
    args['clearMessage'] = clearMessage;
    await methodChannel.invokeMethod("removeConversation", args);
    return;
  }

  ///??????/??????????????????
  @override
  Future<void> setConversationTop(
      Conversation conversation,
      bool isTop,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null) {
      _operationSuccessCallbackMap.putIfAbsent(
          requestId, () => successCallback);
    }
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    await methodChannel.invokeMethod("setConversationTop", {
      "requestId": requestId,
      'conversation': _convertConversation(conversation),
      "isTop": isTop
    });
  }

  ///??????/?????????????????????
  @override
  Future<void> setConversationSilent(
      Conversation conversation,
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null) {
      _operationSuccessCallbackMap.putIfAbsent(
          requestId, () => successCallback);
    }
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    await methodChannel.invokeMethod("setConversationSilent", {
      "requestId": requestId,
      'conversation': _convertConversation(conversation),
      "isSilent": isSilent
    });
  }

  ///????????????
  @override
  Future<void> setConversationDraft(
      Conversation conversation, String draft) async {
    Map<String, dynamic> args = new Map();
    args['conversation'] = _convertConversation(conversation);
    args['draft'] = draft;
    await methodChannel.invokeMethod("setConversationDraft", args);
  }

  ///?????????????????????
  @override
  Future<void> setConversationTimestamp(
      Conversation conversation, int timestamp) async {
    Map<String, dynamic> args = new Map();
    args['conversation'] = _convertConversation(conversation);
    args['timestamp'] = timestamp;
    await methodChannel.invokeMethod("setConversationTimestamp", args);
  }

  ///????????????????????????????????????ID
  @override
  Future<int> getFirstUnreadMessageId(Conversation conversation) async {
    int msgId = await methodChannel.invokeMethod("getFirstUnreadMessageId",
        {"conversation": _convertConversation(conversation)});
    return msgId;
  }

  ///????????????????????????
  @override
  Future<UnreadCount> getConversationUnreadCount(
      Conversation conversation) async {
    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod(
        'getConversationUnreadCount',
        {'conversation': _convertConversation(conversation)});
    return _convertProtoUnreadCount(datas);
  }

  ///????????????????????????????????????
  @override
  Future<UnreadCount> getConversationsUnreadCount(
      List<ConversationType> types, List<int> lines) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod(
        'getConversationsUnreadCount', {'types': itypes, 'lines': lines});
    return _convertProtoUnreadCount(datas);
  }

  ///?????????????????????????????????
  @override
  Future<bool> clearConversationUnreadStatus(
      Conversation conversation) async {
    bool ret = await methodChannel.invokeMethod('clearConversationUnreadStatus',
        {'conversation': _convertConversation(conversation)});
    if (ret) {
      _eventBus.fire(ClearConversationUnreadEvent(conversation));
    }
    return ret;
  }

  ///???????????????????????????????????????
  @override
  Future<bool> clearConversationsUnreadStatus(
      List<ConversationType> types, List<int> lines) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    bool ret = await methodChannel.invokeMethod(
        'clearConversationsUnreadStatus', {'types': itypes, 'lines': lines});
    if (ret) {
      _eventBus.fire(ClearConversationsUnreadEvent(types, lines));
    }
    return ret;
  }

  @override
  Future<bool> clearMessageUnreadStatus(int messageId) async {
    return await methodChannel.invokeMethod('clearMessageUnreadStatus', {"messageId":messageId});
  }

  @override
  Future<bool> markAsUnRead(Conversation conversation, bool sync) async {
    return await methodChannel.invokeMethod('markAsUnRead', {'conversation': _convertConversation(conversation), "sync":sync});
  }
  
  ///???????????????????????????
  @override
  Future<Map<String, int>> getConversationRead(
      Conversation conversation) async {
    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod(
        'getConversationRead',
        {'conversation': _convertConversation(conversation)});
    Map<String, int> map = new Map();
    datas.forEach((key, value) {
      map.putIfAbsent(key, () => value);
    });
    return map;
  }

  ///?????????????????????????????????
  @override
  Future<Map<String, int>> getMessageDelivery(
      Conversation conversation) async {
    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod(
        'getMessageDelivery',
        {'conversation': _convertConversation(conversation)});
    Map<String, int> map = new Map();
    datas.forEach((key, value) {
      map.putIfAbsent(key, () => value);
    });
    return map;
  }

  ///???????????????????????????
  @override
  Future<List<Message>> getMessages(
      Conversation conversation, int fromIndex, int count,
      {List<int> contentTypes, String withUser}) async {
    Map<String, dynamic> args = {
      "conversation": _convertConversation(conversation),
      "fromIndex": fromIndex,
      "count": count
    };
    if (contentTypes != null) {
      args["contentTypes"] = contentTypes;
    }
    if (withUser != null) {
      args["withUser"] = withUser;
    }

    List<dynamic> datas = await methodChannel.invokeMethod("getMessages", args);
    return _convertProtoMessages(datas);
  }

  ///?????????????????????????????????????????????
  @override
  Future<List<Message>> getMessagesByStatus(Conversation conversation,
      int fromIndex, int count, List<MessageStatus> messageStatus,
      {String withUser}) async {
    Map<String, dynamic> args = {
      "conversation": _convertConversation(conversation),
      "fromIndex": fromIndex,
      "count": count,
      "messageStatus": _convertMessageStatusList(messageStatus)
    };

    if (withUser != null) {
      args["withUser"] = withUser;
    }

    List<dynamic> datas =
    await methodChannel.invokeMethod("getMessagesByStatus", args);
    return _convertProtoMessages(datas);
  }

  ///???????????????????????????????????????
  @override
  Future<List<Message>> getConversationsMessages(
      List<ConversationType> types, List<int> lines, int fromIndex, int count,
      {List<int> contentTypes, String withUser}) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    Map<String, dynamic> args = {
      "types": itypes,
      "lines": lines,
      "fromIndex": fromIndex,
      "count": count
    };
    if (contentTypes != null) {
      args["contentTypes"] = contentTypes;
    }
    if (withUser != null) {
      args["withUser"] = withUser;
    }

    List<dynamic> datas =
    await methodChannel.invokeMethod("getConversationsMessages", args);
    return _convertProtoMessages(datas);
  }

  ///?????????????????????????????????????????????????????????
  @override
  Future<List<Message>> getConversationsMessageByStatus(
      List<ConversationType> types,
      List<int> lines,
      int fromIndex,
      int count,
      List<MessageStatus> messageStatus,
      {String withUser}) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    Map<String, dynamic> args = {
      "types": itypes,
      "lines": lines,
      "fromIndex": fromIndex,
      "count": count,
      "messageStatus": _convertMessageStatusList(messageStatus)
    };

    if (withUser != null) {
      args["withUser"] = withUser;
    }

    List<dynamic> datas =
    await methodChannel.invokeMethod("getConversationsMessageByStatus", args);
    return _convertProtoMessages(datas);
  }

  ///????????????????????????
  @override
  Future<void> getRemoteMessages(
      Conversation conversation,
      int beforeMessageUid,
      int count,
      OperationSuccessMessagesCallback successCallback,
      OperationFailureCallback errorCallback, {List<int> contentTypes}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    Map<String, dynamic> args = {
      "requestId": requestId,
      "conversation": _convertConversation(conversation),
      "beforeMessageUid": beforeMessageUid,
      "count": count
    };

    if(contentTypes != null && contentTypes.isNotEmpty) {
      args["contentTypes"] = contentTypes;
    }

    await methodChannel.invokeMethod("getRemoteMessages", args);
  }

  @override
  Future<void> getRemoteMessage(
      int messageUid,
      OperationSuccessMessageCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    await methodChannel.invokeMethod("getRemoteMessage", {"messageUid":messageUid});
  }

  ///????????????Id????????????
  @override
  Future<Message> getMessage(int messageId) async {
    Map<dynamic, dynamic> datas = await methodChannel
        .invokeMethod("getMessage", {"messageId": messageId});
    return _convertProtoMessage(datas);
  }

  ///????????????Uid????????????
  @override
  Future<Message> getMessageByUid(int messageUid) async {
    Map<dynamic, dynamic> datas = await methodChannel
        .invokeMethod("getMessageByUid", {"messageUid": messageUid});
    return _convertProtoMessage(datas);
  }

  ///???????????????????????????
  @override
  Future<List<Message>> searchMessages(Conversation conversation,
      String keyword, bool order, int limit, int offset) async {
    List<dynamic> datas = await methodChannel.invokeMethod("searchMessages", {
      "conversation": _convertConversation(conversation),
      "keyword": keyword,
      "order": order,
      "limit": limit,
      "offset": offset
    });
    return _convertProtoMessages(datas);
  }

  ///??????????????????????????????
  @override
  Future<List<Message>> searchConversationsMessages(
      List<ConversationType> types,
      List<int> lines,
      String keyword,
      int fromIndex,
      int count, {
        List<int> contentTypes,
      }) async {
    List<int> itypes = new List();
    types.forEach((element) {
      itypes.add(element.index);
    });
    if (lines == null || lines.isEmpty) {
      lines = [0];
    }

    var args = {
      "types": itypes,
      "lines": lines,
      "keyword": keyword,
      "fromIndex": fromIndex,
      "count": count
    };
    if (contentTypes != null) {
      args['contentTypes'] = contentTypes;
    }

    List<dynamic> datas =
    await methodChannel.invokeMethod("searchConversationsMessages", args);
    return _convertProtoMessages(datas);
  }

  ///????????????
  Future<Message> sendMessage(
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
  @override
  Future<Message> sendMediaMessage(
      Conversation conversation, MessageContent content,
      {List<String> toUsers,
        int expireDuration,
        SendMessageSuccessCallback successCallback,
        OperationFailureCallback errorCallback,
        SendMediaMessageProgressCallback progressCallback,
        SendMediaMessageUploadedCallback uploadedCallback}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _sendMessageSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    if (progressCallback != null)
      _sendMediaMessageProgressCallbackMap[requestId] = progressCallback;
    if (uploadedCallback != null)
      _sendMediaMessageUploadedCallbackMap[requestId] = uploadedCallback;

    Map<String, dynamic> convMap = _convertConversation(conversation);
    Map<String, dynamic> contMap = await _convertMessageContent(content);
    Map<String, dynamic> args = {
      "requestId": requestId,
      "conversation": convMap,
      "content": contMap
    };

    if (expireDuration > 0) args['expireDuration'] = expireDuration;
    if (toUsers != null && toUsers.isNotEmpty) args['toUsers'] = toUsers;

    Map<dynamic, dynamic> fm = await methodChannel.invokeMethod('sendMessage', args);

    return _convertProtoMessage(fm);
  }

  ///?????????????????????
  @override
  Future<bool> sendSavedMessage(int messageId,
      {int expireDuration,
        SendMessageSuccessCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _sendMessageSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    return await methodChannel.invokeMethod("sendSavedMessage", {
      "requestId": requestId,
      "messageId": messageId,
      "expireDuration": expireDuration
    });
  }

  @override
  Future<bool> cancelSendingMessage(int messageId) async {
    return await methodChannel.invokeMethod("cancelSendingMessage", {"messageId": messageId});
  }

  ///????????????
  @override
  Future<void> recallMessage(
      int messageUid,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod('recallMessage',
        {"requestId": requestId, "messageUid": messageUid});
  }

  ///??????????????????
  @override
  Future<void> uploadMedia(
      String fileName,
      Uint8List mediaData,
      int mediaType,
      OperationSuccessStringCallback successCallback,
      SendMediaMessageProgressCallback progressCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    if (progressCallback != null)
      _sendMediaMessageProgressCallbackMap[requestId] = progressCallback;
    await methodChannel.invokeMethod("uploadMedia", {
      "requestId": requestId,
      "fileName": fileName,
      "mediaData": mediaData,
      "mediaType": mediaType
    });
  }

  @override
  Future<void> getMediaUploadUrl(
      String fileName,
      int mediaType,
      String contentType,
      GetUploadUrlSuccessCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    await methodChannel.invokeMethod("getUploadUrl", {
      "requestId": requestId,
      "fileName": fileName,
      "contentType": contentType,
      "mediaType": mediaType
    });
  }

  @override
  Future<bool> isSupportBigFilesUpload() async {
    return await methodChannel.invokeMethod("isSupportBigFilesUpload");
  }

  ///????????????
  @override
  Future<bool> deleteMessage(int messageId) async {
    return await methodChannel
        .invokeMethod("deleteMessage", {"messageId": messageId});
  }

  @override
  Future<bool> batchDeleteMessages(List<int> messageUids) async {
    return await methodChannel.invokeMethod("batchDeleteMessages", {"messageUids":messageUids});
  }

  @override
  Future<void> deleteRemoteMessage(
      int messageUid,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod('deleteRemoteMessage',
        {"requestId": requestId, "messageUid": messageUid});
  }

  ///?????????????????????
  @override
  Future<bool> clearMessages(Conversation conversation,
      {int before = 0}) async {
    return await methodChannel.invokeMethod("clearMessages", {
      "conversation": _convertConversation(conversation),
      "before": before
    });
  }

  @override
  Future<bool> clearRemoteConversationMessage(Conversation conversation,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    return await methodChannel.invokeMethod("clearMessages", {
      "requestId": requestId,
      "conversation": _convertConversation(conversation)
    });
  }

  ///????????????????????????
  @override
  Future<void> setMediaMessagePlayed(int messageId) async {
    await methodChannel.invokeMethod(
        "setMediaMessagePlayed", {"messageId": messageId});
  }

  @override
  Future<bool> setMessageLocalExtra(int messageId, String localExtra) async {
    return await methodChannel.invokeMethod(
        "setMessageLocalExtra", {"messageId": messageId, "localExtra":localExtra});
  }

  ///????????????
  @override
  Future<Message> insertMessage(Conversation conversation, String sender,
      MessageContent content, int status, int serverTime) async {
    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod("insertMessage", {
      "conversation": _convertConversation(conversation),
      "content": await _convertMessageContent(content),
      "status": status,
      "serverTime": serverTime
    });
    return _convertProtoMessage(datas);
  }

  ///??????????????????
  @override
  Future<void> updateMessage(
      int messageId, MessageContent content) async {
    await methodChannel.invokeMethod("updateMessage", {
      "messageId": messageId,
      "content": await _convertMessageContent(content)
    });
  }

  @override
  Future<void> updateRemoteMessageContent(
      int messageUid, MessageContent content, bool distribute, bool updateLocal,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    await methodChannel.invokeMethod("updateRemoteMessageContent", {
      "requestId": requestId,
      "messageUid": messageUid,
      "content": await _convertMessageContent(content),
      "distribute": distribute,
      "updateLocal":updateLocal
    });
  }

  ///??????????????????
  @override
  Future<void> updateMessageStatus(
      int messageId, MessageStatus status) async {
    await methodChannel.invokeMethod("updateMessageStatus",
        {"messageId": messageId, "status": status.index});
  }

  ///???????????????????????????
  @override
  Future<int> getMessageCount(Conversation conversation) async {
    return await methodChannel.invokeMethod("getMessageCount",
        {'conversation': _convertConversation(conversation)});
  }

  ///??????????????????
  @override
  Future<UserInfo> getUserInfo(String userId,
      {String groupId, bool refresh = false}) async {
    var args = {"userId": userId, "refresh": refresh};
    if (groupId != null) {
      args['groupId'] = groupId;
    }

    Map<dynamic, dynamic> datas =
    await methodChannel.invokeMethod("getUserInfo", args);
    return _convertProtoUserInfo(datas);
  }

  ///????????????????????????
  @override
  Future<List<UserInfo>> getUserInfos(List<String> userIds,
      {String groupId}) async {
    var args;
    if (groupId != null) {
      args = {"userIds": userIds, "groupId": groupId};
    } else {
      args = {"userIds": userIds};
    }
    List<dynamic> datas = await methodChannel.invokeMethod("getUserInfos", args);
    return _convertProtoUserInfos(datas);
  }

  ///????????????
  @override
  Future<void> searchUser(
      String keyword,
      int searchType,
      int page,
      OperationSuccessUserInfosCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    List<dynamic> datas = await methodChannel.invokeMethod("searchUser", {
      "requestId": requestId,
      "keyword": keyword,
      "searchType": searchType,
      "page": page
    });
    return _convertProtoUserInfos(datas);
  }

  ///????????????????????????
  @override
  Future<void> getUserInfoAsync(
      String userId,
      OperationSuccessUserInfoCallback successCallback,
      OperationFailureCallback errorCallback,
      {bool refresh = false}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "getUserInfoAsync", {"requestId": requestId, "userId": userId});
  }

  ///???????????????
  @override
  Future<bool> isMyFriend(String userId) async {
    return await methodChannel.invokeMethod("isMyFriend", {"userId": userId});
  }

  ///??????????????????
  @override
  Future<List<String>> getMyFriendList({bool refresh = false}) async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("getMyFriendList", {"refresh": refresh});
    return Tools.convertDynamicList(datas);
  }

  ///????????????
  @override
  Future<List<UserInfo>> searchFriends(String keyword) async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("searchFriends", {"keyword": keyword});
    return _convertProtoUserInfos(datas);
  }

  @override
  Future<List<Friend>> getFriends(bool refresh) async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("getFriends", {"refresh": refresh});
    return _convertProtoFriends(datas);
  }

  ///????????????
  @override
  Future<List<GroupSearchInfo>> searchGroups(String keyword) async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("searchGroups", {"keyword": keyword});
    return _convertProtoGroupSearchInfos(datas);
  }

  ///?????????????????????????????????
  @override
  Future<List<FriendRequest>> getIncommingFriendRequest() async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("getIncommingFriendRequest");
    return _convertProtoFriendRequests(datas);
  }

  ///????????????????????????????????????
  @override
  Future<List<FriendRequest>> getOutgoingFriendRequest() async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("getOutgoingFriendRequest");
    return _convertProtoFriendRequests(datas);
  }

  ///???????????????????????????????????????
  @override
  Future<FriendRequest> getFriendRequest(
      String userId, FriendRequestDirection direction) async {
    Map<dynamic, dynamic> data = await methodChannel.invokeMethod(
        "getFriendRequest", {"userId": userId, "direction": direction.index});
    return _convertProtoFriendRequest(data);
  }

  ///??????????????????????????????
  @override
  Future<void> loadFriendRequestFromRemote() async {
    await methodChannel.invokeMethod("loadFriendRequestFromRemote");
  }

  ///???????????????????????????
  @override
  Future<int> getUnreadFriendRequestStatus() async {
    return await methodChannel.invokeMethod("getUnreadFriendRequestStatus");
  }

  ///??????????????????????????????
  @override
  Future<bool> clearUnreadFriendRequestStatus() async {
    bool ret = await methodChannel.invokeMethod("clearUnreadFriendRequestStatus");
    if (ret) {
      _eventBus.fire(ClearFriendRequestUnreadEvent());
    }
    return ret;
  }

  ///????????????
  @override
  Future<void> deleteFriend(
      String userId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "deleteFriend", {"requestId": requestId, "userId": userId});
  }

  ///??????????????????
  @override
  Future<void> sendFriendRequest(
      String userId,
      String reason,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("sendFriendRequest",
        {"requestId": requestId, "userId": userId, "reason": reason});
  }

  ///??????????????????
  @override
  Future<void> handleFriendRequest(
      String userId,
      bool accept,
      String extra,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("handleFriendRequest", {
      "requestId": requestId,
      "userId": userId,
      "accept": accept,
      "extra": extra
    });
  }

  ///?????????????????????
  @override
  Future<String> getFriendAlias(String userId) async {
    String data =
    await methodChannel.invokeMethod("getFriendAlias", {"userId": userId});
    return data;
  }

  ///?????????????????????
  @override
  Future<void> setFriendAlias(
      String friendId,
      String alias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setFriendAlias",
        {"requestId": requestId, "friendId": friendId, "alias": alias});
  }

  ///????????????extra??????
  @override
  Future<String> getFriendExtra(String userId) async {
    String data =
    await methodChannel.invokeMethod("getFriendExtra", {"userId": userId});
    return data;
  }

  ///????????????????????????
  @override
  Future<bool> isBlackListed(String userId) async {
    bool data =
    await methodChannel.invokeMethod("isBlackListed", {"userId": userId});
    return data;
  }

  ///?????????????????????
  @override
  Future<List<String>> getBlackList({bool refresh = false}) async {
    List<dynamic> datas =
    await methodChannel.invokeMethod("getBlackList", {"refresh": refresh});
    return Tools.convertDynamicList(datas);
  }

  ///??????/?????????????????????
  @override
  Future<void> setBlackList(
      String userId,
      bool isBlackListed,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setBlackList", {
      "requestId": requestId,
      "userId": userId,
      "isBlackListed": isBlackListed
    });
  }

  ///?????????????????????
  @override
  Future<List<GroupMember>> getGroupMembers(String groupId,
      {bool refresh = false}) async {
    List<dynamic> datas = await methodChannel.invokeMethod(
        "getGroupMembers", {"groupId": groupId, "refresh": refresh});
    return _convertProtoGroupMembers(datas);
  }

  ///??????????????????????????????????????????
  @override
  Future<List<GroupMember>> getGroupMembersByTypes(
      String groupId, GroupMemberType memberType) async {
    List<dynamic> datas = await methodChannel.invokeMethod("getGroupMembersByTypes",
        {"groupId": groupId, "memberType": memberType.index});
    return _convertProtoGroupMembers(datas);
  }

  ///???????????????????????????
  @override
  Future<void> getGroupMembersAsync(String groupId,
      {bool refresh = false,
        OperationSuccessGroupMembersCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getGroupMembersAsync",
        {"requestId": requestId, "groupId": groupId, "refresh": refresh});
  }

  ///???????????????
  @override
  Future<GroupInfo> getGroupInfo(String groupId,
      {bool refresh = false}) async {
    Map<dynamic, dynamic> datas = await methodChannel
        .invokeMethod("getGroupInfo", {"groupId": groupId, "refresh": refresh});
    return _convertProtoGroupInfo(datas);
  }

  ///?????????????????????
  @override
  Future<void> getGroupInfoAsync(String groupId,
      {bool refresh = false,
        OperationSuccessGroupInfoCallback successCallback,
        OperationFailureCallback errorCallback}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getGroupInfoAsync",
        {"requestId": requestId, "groupId": groupId, "refresh": refresh});
  }

  ///???????????????????????????
  @override
  Future<GroupMember> getGroupMember(
      String groupId, String memberId) async {
    Map<dynamic, dynamic> datas = await methodChannel.invokeMethod(
        "getGroupMember", {"groupId": groupId, "memberId": memberId});
    return _convertProtoGroupMember(datas);
  }

  ///???????????????groupId???????????????
  @override
  Future<void> createGroup(
      String groupId,
      String groupName,
      String groupPortrait,
      int type,
      List<String> members,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    Map<String, dynamic> args = new Map();
    args['requestId'] = requestId;
    if (groupId != null) {
      args['groupId'] = groupId;
    }
    if (groupName != null) {
      args['groupName'] = groupName;
    }
    if (groupPortrait != null) {
      args['groupPortrait'] = groupPortrait;
    }
    args['type'] = type;
    args['groupMembers'] = members;
    if (notifyLines != null) {
      args['notifyLines'] = notifyLines;
    }
    if (notifyContent != null) {
      args['notifyContent'] = await _convertMessageContent(notifyContent);
    }

    await methodChannel.invokeMethod("createGroup", args);
  }

  ///???????????????
  @override
  Future<void> addGroupMembers(
      String groupId,
      List<String> members,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("addGroupMembers", {
      "requestId": requestId,
      "groupId": groupId,
      "groupMembers": members,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///???????????????
  @override
  Future<void> kickoffGroupMembers(
      String groupId,
      List<String> members,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("kickoffGroupMembers", {
      "requestId": requestId,
      "groupId": groupId,
      "groupMembers": members,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///????????????
  @override
  Future<void> quitGroup(
      String groupId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("quitGroup", {
      "requestId": requestId,
      "groupId": groupId,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///????????????
  @override
  Future<void> dismissGroup(
      String groupId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("dismissGroup", {
      "requestId": requestId,
      "groupId": groupId,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///??????????????????
  @override
  Future<void> modifyGroupInfo(
      String groupId,
      ModifyGroupInfoType modifyType,
      String newValue,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("modifyGroupInfo", {
      "requestId": requestId,
      "groupId": groupId,
      "modifyType": modifyType.index,
      "value": newValue,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///????????????????????????
  @override
  Future<void> modifyGroupAlias(
      String groupId,
      String newAlias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("modifyGroupAlias", {
      "requestId": requestId,
      "groupId": groupId,
      "newAlias": newAlias,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///???????????????????????????
  @override
  Future<void> modifyGroupMemberAlias(
      String groupId,
      String memberId,
      String newAlias,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("modifyGroupMemberAlias", {
      "requestId": requestId,
      "groupId": groupId,
      "newAlias": newAlias,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///????????????
  @override
  Future<void> transferGroup(
      String groupId,
      String newOwner,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("transferGroup", {
      "requestId": requestId,
      "groupId": groupId,
      "newOwner": newOwner,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///??????/??????????????????
  @override
  Future<void> setGroupManager(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setGroupManager", {
      "requestId": requestId,
      "groupId": groupId,
      "isSet": isSet,
      "memberIds": memberIds,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///??????/?????????????????????
  @override
  Future<void> muteGroupMember(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("muteGroupMember", {
      "requestId": requestId,
      "groupId": groupId,
      "isSet": isSet,
      "memberIds": memberIds,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  ///??????/??????????????????
  @override
  Future<void> allowGroupMember(
      String groupId,
      bool isSet,
      List<String> memberIds,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback,
      {List<int> notifyLines = const [],
        MessageContent notifyContent}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("allowGroupMember", {
      "requestId": requestId,
      "groupId": groupId,
      "isSet": isSet,
      "memberIds": memberIds,
      "notifyLines": notifyLines,
      "notifyContent": await _convertMessageContent(notifyContent)
    });
  }

  @override
  Future<String> getGroupRemark(String groupId) async {
    return await methodChannel.invokeMethod("getGroupRemark", {"groupId":groupId});
  }

  @override
  Future<void> setGroupRemark(String groupId, String remark,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setGroupRemark", {
      "requestId": requestId,
      "groupId": groupId,
      "remark": remark
    });
  }

  ///????????????????????????
  @override
  Future<List<String>> getFavGroups() async {
    return Tools.convertDynamicList(await methodChannel.invokeMethod("getFavGroups"));
  }

  ///??????????????????
  @override
  Future<bool> isFavGroup(String groupId) async {
    return await methodChannel.invokeMethod("isFavGroup", {"groupId": groupId});
  }

  ///??????/??????????????????
  @override
  Future<void> setFavGroup(
      String groupId,
      bool isFav,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setFavGroup",
        {"requestId": requestId, "groupId": groupId, "isFav": isFav});
  }

  ///??????????????????
  @override
  Future<String> getUserSetting(int scope, String value) async {
    return await methodChannel
        .invokeMethod("getUserSetting", {"scope": scope, "value": value});
  }

  ///????????????????????????
  @override
  Future<Map<String, String>> getUserSettings(int scope) async {
    return await methodChannel.invokeMethod("getUserSettings", {"scope": scope});
  }

  ///??????????????????
  @override
  Future<void> setUserSetting(
      int scope,
      String key,
      String value,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setUserSetting",
        {"requestId": requestId, "scope": scope, "key": key, "value": value});
  }

  ///????????????????????????
  @override
  Future<void> modifyMyInfo(
      Map<ModifyMyInfoType, String> values,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;

    Map<int, String> v = new Map();
    values.forEach((key, value) {
      v.putIfAbsent(key.index, () => value);
    });

    await methodChannel
        .invokeMethod("modifyMyInfo", {"requestId": requestId, "values": v});
  }

  ///??????????????????
  @override
  Future<bool> isGlobalSilent() async {
    return await methodChannel.invokeMethod("isGlobalSilent");
  }

  ///??????/??????????????????
  @override
  Future<void> setGlobalSilent(
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "setGlobalSilent", {"requestId": requestId, "isSilent": isSilent});
  }

  @override
  Future<bool> isVoipNotificationSilent() async {
    return await methodChannel.invokeMethod("isVoipNotificationSilent");
  }

  Future<void> setVoipNotificationSilent(
      bool isSilent,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "setVoipNotificationSilent", {"requestId": requestId, "isSilent": isSilent});
  }

  @override
  Future<bool> isEnableSyncDraft() async {
    return await methodChannel.invokeMethod("isEnableSyncDraft");
  }

  @override
  Future<void> setEnableSyncDraft(
      bool enable,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "setEnableSyncDraft", {"requestId": requestId, "enable": enable});
  }

  ///????????????????????????
  @override
  Future<void> getNoDisturbingTimes(
      OperationSuccessIntPairCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel
        .invokeMethod("getNoDisturbingTimes", {"requestId": requestId});
  }

  ///????????????????????????
  @override
  Future<void> setNoDisturbingTimes(
      int startMins,
      int endMins,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setNoDisturbingTimes",
        {"requestId": requestId, "startMins": startMins, "endMins": endMins});
  }

  ///????????????????????????
  @override
  Future<void> clearNoDisturbingTimes(
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel
        .invokeMethod("clearNoDisturbingTimes", {"requestId": requestId});
  }

  @override
  Future<bool> isNoDisturbing() async {
    return await methodChannel.invokeMethod("isNoDisturbing");
  }

  ///????????????????????????
  @override
  Future<bool> isHiddenNotificationDetail() async {
    return await methodChannel.invokeMethod("isHiddenNotificationDetail");
  }

  ///????????????????????????
  @override
  Future<void> setHiddenNotificationDetail(
      bool isHidden,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setHiddenNotificationDetail",
        {"requestId": requestId, "isHidden": isHidden});
  }

  ///???????????????????????????
  @override
  Future<bool> isHiddenGroupMemberName(String groupId) async {
    return await methodChannel
        .invokeMethod("isHiddenGroupMemberName", {"groupId": groupId});
  }

  ///?????????????????????????????????
  @override
  Future<void> setHiddenGroupMemberName(
      bool isHidden,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setHiddenGroupMemberName",
        {"requestId": requestId, "isHidden": isHidden});
  }


  @override
  Future<void> getMyGroups(
      OperationSuccessStringListCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getMyGroups",
        {"requestId": requestId});
  }

  @override
  Future<void> getCommonGroups(String userId,
      OperationSuccessStringListCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getCommonGroups",
        {"requestId": requestId, "userId": userId});
  }

  ///????????????????????????????????????
  @override
  Future<bool> isUserEnableReceipt() async {
    return await methodChannel.invokeMethod("isUserEnableReceipt");
  }

  ///?????????????????????????????????????????????????????????????????????????????????
  @override
  Future<void> setUserEnableReceipt(
      bool isEnable,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "setUserEnableReceipt", {"requestId": requestId, "isEnable": isEnable});
  }

  ///????????????????????????
  @override
  Future<List<String>> getFavUsers() async {
    return Tools.convertDynamicList(await methodChannel.invokeMethod("getFavUsers"));
  }

  ///?????????????????????
  @override
  Future<bool> isFavUser(String userId) async {
    return await methodChannel.invokeMethod("isFavUser", {"userId": userId});
  }

  ///??????????????????
  @override
  Future<void> setFavUser(
      String userId,
      bool isFav,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("setFavUser",
        {"requestId": requestId, "userId": userId, "isFav": isFav});
  }

  ///???????????????
  @override
  Future<void> joinChatroom(
      String chatroomId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "joinChatroom", {"requestId": requestId, "chatroomId": chatroomId});
  }

  ///???????????????
  @override
  Future<void> quitChatroom(
      String chatroomId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "quitChatroom", {"requestId": requestId, "chatroomId": chatroomId});
  }

  ///?????????????????????
  @override
  Future<void> getChatroomInfo(
      String chatroomId,
      int updateDt,
      OperationSuccessChatroomInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getChatroomInfo", {
      "requestId": requestId,
      "chatroomId": chatroomId,
      "updateDt": updateDt
    });
  }

  ///???????????????????????????
  @override
  Future<void> getChatroomMemberInfo(
      String chatroomId,
      OperationSuccessChatroomMemberInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getChatroomMemberInfo",
        {"requestId": requestId, "chatroomId": chatroomId});
  }

  ///????????????
  @override
  Future<void> createChannel(
      String channelName,
      String channelPortrait,
      int status,
      String desc,
      String extra,
      OperationSuccessChannelInfoCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("createChannel", {
      "requestId": requestId,
      "name": channelName,
      "portrait": channelPortrait,
      "status": status,
      "desc": desc,
      "extra": extra
    });
  }

  ///??????????????????
  @override
  Future<ChannelInfo> getChannelInfo(String channelId,
      {bool refresh = false}) async {
    Map<dynamic, dynamic> data = await methodChannel.invokeMethod(
        "getChannelInfo", {"channelId": channelId, "refresh": refresh});
    return _convertProtoChannelInfo(data);
  }

  ///??????????????????
  @override
  Future<void> modifyChannelInfo(
      String channelId,
      ModifyChannelInfoType modifyType,
      String newValue,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("modifyChannelInfo", {
      "requestId": requestId,
      "channelId": channelId,
      "modifyType": modifyType.index,
      "newValue": newValue
    });
  }

  ///????????????
  @override
  Future<void> searchChannel(
      String keyword,
      OperationSuccessChannelInfosCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "searchChannel", {"requestId": requestId, "keyword": keyword});
  }

  ///????????????????????????
  @override
  Future<bool> isListenedChannel(String channelId) async {
    return await methodChannel
        .invokeMethod("isListenedChannel", {"channelId": channelId});
  }

  ///??????/??????????????????
  @override
  Future<void> listenChannel(
      String channelId,
      bool isListen,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("listenChannel",
        {"requestId": requestId, "channelId": channelId, "isListen": isListen});
  }

  ///??????????????????
  @override
  Future<List<String>> getMyChannels() async {
    return Tools.convertDynamicList(await methodChannel.invokeMethod("getMyChannels"));
  }

  ///????????????????????????
  @override
  Future<List<String>> getListenedChannels() async {
    return Tools.convertDynamicList(
        await methodChannel.invokeMethod("getListenedChannels"));
  }

  ///????????????
  @override
  Future<void> destroyChannel(
      String channelId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "destoryChannel", {"requestId": requestId, "channelId": channelId});
  }

  ///??????PC???????????????
  @override
  Future<List<OnlineInfo>> getOnlineInfos() async {
    List<dynamic> datas = await methodChannel.invokeMethod("getOnlineInfos");
    return _convertProtoOnlineInfos(datas);
  }

  ///??????PC?????????
  @override
  Future<void> kickoffPCClient(
      String clientId,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod(
        "kickoffPCClient", {"requestId": requestId, "clientId": clientId});
  }

  ///???????????????PC???????????????????????????
  @override
  Future<bool> isMuteNotificationWhenPcOnline() async {
    return await methodChannel.invokeMethod("isMuteNotificationWhenPcOnline");
  }

  ///??????/???????????????PC???????????????????????????
  @override
  Future<void> muteNotificationWhenPcOnline(
      bool isMute,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("muteNotificationWhenPcOnline",
        {"requestId": requestId, "isMute": isMute});
  }

  ///????????????????????????
  @override
  Future<void> getConversationFiles(
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback,
      {Conversation conversation,
        String fromUser}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getConversationFiles", {
      "requestId": requestId,
      "conversation": _convertConversation(conversation),
      "fromUser": fromUser,
      "beforeMessageUid": beforeMessageUid,
      "count": count
    });
  }

  ///????????????????????????
  @override
  Future<void> getMyFiles(
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getMyFiles", {
      "requestId": requestId,
      "beforeMessageUid": beforeMessageUid,
      "count": count
    });
  }

  ///??????????????????
  @override
  Future<void> deleteFileRecord(
      int messageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("deleteFileRecord",
        {"requestId": requestId, "messageUid": messageUid});
  }

  ///??????????????????
  @override
  Future<void> searchFiles(
      String keyword,
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback,
      {Conversation conversation,
        String fromUser}) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("searchFiles", {
      "requestId": requestId,
      "keyword": keyword,
      "beforeMessageUid": beforeMessageUid,
      "count": count,
      "conversation": _convertConversation(conversation),
      "fromUser": fromUser
    });
  }

  int addCallback(dynamic successCallback, OperationFailureCallback errorCallback) {
    int requestId = _requestId++;
    if (successCallback != null) {
      _operationSuccessCallbackMap[requestId] = successCallback;
    }
    if (errorCallback != null) {
      _errorCallbackMap[requestId] = errorCallback;
    }
    return requestId;
  }

  ///????????????????????????
  @override
  Future<void> searchMyFiles(
      String keyword,
      int beforeMessageUid,
      int count,
      OperationSuccessFilesCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = addCallback(successCallback, errorCallback);
    await methodChannel.invokeMethod("searchMyFiles", {
      "requestId": requestId,
      "keyword": keyword,
      "beforeMessageUid": beforeMessageUid,
      "count": count
    });
  }

  ///?????????????????????????????????
  @override
  Future<void> getAuthorizedMediaUrl(
      String mediaPath,
      int messageUid,
      int mediaType,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getAuthorizedMediaUrl", {
      "requestId": requestId,
      "mediaPath": mediaPath,
      "messageUid": messageUid,
      "mediaType": mediaType
    });
  }

  @override
  Future<void> getAuthCode(
      String applicationId,
      int type,
      String host,
      OperationSuccessStringCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("getAuthCode", {
      "requestId": requestId,
      "applicationId": applicationId,
      "type": type,
      "host": host
    });
  }

  @override
  Future<void> configApplication(
      String applicationId,
      int type,
      int timestamp,
      String nonce,
      String signature,
      OperationSuccessVoidCallback successCallback,
      OperationFailureCallback errorCallback) async {
    int requestId = _requestId++;
    if (successCallback != null)
      _operationSuccessCallbackMap[requestId] = successCallback;
    if (errorCallback != null) _errorCallbackMap[requestId] = errorCallback;
    await methodChannel.invokeMethod("configApplication", {
      "requestId": requestId,
      "applicationId": applicationId,
      "type": type,
      "timestamp": timestamp,
      "nonce":nonce,
      "signature":signature
    });
  }

  ///??????amr?????????wav???????????????iOS????????????
  @override
  Future<Uint8List> getWavData(String amrPath) async {
    return await methodChannel.invokeMethod("getWavData", {"amrPath": amrPath});
  }

  ///???????????????????????????????????????????????????????????????
  @override
  Future<bool> beginTransaction() async {
    return await methodChannel.invokeMethod("beginTransaction");
  }

  ///???????????????????????????????????????????????????????????????
  @override
  Future<bool> commitTransaction() async {
    return await methodChannel.invokeMethod("commitTransaction");
  }

  @override
  Future<bool> rollbackTransaction() async {
    return await methodChannel.invokeMethod("rollbackTransaction");
  }

  ///??????????????????
  @override
  Future<bool> isCommercialServer() async {
    return await methodChannel.invokeMethod("isCommercialServer");
  }

  ///??????????????????????????????
  @override
  Future<bool> isReceiptEnabled() async {
    return await methodChannel.invokeMethod("isReceiptEnabled");
  }

  @override
  Future<bool> isGlobalDisableSyncDraft() async {
    return await methodChannel.invokeMethod("isGlobalDisableSyncDraft");
  }
}
