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
    Meteor.call('sendEvemail',
                90720899,
                'Waitlist Issue Report',
                generateCharMsg(Session.get('me')), (error) => {
      if (error) {
        swal({
          title: 'Error',
          text: error.reason,
          type: 'error'
        });
      } else {
        swal({
          title: 'Issue Report',
          text: 'Check your EVE client, a prefilled evemail should be open.',
          type: 'success'
        });
      }
    });
  }
});
