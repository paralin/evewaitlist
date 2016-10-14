import { IService } from '../service';
import { Characters } from '../../schema/characters';

export class CheckActiveCharacters implements IService {

  public init() {
    this.checkActiveCharacters();
  }

  public checkActiveCharacters() {
    let lastAcceptableTime = (new Date().getTime()) - 10 * 1000;
    return Characters.update({
      active: true,
      lastActiveTime: {
        $lt: lastAcceptableTime
      }
    }, {
      $set: {
        active: false
      }
    }, {
      multi: true
    });
  }
}
