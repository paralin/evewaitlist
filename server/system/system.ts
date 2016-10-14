import { HTTP } from 'meteor/http';
import { IService } from '../service';
import { SolarSystems } from '../../schema/solarsystem';
import { CREST_ENDPOINT } from '../crest/client';

import * as winston from 'winston';

export class SolarSystemFetcher implements IService {
  public init() {
    let oldest = new Date();
    oldest.setHours(oldest.getHours() - 24);
    let lfRecord = SolarSystems.findOne({_id: '0'});
    if (lfRecord && lfRecord.lastFetch.getTime() > oldest.getTime()) {
      return;
    }

    winston.info('System data is old, refetching...');

    SolarSystems.remove({});
    let res = HTTP.get(CREST_ENDPOINT + 'solarsystems/');
    let data = JSON.parse(res.content);
    for (let item of data['items']) {
      SolarSystems.insert({
        _id: '' + item.id,
        name: item.name,
        name_lower: item.name.toLowerCase(),
      });
    }
    SolarSystems.insert({
      _id: '0',
      name: null,
      name_lower: null,
      lastFetch: new Date(),
    });
  }
}
