export enum NotificationType {
  ISSUE_CREATED = 'ISSUE_CREATED',
  ISSUE_RESOLVED = 'ISSUE_RESOLVED',
  ISSUE_REOPENED = 'ISSUE_REOPENED',
  ISSUE_COMMENT = 'ISSUE_COMMENT',
  MEDIA_APPROVED = 'MEDIA_APPROVED',
  MEDIA_AUTO_APPROVED = 'MEDIA_AUTO_APPROVED',
  MEDIA_AVAILABLE = 'MEDIA_AVAILABLE',
  MEDIA_DECLINED = 'MEDIA_DECLINED',
  MEDIA_FAILED = 'MEDIA_FAILED',
  MEDIA_PENDING = 'MEDIA_PENDING',
  TEST_NOTIFICATION = 'TEST_NOTIFICATION',
}

export enum MediaType {
  MOVIE = 'movie',
  TV_SHOW = 'tv',
}

export enum IssueType {
  VIDEO = 'VIDEO',
  AUDIO = 'AUDIO',
  SUBTITLES = 'SUBTITLES',
  OTHER = 'OTHER',
}

export enum IssueStatus {
  OPEN = 'OPEN',
  RESOLVED = 'RESOLVED',
}

export interface RequestProperties {
  notification_type?: NotificationType;
  event?: string;
  subject?: string;
  message?: string;
  image?: string;
  email?: string;
  username?: string;
  avatar?: string;
  media?: MediaProperties;
  extra?: Record<string, unknown>;
  request?: RequestByProperties;
  issue?: IssueProperties;
  comment?: CommentProperties;
}

export interface RequestByProperties {
  request_id?: string;
  requestedBy_username?: string;
  requestedBy_email?: string;
  requestedBy_avatar?: string;
  requestedBy_settings_discordId?: string;
  requestedBy_settings_telegramChatId?: string;
}

export interface MediaProperties {
  media_type?: MediaType;
  tmdbId?: string;
  imdbId?: string;
  tvdbId?: string;
  status?: string;
  status4k?: string;
}

export interface IssueProperties {
  issue_id?: number;
  issue_type?: IssueType;
  issue_status?: IssueStatus;
  createdBy_email?: string;
  createdBy_username?: string;
  createdBy_avatar?: string;
}

export interface CommentProperties {
  comment_message?: string;
  commentedBy_email?: string;
  commentedBy_username?: string;
  commentedBy_avatar?: string;
}
