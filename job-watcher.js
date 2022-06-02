require('dotenv').config()
const { firefox } = require('playwright-firefox');
const sleep = require('util').promisify(setTimeout);
const { sendMail } = require('./utils');

const URL = process.env.URL;

(async () => {
  let isDevOpsJobAvailable = false;

  while (!isDevOpsJobAvailable) {
      const browser = await firefox.launch();
      const context = await browser.newContext({
        userAgent: "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36"
      });
      const page = await context.newPage();
      await page.goto(URL);
  
      await page.focus("input[name='quick-search']");
      await page.keyboard.type(process.env.KEYWORD);
      await page.waitForTimeout(500);
  
      const listings = await page.$$('.JobListing');
  
      if (listings.length > 0) {
        sendMail();
        isDevOpsJobAvailable = true;
      } else {
        const currentTime = new Date().toLocaleString('en-US', { timezone: 'America/Los_Angeles'});
        console.log(`${currentTime} |  *** No ${process.env.KEYWORD} jobs available ***`);
      }
      await browser.close();
      await sleep(300000);
  } 
})();