import { IService } from '../service';

import { UserTokenRefreshService } from './token_refresh';
import { CharacterFetcherService } from './character_fetcher';
import { CheckActiveCharacters } from './active_characters';

export const USER_SERVICES: IService[] = [
  new UserTokenRefreshService(),
  new CharacterFetcherService(),
  new CheckActiveCharacters(),
];
