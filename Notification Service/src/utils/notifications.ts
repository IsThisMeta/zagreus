// Notification payload interfaces

export interface Payload {
  title: string;
  body: string;
  image?: string;
  data?: {
    [key: string]: string;
  };
}

export interface Settings {
  sound: boolean;
  ios: {
    interruptionLevel: iOSInterruptionLevel;
  };
}

export enum iOSInterruptionLevel {
  PASSIVE = 'passive',
  ACTIVE = 'active',
  TIME_SENSITIVE = 'time-sensitive',
}


export const generateTitle = (module: string, profile: string, body: string): string => {
  if (profile && profile !== 'default') return `${module} (${profile}): ${body}`;
  return `${module}: ${body}`;
};
