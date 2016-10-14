import { Meteor } from 'meteor/meteor';
import { IService } from '../service';

import * as winston from 'winston';

// Service that automatically updates user refresh tokens.
export class UserTokenRefreshService implements IService {
  private running = false;
  private updateInterval: number;

  public init() {
    //
  }

  public startup() {
    if (this.running) {
      return;
    }
    this.running = true;
    // Update every minute.
    this.updateInterval = Meteor.setInterval(() => {
      this.refreshTokens();
    }, 60000);
    this.refreshTokens();
  }

  public refreshTokens() {
    let latestExpire = new Date();
    latestExpire.setHours(latestExpire.getHours() + 2);

    // Find any tokens expiring in the next 2 hours
    let users = Meteor.users.find({
      'services.eveonline.expiresAt': {
        $lt: latestExpire.getTime(),
      },
    }).fetch();
    for (let user of users) {
      let eveService = user.services.eveonline;
      let refreshToken = eveService.refreshToken;
      if (!refreshToken) {
        continue;
      }

      winston.debug('Refreshing token for user ' + user.profile.eveOnlineCharacterName + '...');
      try {
        EveonlineHelpers.refreshAuthToken(user);
      } catch (e) {
        winston.error('Unable to refresh token, ' + e);
      }
      winston.debug('Token for user ' + user.profile.eveOnlineCharacterName + ' refreshed.');
    }
  }

  public close() {
    this.running = false;
    if (this.updateInterval != null) {
      Meteor.clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }
}
