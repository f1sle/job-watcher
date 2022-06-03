require('dotenv').config();
const SMSru = require('sms_ru');
const sms = new SMSru(process.env.SMS_API_KEY);

const ses = require('node-ses'),
  client = ses.createClient({ key: process.env.SES_KEY , secret: process.env.SES_SECRET, amazon: process.env.SES_SERVER });

const subject = `LivRez ${process.env.KEYWORD}`
const messageEmail = `
                      <h1>DevOps job available</h1><br>
                      <p>Here is your job link <a href="${process.env.URL}">job</a></p>
                      `
const messageSMS = `${subject} Here is your job link: ${process.env.URL}`

const sendMail = () => {
  client.sendEmail({
    to: process.env.TO,
    from: process.env.FROM,
    subject: subject,
    message: messageEmail
 }, function (err, data, res) {
 });
}

const sendSMS = (message = messageSMS ) => {
  sms.sms_send({
    to: process.env.SMS_TO,
    text: message,
    from: process.env.SMS_FROM,
    }, (e) => {
      console.log(e.description)
    }
  )
}

module.exports = { sendMail, sendSMS };