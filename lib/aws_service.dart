import 'package:aws_polly/aws_polly.dart';
import 'package:flutter/material.dart';
import 'package:kids_qa_bot/config.dart';
import 'package:kids_qa_bot/settings.dart';

class AWSService {
  final AwsPolly _awsPolly = AwsPolly.instance(
    poolId: AWS_POLLY_POOL_ID,
    region: AWSRegionType.USEast1,
  );

  Future<String> getTTSAudio(String text, Language language) async {
    try {
      AWSPolyVoiceId voiceId;
      switch (language) {
        case Language.english:
          voiceId = AWSPolyVoiceId.ivy;
          break;
        case Language.chinese:
          voiceId = AWSPolyVoiceId.zhiyu;
          break;
        default:
          voiceId = AWSPolyVoiceId.nicole;
          break;
      }

      final url = await _awsPolly.getUrl(
        voiceId: voiceId,
        input: text,
      );
      return url;
    } catch (e) {
      return e.toString();
    }
  }
}
