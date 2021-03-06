import { Meteor } from 'meteor/meteor';
import { IService } from '../service';
// import { Tracker } from 'meteor/tracker';
// import { Waitlists, IWaitlist } from '../../schema/waitlist';

export class FleetMonitorService implements IService {
  private running = false;
  private updateTimeout: number;

  public init() {
    //
  }

  public startup() {
    this.running = true;
    this.setNextUpdate();
  }

  public close() {
    this.running = false;
    Meteor.clearTimeout(this.updateTimeout);
  }

  private update() {
    // let waitlists: IWaitlist[] = Waitlists.find({finished: false}).fetch();
  }

  private setNextUpdate() {
    this.updateTimeout = Meteor.setTimeout(() => {
      this.update();
    }, 5000);
  }
}
