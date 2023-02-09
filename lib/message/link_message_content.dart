import 'dart:convert';

import '../model/message_payload.dart';
import 'media_message_content.dart';
import 'message.dart';
import 'message_content.dart';

// ignore: non_constant_identifier_names
MessageContent LinkMessageContentCreator() {
  return new LinkMessageContent();
}

const linkContentMeta = MessageContentMeta(MESSAGE_CONTENT_TYPE_LINK,
    MessageFlag.PERSIST_AND_COUNT, LinkMessageContentCreator);

class LinkMessageContent extends MediaMessageContent {
  String title;
  String contentDigest;
  String url;
  String thumbnailUrl;

  @override
  MessageContentMeta get meta => linkContentMeta;

  @override
  void decode(MessagePayload payload) {
    super.decode(payload);
    title = payload.searchableContent;
    Map<dynamic, dynamic> map = json.decode(utf8.decode(payload.binaryContent));
    contentDigest = map['d'];
    url = map['u'];
    thumbnailUrl = map['t'];
  }

  @override
  Future<MessagePayload> encode() async {
    MessagePayload payload = await super.encode();

    payload.searchableContent = title;
    payload.binaryContent = utf8.encode(json.encode({
      'd': contentDigest,
      'u': url,
      't': thumbnailUrl,
    }));
    return payload;
  }

  @override
  Future<String> digest(Message message) async {
    if (title != null && title.isNotEmpty) {
      return '[链接]:$title';
    }
    return '[链接]';
  }
}
