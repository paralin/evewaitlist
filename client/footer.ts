declare var showOwnerDetails: any;
declare var sendEvemail: any;

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
    showOwnerDetails(90720899);
  },
  'click .msgmorph': function(e) {
    e.preventDefault();
    sendEvemail(90720899, 'Waitlist Issue Report', generateCharMsg(Session.get('me')));
  }
});
