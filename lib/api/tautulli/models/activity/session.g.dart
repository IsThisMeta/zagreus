// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSession _$TautulliSessionFromJson(Map<String, dynamic> json) =>
    TautulliSession(
      sessionKey: TautulliUtilities.ensureIntegerFromJson(json['session_key']),
      mediaType:
          TautulliUtilities.mediaTypeFromJson(json['media_type'] as String?),
      viewOffset: TautulliUtilities.ensureIntegerFromJson(json['view_offset']),
      progressPercent:
          TautulliUtilities.ensureIntegerFromJson(json['progress_percent']),
      qualityProfile:
          TautulliUtilities.ensureStringFromJson(json['quality_profile']),
      syncedVersionProfile: TautulliUtilities.ensureStringFromJson(
          json['synced_version_profile']),
      optimizedVersionProfile: TautulliUtilities.ensureStringFromJson(
          json['optimized_version_profile']),
      user: TautulliUtilities.ensureStringFromJson(json['user']),
      channelStream:
          TautulliUtilities.ensureIntegerFromJson(json['channel_stream']),
      sectionId: TautulliUtilities.ensureIntegerFromJson(json['section_id']),
      libraryName: TautulliUtilities.ensureStringFromJson(json['library_name']),
      ratingKey: TautulliUtilities.ensureIntegerFromJson(json['rating_key']),
      parentRatingKey:
          TautulliUtilities.ensureIntegerFromJson(json['parent_rating_key']),
      grandparentRatingKey: TautulliUtilities.ensureIntegerFromJson(
          json['grandparent_rating_key']),
      title: TautulliUtilities.ensureStringFromJson(json['title']),
      parentTitle: TautulliUtilities.ensureStringFromJson(json['parent_title']),
      grandparentTitle:
          TautulliUtilities.ensureStringFromJson(json['grandparent_title']),
      originalTitle:
          TautulliUtilities.ensureStringFromJson(json['original_title']),
      sortTitle: TautulliUtilities.ensureStringFromJson(json['sort_title']),
      mediaIndex: TautulliUtilities.ensureIntegerFromJson(json['media_index']),
      parentMediaIndex:
          TautulliUtilities.ensureIntegerFromJson(json['parent_media_index']),
      studio: TautulliUtilities.ensureStringFromJson(json['studio']),
      contentRating:
          TautulliUtilities.ensureStringFromJson(json['content_rating']),
      summary: TautulliUtilities.ensureStringFromJson(json['summary']),
      tagline: TautulliUtilities.ensureStringFromJson(json['tagline']),
      rating: TautulliUtilities.ensureDoubleFromJson(json['rating']),
      ratingImage: TautulliUtilities.ensureStringFromJson(json['rating_image']),
      audienceRating:
          TautulliUtilities.ensureDoubleFromJson(json['audience_rating']),
      audienceRatingImage:
          TautulliUtilities.ensureStringFromJson(json['audience_rating_image']),
      userRating: TautulliUtilities.ensureDoubleFromJson(json['user_rating']),
      duration:
          TautulliUtilities.millisecondsDurationFromJson(json['duration']),
      year: TautulliUtilities.ensureIntegerFromJson(json['year']),
      thumb: TautulliUtilities.ensureStringFromJson(json['thumb']),
      parentThumb: TautulliUtilities.ensureStringFromJson(json['parent_thumb']),
      grandparentThumb:
          TautulliUtilities.ensureStringFromJson(json['grandparent_thumb']),
      art: TautulliUtilities.ensureStringFromJson(json['art']),
      banner: TautulliUtilities.ensureStringFromJson(json['banner']),
      originallyAvailableAt: TautulliUtilities.ensureStringFromJson(
          json['originally_available_at']),
      addedAt: TautulliUtilities.millisecondsDateTimeFromJson(json['added_at']),
      updatedAt:
          TautulliUtilities.millisecondsDateTimeFromJson(json['updated_at']),
      lastViewedAt: TautulliUtilities.millisecondsDateTimeFromJson(
          json['last_viewed_at']),
      guid: TautulliUtilities.ensureStringFromJson(json['guid']),
      parentGuid: TautulliUtilities.ensureStringFromJson(json['parent_guid']),
      grandparentGuid:
          TautulliUtilities.ensureStringFromJson(json['grandparent_guid']),
      directors: TautulliUtilities.ensureStringListFromJson(json['directors']),
      actors: TautulliUtilities.ensureStringListFromJson(json['actors']),
      writers: TautulliUtilities.ensureStringListFromJson(json['writers']),
      genres: TautulliUtilities.ensureStringListFromJson(json['genres']),
      labels: TautulliUtilities.ensureStringListFromJson(json['labels']),
      collections:
          TautulliUtilities.ensureStringListFromJson(json['collections']),
      fullTitle: TautulliUtilities.ensureStringFromJson(json['full_title']),
      childrenCount:
          TautulliUtilities.ensureIntegerFromJson(json['children_count']),
      live: TautulliUtilities.ensureBooleanFromJson(json['live']),
      id: TautulliUtilities.ensureIntegerFromJson(json['id']),
      container: TautulliUtilities.ensureStringFromJson(json['container']),
      bitrate: TautulliUtilities.ensureIntegerFromJson(json['bitrate']),
      height: TautulliUtilities.ensureIntegerFromJson(json['height']),
      width: TautulliUtilities.ensureIntegerFromJson(json['width']),
      aspectRatio: TautulliUtilities.ensureDoubleFromJson(json['aspect_ratio']),
      videoCodec: TautulliUtilities.ensureStringFromJson(json['video_codec']),
      videoResolution:
          TautulliUtilities.ensureStringFromJson(json['video_resolution']),
      videoFullResolution:
          TautulliUtilities.ensureStringFromJson(json['video_full_resolution']),
      videoFramerate:
          TautulliUtilities.ensureStringFromJson(json['video_framerate']),
      videoProfile:
          TautulliUtilities.ensureStringFromJson(json['video_profile']),
      audioCodec: TautulliUtilities.ensureStringFromJson(json['audio_codec']),
      audioChannels:
          TautulliUtilities.ensureIntegerFromJson(json['audio_channels']),
      audioChannelLayout:
          TautulliUtilities.ensureStringFromJson(json['audio_channel_layout']),
      audioProfile:
          TautulliUtilities.ensureStringFromJson(json['audio_profile']),
      optimizedVersion:
          TautulliUtilities.ensureBooleanFromJson(json['optimized_version']),
      channelCallSign:
          TautulliUtilities.ensureStringFromJson(json['channel_call_sign']),
      channelIdentifier:
          TautulliUtilities.ensureStringFromJson(json['channel_identifier']),
      channelThumb:
          TautulliUtilities.ensureStringFromJson(json['channel_thumb']),
      file: TautulliUtilities.ensureStringFromJson(json['file']),
      fileSize: TautulliUtilities.ensureIntegerFromJson(json['file_size']),
      indexes: TautulliUtilities.ensureBooleanFromJson(json['indexes']),
      selected: TautulliUtilities.ensureBooleanFromJson(json['selected']),
      type: TautulliUtilities.ensureIntegerFromJson(json['type']),
      videoCodecLevel:
          TautulliUtilities.ensureStringFromJson(json['video_codec_level']),
      videoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['video_bitrate']),
      videoBitDepth:
          TautulliUtilities.ensureIntegerFromJson(json['video_bit_depth']),
      videoChromaSubsampling: TautulliUtilities.ensureStringFromJson(
          json['video_chroma_subsampling']),
      videoColorPrimaries:
          TautulliUtilities.ensureStringFromJson(json['video_color_primaries']),
      videoColorRange:
          TautulliUtilities.ensureStringFromJson(json['video_color_range']),
      videoColorSpace:
          TautulliUtilities.ensureStringFromJson(json['video_color_space']),
      videoColorTRC:
          TautulliUtilities.ensureStringFromJson(json['video_color_trc']),
      videoFrameRate:
          TautulliUtilities.ensureDoubleFromJson(json['video_frame_rate']),
      videoRefFrames:
          TautulliUtilities.ensureIntegerFromJson(json['video_ref_frames']),
      videoHeight:
          TautulliUtilities.ensureIntegerFromJson(json['video_height']),
      videoWidth: TautulliUtilities.ensureIntegerFromJson(json['video_width']),
      videoLanguage:
          TautulliUtilities.ensureStringFromJson(json['video_language']),
      videoLanguageCode:
          TautulliUtilities.ensureStringFromJson(json['video_language_code']),
      videoDynamicRange:
          TautulliUtilities.ensureStringFromJson(json['video_dynamic_range']),
      videoScanType:
          TautulliUtilities.ensureStringFromJson(json['video_scan_type']),
      audioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_bitrate']),
      audioBitrateMode:
          TautulliUtilities.ensureStringFromJson(json['audio_bitrate_mode']),
      audioSampleRate:
          TautulliUtilities.ensureIntegerFromJson(json['audio_sample_rate']),
      audioLanguage:
          TautulliUtilities.ensureStringFromJson(json['audio_language']),
      audioLanguageCode:
          TautulliUtilities.ensureStringFromJson(json['audio_language_code']),
      subtitleCodec:
          TautulliUtilities.ensureStringFromJson(json['subtitle_codec']),
      subtitleContainer:
          TautulliUtilities.ensureStringFromJson(json['subtitle_container']),
      subtitleFormat:
          TautulliUtilities.ensureStringFromJson(json['subtitle_format']),
      subtitleForced:
          TautulliUtilities.ensureBooleanFromJson(json['subtitle_forced']),
      subtitleLanguage:
          TautulliUtilities.ensureStringFromJson(json['subtitle_language']),
      subtitleLanguageCode: TautulliUtilities.ensureStringFromJson(
          json['subtitle_language_code']),
      subtitleLocation:
          TautulliUtilities.ensureStringFromJson(json['subtitle_location']),
      rowId: TautulliUtilities.ensureIntegerFromJson(json['row_id']),
      userId: TautulliUtilities.ensureIntegerFromJson(json['user_id']),
      username: TautulliUtilities.ensureStringFromJson(json['username']),
      friendlyName:
          TautulliUtilities.ensureStringFromJson(json['friendly_name']),
      userThumb: TautulliUtilities.ensureStringFromJson(json['user_thumb']),
      email: TautulliUtilities.ensureStringFromJson(json['email']),
      isActive: TautulliUtilities.ensureBooleanFromJson(json['is_active']),
      isAdmin: TautulliUtilities.ensureBooleanFromJson(json['is_admin']),
      isHomeUser: TautulliUtilities.ensureBooleanFromJson(json['is_home_user']),
      isAllowSync:
          TautulliUtilities.ensureBooleanFromJson(json['is_allow_sync']),
      isRestricted:
          TautulliUtilities.ensureBooleanFromJson(json['is_restricted']),
      doNotify: TautulliUtilities.ensureBooleanFromJson(json['do_notify']),
      keepHistory:
          TautulliUtilities.ensureBooleanFromJson(json['keep_history']),
      deletedUser:
          TautulliUtilities.ensureBooleanFromJson(json['deleted_user']),
      allowGuest: TautulliUtilities.ensureBooleanFromJson(json['allow_guest']),
      sharedLibraries:
          TautulliUtilities.ensureIntegerListFromJson(json['shared_libraries']),
      ipAddress: TautulliUtilities.ensureStringFromJson(json['ip_address']),
      ipAddressPublic:
          TautulliUtilities.ensureStringFromJson(json['ip_address_public']),
      device: TautulliUtilities.ensureStringFromJson(json['device']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      platformName:
          TautulliUtilities.ensureStringFromJson(json['platform_name']),
      platformVersion:
          TautulliUtilities.ensureStringFromJson(json['platform_version']),
      product: TautulliUtilities.ensureStringFromJson(json['product']),
      productVersion:
          TautulliUtilities.ensureStringFromJson(json['product_version']),
      profile: TautulliUtilities.ensureStringFromJson(json['profile']),
      player: TautulliUtilities.ensureStringFromJson(json['player']),
      machineId: TautulliUtilities.ensureStringFromJson(json['machine_id']),
      state: TautulliUtilities.sessionStateFromJson(json['state'] as String?),
      local: TautulliUtilities.ensureBooleanFromJson(json['local']),
      relayed: TautulliUtilities.ensureBooleanFromJson(json['relayed']),
      secure: TautulliUtilities.ensureBooleanFromJson(json['secure']),
      sessionId: TautulliUtilities.ensureStringFromJson(json['session_id']),
      bandwidth: TautulliUtilities.ensureIntegerFromJson(json['bandwidth']),
      location: TautulliUtilities.sessionLocationFromJson(
          json['location'] as String?),
      transcodeKey:
          TautulliUtilities.ensureStringFromJson(json['transcode_key']),
      transcodeThrottled:
          TautulliUtilities.ensureBooleanFromJson(json['transcode_throttled']),
      transcodeProgress:
          TautulliUtilities.ensureIntegerFromJson(json['transcode_progress']),
      transcodeSpeed:
          TautulliUtilities.ensureDoubleFromJson(json['transcode_speed']),
      transcodeAudioChannels: TautulliUtilities.ensureIntegerFromJson(
          json['transcode_audio_channels']),
      transcodeAudioCodec:
          TautulliUtilities.ensureStringFromJson(json['transcode_audio_codec']),
      transcodeVideoCodec:
          TautulliUtilities.ensureStringFromJson(json['transcode_video_codec']),
      transcodeWidth:
          TautulliUtilities.ensureIntegerFromJson(json['transcode_width']),
      transcodeHeight:
          TautulliUtilities.ensureIntegerFromJson(json['transcode_height']),
      transcodeContainer:
          TautulliUtilities.ensureStringFromJson(json['transcode_container']),
      transcodeProtocol:
          TautulliUtilities.ensureStringFromJson(json['transcode_protocol']),
      transcodeHardwareRequested: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_requested']),
      transcodeHardwareDecode:
          TautulliUtilities.ensureStringFromJson(json['transcode_hw_decode']),
      transcodeHardwareDecodeTitle: TautulliUtilities.ensureStringFromJson(
          json['transcode_hw_decode_title']),
      transcodeHardwareEncode:
          TautulliUtilities.ensureStringFromJson(json['transcode_hw_encode']),
      transcodeHardwareEncodeTitle: TautulliUtilities.ensureStringFromJson(
          json['transcode_hw_encode_title']),
      transcodeHardwareFullPipeline: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_full_pipeline']),
      audioDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['audio_decision'] as String?),
      videoDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['video_decision'] as String?),
      subtitleDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['subtitle_decision'] as String?),
      throttled: TautulliUtilities.ensureBooleanFromJson(json['throttled']),
      transcodeHardwareDecoding: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_decoding']),
      transcodeHardwareEncoding: TautulliUtilities.ensureBooleanFromJson(
          json['transcode_hw_encoding']),
      streamContainer:
          TautulliUtilities.ensureStringFromJson(json['stream_container']),
      streamBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_bitrate']),
      streamAspectRatio:
          TautulliUtilities.ensureDoubleFromJson(json['stream_aspect_ratio']),
      streamAudioCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_audio_codec']),
      streamAudioChannels: TautulliUtilities.ensureIntegerFromJson(
          json['stream_audio_channels']),
      streamAudioChannelLayout: TautulliUtilities.ensureStringFromJson(
          json['stream_audio_channel_layout']),
      streamAudioChannelLayout_: TautulliUtilities.ensureStringFromJson(
          json['stream_audio_channel_layout_']),
      streamVideoCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_video_codec']),
      streamVideoFramerate: TautulliUtilities.ensureStringFromJson(
          json['stream_video_framerate']),
      streamVideoResolution: TautulliUtilities.ensureStringFromJson(
          json['stream_video_resolution']),
      streamVideoHeight:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_height']),
      streamVideoWidth:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_width']),
      streamDuration: TautulliUtilities.millisecondsDurationFromJson(
          json['stream_duration']),
      streamContainerDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_container_decision'] as String?),
      optimizedVersionTitle: TautulliUtilities.ensureStringFromJson(
          json['optimized_version_title']),
      syncedVersion:
          TautulliUtilities.ensureBooleanFromJson(json['synced_version']),
      liveUuid: TautulliUtilities.ensureStringFromJson(json['live_uuid']),
      bifThumb: TautulliUtilities.ensureStringFromJson(json['bif_thumb']),
      transcodeDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['transcode_decision'] as String?),
      subtitles: TautulliUtilities.ensureBooleanFromJson(json['subtitles']),
      streamVideoFullResolution: TautulliUtilities.ensureStringFromJson(
          json['stream_video_full_resolution']),
      streamVideoDynamicRange: TautulliUtilities.ensureStringFromJson(
          json['stream_video_dynamic_range']),
      streamVideoBitDepth: TautulliUtilities.ensureIntegerFromJson(
          json['stream_video_bit_depth']),
      streamVideoBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_video_bitrate']),
      streamVideoChromaSubsampling: TautulliUtilities.ensureStringFromJson(
          json['stream_video_chroma_subsampling']),
      streamVideoCodecLevel: TautulliUtilities.ensureStringFromJson(
          json['stream_video_codec_level']),
      streamVideoColorPrimaries: TautulliUtilities.ensureStringFromJson(
          json['stream_video_color_primaries']),
      streamVideoColorRange: TautulliUtilities.ensureStringFromJson(
          json['stream_video_color_range']),
      streamVideoColorSpace: TautulliUtilities.ensureStringFromJson(
          json['stream_video_color_space']),
      streamVideoColorTRC: TautulliUtilities.ensureStringFromJson(
          json['stream_video_color_trc']),
      streamVideoRefFrames: TautulliUtilities.ensureIntegerFromJson(
          json['stream_video_ref_frames']),
      streamVideoDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_video_decision'] as String?),
      streamVideoLanguage:
          TautulliUtilities.ensureStringFromJson(json['stream_video_language']),
      streamVideoLanguageCode: TautulliUtilities.ensureStringFromJson(
          json['stream_video_language_code']),
      streamVideoScanType: TautulliUtilities.ensureStringFromJson(
          json['stream_video_scan_type']),
      streamAudioBitrate:
          TautulliUtilities.ensureIntegerFromJson(json['stream_audio_bitrate']),
      streamAudioBitrateMode: TautulliUtilities.ensureStringFromJson(
          json['stream_audio_bitrate_mode']),
      streamAudioDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_audio_decision'] as String?),
      streamAudioLanguage:
          TautulliUtilities.ensureStringFromJson(json['stream_audio_language']),
      streamAudioLanguageCode: TautulliUtilities.ensureStringFromJson(
          json['stream_audio_language_code']),
      streamAudioSampleRate: TautulliUtilities.ensureIntegerFromJson(
          json['stream_audio_sample_rate']),
      streamSubtitleCodec:
          TautulliUtilities.ensureStringFromJson(json['stream_subtitle_codec']),
      streamSubtitleContainer: TautulliUtilities.ensureStringFromJson(
          json['stream_subtitle_container']),
      streamSubtitleDecision: TautulliUtilities.transcodeDecisionFromJson(
          json['stream_subtitle_decision'] as String?),
      streamSubtitleForced: TautulliUtilities.ensureBooleanFromJson(
          json['stream_subtitle_forced']),
      streamSubtitleFormat: TautulliUtilities.ensureStringFromJson(
          json['stream_subtitle_format']),
      streamSubtitleLanguage: TautulliUtilities.ensureStringFromJson(
          json['stream_subtitle_language']),
      streamSubtitleLanguageCode: TautulliUtilities.ensureStringFromJson(
          json['stream_subtitle_language_code']),
      streamSubtitleLocation: TautulliUtilities.ensureStringFromJson(
          json['stream_subtitle_location']),
      streamSubtitleTransient: TautulliUtilities.ensureBooleanFromJson(
          json['stream_subtitle_transient']),
    );

