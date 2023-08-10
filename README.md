# ssl-cert-check


## ssl-cert-check
---
Loads CSV file
Checks hostnames
- Checks cert valid-until date  
- Calculates remaining Days


### CSV file
---
File needs header row

Current columns
- id -> may not needs
- host_name -> URL host name for cert Check 
- port -> Default: 443, specify different if needed
- last_checked -> last scan date 
- days_remaining -> how many days left on the cert
  - set warning messages based on <= 30 days?
- Expiry_date -> the actual date of expiration
  - used to calculate days remaining



### TODOs
---
- Add default params for url:port = 443
- Set up emailer to send weekly Cert Report
- use emailer to send warning messages on certs expiring soon
- set up menu
  - check for 'updates'
  - print out current days left
  - ?

- set up CLI progress bars?
  - gem tty-progressbar
