let generateCharMsg = function(char) {
  return `
Dear Morpheus Deathbrew,

Here are my comments about the waitlist app:

Sincerely,
${char.name}
`;
};

Template['footer'].events({
  'click .morph': function(e) {
    e.preventDefault();
    Meteor.call('showOwnerDetails', 90720899, (error) => {
      if (error) {
        swal({
          title: 'Error',
          text: error.reason,
          type: 'error'
        });
      }
    });
  },
  'click .msgmorph': function(e) {
    e.preventDefault();
    declare var sendEvemail: any;
    sendEvemail(90720899, 'Waitlist Issue Report', generateCharMsg(Session.get('me')));
  }
});
