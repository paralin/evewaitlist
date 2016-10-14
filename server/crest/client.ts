import { Meteor } from 'meteor/meteor';
import { HTTP } from 'meteor/http';

export const CREST_ENDPOINT = 'https://crest-tq.eveonline.com/';
export class CrestClient {
  private options: HTTP.HTTPRequest;
  constructor(private token: string) {
    this.options = {
      headers: {
        Authorization: 'Bearer ' + token,
        Accept: 'application/json',
      },
    };
  }

  public call(method: string, uri: string, options: HTTP.HTTPRequest): HTTP.HTTPResponse {
    options.headers = options.headers || {};
    options.headers['Authorization'] = this.options.headers['Authorization'];
    options.headers['Accept'] = this.options.headers['Accept'];
    if (uri.indexOf('http') !== 0) {
      uri = CREST_ENDPOINT + uri;
    }
    return HTTP.call(method, uri, options);
  }

  public callTree(method: string, uri: string, options: HTTP.HTTPRequest): ICrestTree {
    let res = this.call(method, uri, options);
    return buildCrestTree(this, JSON.parse(res.content));
  }

  public root(): ICrestTree {
    return this.callTree('GET', CREST_ENDPOINT, {});
  }
}

export interface ICrestTree {
  [key: string]: any | ICrestTree;
}

export function buildCrestTree(client: CrestClient, data: Object): ICrestTree {
  let res: ICrestTree = {};
  for (let keyi in data) {
    if (!data.hasOwnProperty(keyi)) {
      continue;
    }
    (function(key: string, val: any) {
      // todo: parse first word, check if verb. if so, define a function on object, not getter
      let getProp = function(): any | ICrestTree {
        let method = 'GET';
        let options = {};
        if (key === 'href') {
          let cres = client.call(method || 'GET', val, options || {});
          return buildCrestTree(client, cres.data);
        }
        if (typeof val === 'object') {
          if (val.href && Object.keys(val).length === 1) {
            return client.callTree(method || 'GET', val.href, options || {});
          } else {
            return buildCrestTree(client, val);
          }
        }
        return val;
      };
      Object.defineProperty(res, key, {
        get: getProp,
        set: () => {},
        enumerable: true,
        configurable: true,
      });
    })(keyi, data[keyi]);
  }
  return res;
}

export function clientForUser(user: Meteor.User): CrestClient {
  return new CrestClient(user.services.eveonline.accessToken);
}
