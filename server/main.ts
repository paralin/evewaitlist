import { Meteor } from 'meteor/meteor';
import { IService } from './service';

import * as winston from 'winston';

// services
import { USER_SERVICES } from './user/services';
import { SolarSystemFetcher } from './system/system';

const services: IService[] = [
  ...USER_SERVICES,
  new SolarSystemFetcher(),
];

Meteor.startup(() => {
  winston.info('Initializing services...');
  for (let service of services) {
    service.init();
  }
  for (let service of services) {
    if (service.startup) {
      service.startup();
    }
  }
  winston.info('Service initialization complete.');
});