Map<String, dynamic> _$TautulliSessionToJson(TautulliSession instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'media_type', TautulliUtilities.mediaTypeToJson(instance.mediaType));
  writeNotNull('session_key', instance.sessionKey);
  writeNotNull('view_offset', instance.viewOffset);
  writeNotNull('progress_percent', instance.progressPercent);
  writeNotNull('quality_profile', instance.qualityProfile);
  writeNotNull('synced_version_profile', instance.syncedVersionProfile);
  writeNotNull('optimized_version_profile', instance.optimizedVersionProfile);
  writeNotNull('user', instance.user);
  writeNotNull('channel_stream', instance.channelStream);
  writeNotNull('section_id', instance.sectionId);
  writeNotNull('library_name', instance.libraryName);
  writeNotNull('rating_key', instance.ratingKey);
  writeNotNull('parent_rating_key', instance.parentRatingKey);
  writeNotNull('grandparent_rating_key', instance.grandparentRatingKey);
  writeNotNull('title', instance.title);
  writeNotNull('parent_title', instance.parentTitle);
  writeNotNull('grandparent_title', instance.grandparentTitle);
  writeNotNull('original_title', instance.originalTitle);
  writeNotNull('sort_title', instance.sortTitle);
  writeNotNull('media_index', instance.mediaIndex);
  writeNotNull('parent_media_index', instance.parentMediaIndex);
  writeNotNull('studio', instance.studio);
  writeNotNull('content_rating', instance.contentRating);
  writeNotNull('summary', instance.summary);
  writeNotNull('tagline', instance.tagline);
  writeNotNull('rating', instance.rating);
  writeNotNull('rating_image', instance.ratingImage);
  writeNotNull('audience_rating', instance.audienceRating);
  writeNotNull('audience_rating_image', instance.audienceRatingImage);
  writeNotNull('user_rating', instance.userRating);
  writeNotNull('duration', instance.duration?.inMicroseconds);
  writeNotNull('year', instance.year);
  writeNotNull('thumb', instance.thumb);
  writeNotNull('parent_thumb', instance.parentThumb);
  writeNotNull('grandparent_thumb', instance.grandparentThumb);
  writeNotNull('art', instance.art);
  writeNotNull('banner', instance.banner);
  writeNotNull('originally_available_at', instance.originallyAvailableAt);
  writeNotNull('added_at', instance.addedAt?.toIso8601String());
  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  writeNotNull('last_viewed_at', instance.lastViewedAt?.toIso8601String());
  writeNotNull('guid', instance.guid);
  writeNotNull('parent_guid', instance.parentGuid);
  writeNotNull('grandparent_guid', instance.grandparentGuid);
  writeNotNull('directors', instance.directors);
  writeNotNull('writers', instance.writers);
  writeNotNull('actors', instance.actors);
  writeNotNull('genres', instance.genres);
  writeNotNull('labels', instance.labels);
  writeNotNull('collections', instance.collections);
  writeNotNull('full_title', instance.fullTitle);
  writeNotNull('children_count', instance.childrenCount);
  writeNotNull('live', instance.live);
  writeNotNull('id', instance.id);
  writeNotNull('container', instance.container);
  writeNotNull('bitrate', instance.bitrate);
  writeNotNull('height', instance.height);
  writeNotNull('width', instance.width);
  writeNotNull('aspect_ratio', instance.aspectRatio);
  writeNotNull('video_codec', instance.videoCodec);
  writeNotNull('video_resolution', instance.videoResolution);
  writeNotNull('video_full_resolution', instance.videoFullResolution);
  writeNotNull('video_framerate', instance.videoFramerate);
  writeNotNull('video_profile', instance.videoProfile);
  writeNotNull('audio_codec', instance.audioCodec);
  writeNotNull('audio_channels', instance.audioChannels);
  writeNotNull('audio_channel_layout', instance.audioChannelLayout);
  writeNotNull('audio_profile', instance.audioProfile);
  writeNotNull('optimized_version', instance.optimizedVersion);
  writeNotNull('channel_call_sign', instance.channelCallSign);
  writeNotNull('channel_identifier', instance.channelIdentifier);
  writeNotNull('channel_thumb', instance.channelThumb);
  writeNotNull('file', instance.file);
  writeNotNull('file_size', instance.fileSize);
  writeNotNull('indexes', instance.indexes);
  writeNotNull('selected', instance.selected);
  writeNotNull('type', instance.type);
  writeNotNull('video_codec_level', instance.videoCodecLevel);
  writeNotNull('video_bitrate', instance.videoBitrate);
  writeNotNull('video_bit_depth', instance.videoBitDepth);
  writeNotNull('video_chroma_subsampling', instance.videoChromaSubsampling);
  writeNotNull('video_color_primaries', instance.videoColorPrimaries);
  writeNotNull('video_color_range', instance.videoColorRange);
  writeNotNull('video_color_space', instance.videoColorSpace);
  writeNotNull('video_color_trc', instance.videoColorTRC);
  writeNotNull('video_frame_rate', instance.videoFrameRate);
  writeNotNull('video_ref_frames', instance.videoRefFrames);
  writeNotNull('video_height', instance.videoHeight);
  writeNotNull('video_width', instance.videoWidth);
  writeNotNull('video_language', instance.videoLanguage);
  writeNotNull('video_language_code', instance.videoLanguageCode);
  writeNotNull('video_scan_type', instance.videoScanType);
  writeNotNull('video_dynamic_range', instance.videoDynamicRange);
  writeNotNull('audio_bitrate', instance.audioBitrate);
  writeNotNull('audio_bitrate_mode', instance.audioBitrateMode);
  writeNotNull('audio_sample_rate', instance.audioSampleRate);
  writeNotNull('audio_language', instance.audioLanguage);
  writeNotNull('audio_language_code', instance.audioLanguageCode);
  writeNotNull('subtitle_codec', instance.subtitleCodec);
  writeNotNull('subtitle_container', instance.subtitleContainer);
  writeNotNull('subtitle_format', instance.subtitleFormat);
  writeNotNull('subtitle_forced', instance.subtitleForced);
  writeNotNull('subtitle_location', instance.subtitleLocation);
  writeNotNull('subtitle_language', instance.subtitleLanguage);
  writeNotNull('subtitle_language_code', instance.subtitleLanguageCode);
  writeNotNull('row_id', instance.rowId);
  writeNotNull('user_id', instance.userId);
  writeNotNull('username', instance.username);
  writeNotNull('friendly_name', instance.friendlyName);
  writeNotNull('user_thumb', instance.userThumb);
  writeNotNull('email', instance.email);
  writeNotNull('is_active', instance.isActive);
  writeNotNull('is_admin', instance.isAdmin);
  writeNotNull('is_home_user', instance.isHomeUser);
  writeNotNull('is_allow_sync', instance.isAllowSync);
  writeNotNull('is_restricted', instance.isRestricted);
  writeNotNull('do_notify', instance.doNotify);
  writeNotNull('keep_history', instance.keepHistory);
  writeNotNull('deleted_user', instance.deletedUser);
  writeNotNull('allow_guest', instance.allowGuest);
  writeNotNull('shared_libraries', instance.sharedLibraries);
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('ip_address_public', instance.ipAddressPublic);
  writeNotNull('device', instance.device);
  writeNotNull('platform', instance.platform);
  writeNotNull('platform_name', instance.platformName);
  writeNotNull('platform_version', instance.platformVersion);
  writeNotNull('product', instance.product);
  writeNotNull('product_version', instance.productVersion);
  writeNotNull('profile', instance.profile);
  writeNotNull('player', instance.player);
  writeNotNull('machine_id', instance.machineId);
  writeNotNull('state', TautulliUtilities.sessionStateToJson(instance.state));
  writeNotNull('local', instance.local);
  writeNotNull('relayed', instance.relayed);
  writeNotNull('secure', instance.secure);
  writeNotNull('session_id', instance.sessionId);
  writeNotNull('bandwidth', instance.bandwidth);
  writeNotNull(
      'location', TautulliUtilities.sessionLocationToJson(instance.location));
  writeNotNull('transcode_key', instance.transcodeKey);
  writeNotNull('transcode_throttled', instance.transcodeThrottled);
  writeNotNull('transcode_progress', instance.transcodeProgress);
  writeNotNull('transcode_speed', instance.transcodeSpeed);
  writeNotNull('transcode_audio_channels', instance.transcodeAudioChannels);
  writeNotNull('transcode_audio_codec', instance.transcodeAudioCodec);
  writeNotNull('transcode_video_codec', instance.transcodeVideoCodec);
  writeNotNull('transcode_height', instance.transcodeHeight);
  writeNotNull('transcode_width', instance.transcodeWidth);
  writeNotNull('transcode_container', instance.transcodeContainer);
  writeNotNull('transcode_protocol', instance.transcodeProtocol);
  writeNotNull('transcode_hw_requested', instance.transcodeHardwareRequested);
  writeNotNull('transcode_hw_decode', instance.transcodeHardwareDecode);
  writeNotNull(
      'transcode_hw_decode_title', instance.transcodeHardwareDecodeTitle);
  writeNotNull('transcode_hw_encode', instance.transcodeHardwareEncode);
  writeNotNull(
      'transcode_hw_encode_title', instance.transcodeHardwareEncodeTitle);
  writeNotNull(
      'transcode_hw_full_pipeline', instance.transcodeHardwareFullPipeline);
  writeNotNull('audio_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.audioDecision));
  writeNotNull('video_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.videoDecision));
  writeNotNull('subtitle_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.subtitleDecision));
  writeNotNull('throttled', instance.throttled);
  writeNotNull('transcode_hw_decoding', instance.transcodeHardwareDecoding);
  writeNotNull('transcode_hw_encoding', instance.transcodeHardwareEncoding);
  writeNotNull('stream_container', instance.streamContainer);
  writeNotNull('stream_bitrate', instance.streamBitrate);
  writeNotNull('stream_aspect_ratio', instance.streamAspectRatio);
  writeNotNull('stream_audio_codec', instance.streamAudioCodec);
  writeNotNull('stream_audio_channels', instance.streamAudioChannels);
  writeNotNull(
      'stream_audio_channel_layout', instance.streamAudioChannelLayout);
  writeNotNull(
      'stream_audio_channel_layout_', instance.streamAudioChannelLayout_);
  writeNotNull('stream_video_codec', instance.streamVideoCodec);
  writeNotNull('stream_video_resolution', instance.streamVideoResolution);
  writeNotNull('stream_video_framerate', instance.streamVideoFramerate);
  writeNotNull('stream_video_height', instance.streamVideoHeight);
  writeNotNull('stream_video_width', instance.streamVideoWidth);
  writeNotNull('stream_duration', instance.streamDuration?.inMicroseconds);
  writeNotNull(
      'stream_container_decision',
      TautulliUtilities.transcodeDecisionToJson(
          instance.streamContainerDecision));
  writeNotNull('optimized_version_title', instance.optimizedVersionTitle);
  writeNotNull('synced_version', instance.syncedVersion);
  writeNotNull('live_uuid', instance.liveUuid);
  writeNotNull('bif_thumb', instance.bifThumb);
  writeNotNull('transcode_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.transcodeDecision));
  writeNotNull('subtitles', instance.subtitles);
  writeNotNull(
      'stream_video_full_resolution', instance.streamVideoFullResolution);
  writeNotNull('stream_video_dynamic_range', instance.streamVideoDynamicRange);
  writeNotNull('stream_video_codec_level', instance.streamVideoCodecLevel);
  writeNotNull('stream_video_bitrate', instance.streamVideoBitrate);
  writeNotNull('stream_video_bit_depth', instance.streamVideoBitDepth);
  writeNotNull(
      'stream_video_chroma_subsampling', instance.streamVideoChromaSubsampling);
  writeNotNull(
      'stream_video_color_primaries', instance.streamVideoColorPrimaries);
  writeNotNull('stream_video_color_range', instance.streamVideoColorRange);
  writeNotNull('stream_video_color_space', instance.streamVideoColorSpace);
  writeNotNull('stream_video_color_trc', instance.streamVideoColorTRC);
  writeNotNull('stream_video_ref_frames', instance.streamVideoRefFrames);
  writeNotNull('stream_video_language', instance.streamVideoLanguage);
  writeNotNull('stream_video_language_code', instance.streamVideoLanguageCode);
  writeNotNull('stream_video_scan_type', instance.streamVideoScanType);
  writeNotNull('stream_video_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.streamVideoDecision));
  writeNotNull('stream_audio_bitrate', instance.streamAudioBitrate);
  writeNotNull('stream_audio_bitrate_mode', instance.streamAudioBitrateMode);
  writeNotNull('stream_audio_sample_rate', instance.streamAudioSampleRate);
  writeNotNull('stream_audio_language', instance.streamAudioLanguage);
  writeNotNull('stream_audio_language_code', instance.streamAudioLanguageCode);
  writeNotNull('stream_audio_decision',
      TautulliUtilities.transcodeDecisionToJson(instance.streamAudioDecision));
  writeNotNull('stream_subtitle_codec', instance.streamSubtitleCodec);
  writeNotNull('stream_subtitle_container', instance.streamSubtitleContainer);
  writeNotNull('stream_subtitle_format', instance.streamSubtitleFormat);
  writeNotNull('stream_subtitle_forced', instance.streamSubtitleForced);
  writeNotNull('stream_subtitle_location', instance.streamSubtitleLocation);
  writeNotNull('stream_subtitle_language', instance.streamSubtitleLanguage);
  writeNotNull(
      'stream_subtitle_language_code', instance.streamSubtitleLanguageCode);
  writeNotNull('stream_subtitle_transient', instance.streamSubtitleTransient);
  writeNotNull(
      'stream_subtitle_decision',
      TautulliUtilities.transcodeDecisionToJson(
          instance.streamSubtitleDecision));
  return val;
}
