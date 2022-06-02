require('dotenv').config();

const ses = require('node-ses'),
  client = ses.createClient({ key: process.env.SES_KEY , secret: process.env.SES_SECRET, amazon: process.env.SES_SERVER });

const sendMail = async () => {
  client.sendEmail({
    to: process.env.TO,
    from: process.env.FROM,
    subject: 'LivRez DevOps Job Listing',
    message: `
    <h1>DevOps job available</h1><br>
    <p>Here is your job link <a href="${process.env.URL}">job</a></p>
    `
 }, function (err, data, res) {
 });
}

module.exports = { sendMail };