# Automated Deploy
## Windows
> You should run this script from where you want to host your Unity server. So if you want it to be on an amazon ec2 server then git clone this repo to the ec2 instance and follow along by doing everything on that instance. That also means your domain name must already be setup and pointed to this server. If running this locally via localhost, then you must already have your VPN setup and ports forwarded.

Navigate up one directory to `Docker/webgl_windows_get_certs.ps1`. This is the file that is used to automatically register a domain for you with letsencrypt, generate the certificates, and finally generate the pfx bundle need for unity server builds with WebGL Transport Layer.

Since this is not digitally signed by microsoft you have to allow your current powershell window to run none digitially signed scripts by running the following in the powershell window you plan on running the script in:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
Then you can run:
```
cd <path_to>/EMI_Server/Docker
./webgl_windows_get_certs.ps1
```
It will have output that will ask you for the `domain name` that you want to register with letsencrypt and the `email address` you want to register with letsencrypt:
```
Input your domain name: my_example_domain.com
Input the email you want to register with LetsEncrypt: emailaddress@gmail.com
```
Then it will do the rest for you. You can follow along with the output in the window. It should look something similar to the following:
```
Performing pre-checks...     
Verifying docker installed...
Docker version 20.10.16, build aa7e414
Verifying docker-compose installed...
docker-compose version 1.29.2, build 5becea4c
Verifying port 80 is open...

Port: 80, Open - Attempting to generate certs for domain: my_example_domain.com
Modifying files at ./WebGL-my_example_domain.com/
Starting basic nginx server on port 80...
Creating network "certsetup_docker-network" with driver "bridge"
Creating letsencrypt-nginx-container ... done
Verifying port 80 open on nginx docker...
Attempting to request LetsEncrypt certificates for domain: my_example_domain.com...
Creating certbot-prod-container ... done
Attaching to certbot-prod-container
certbot-prod-container    | Saving debug log to /var/log/letsencrypt/letsencrypt.log
certbot-prod-container    | Account registered.
certbot-prod-container    | Requesting a certificate for my_example_domain.com
certbot-prod-container    | 
certbot-prod-container    | Successfully received certificate.
certbot-prod-container    | Certificate is saved at: /etc/letsencrypt/live/my_example_domain.com/fullchain.pem
certbot-prod-container    | Key is saved at:         /etc/letsencrypt/live/my_example_domain.com/privkey.pem
certbot-prod-container    | This certificate expires on 2023-01-27.
certbot-prod-container    | These files will be updated when the certificate renews.
certbot-prod-container    | NEXT STEPS:
certbot-prod-container    | - The certificate will need to be renewed before it expires. Certbot can automatically renew the certificate in the background, but you may need to take steps to enable that functionality. See https://certbot.org/renewal-setup for instructions.
certbot-prod-container    |
certbot-prod-container    | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
certbot-prod-container    | If you like Certbot, please consider supporting our work by:
certbot-prod-container    |  * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
certbot-prod-container    |  * Donating to EFF:                    https://eff.org/donate-le
certbot-prod-container    | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
certbot-prod-container exited with code 0
Verifying LetsEncrypt certificates for domain: my_example_domain.com...
Recreating certbot-prod-container ... done
Attaching to certbot-prod-container
certbot-prod-container    | Saving debug log to /var/log/letsencrypt/letsencrypt.log
certbot-prod-container    | 
certbot-prod-container    | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
certbot-prod-container    | Found the following certs:
certbot-prod-container    |   Certificate Name: my_example_domain.com
certbot-prod-container    |     Serial Number: 1234567890abcdefg123451abcde12345795
certbot-prod-container    |     Key Type: RSA
certbot-prod-container    |     Domains: my_example_domain.com
certbot-prod-container    |     Expiry Date: 2023-01-27 01:17:27+00:00 (VALID: 89 days)
certbot-prod-container    |     Certificate Path: /etc/letsencrypt/live/my_example_domain.com/fullchain.pem
certbot-prod-container    |     Private Key Path: /etc/letsencrypt/live/my_example_domain.com/privkey.pem
certbot-prod-container    | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
certbot-prod-container exited with code 0
Recreating letsencrypt-nginx-container ... done
Attaching to dhparam_generator
dhparam_generator              | Generating DH parameters, 2048 bit long safe prime, generator 2
dhparam_generator              | This is going to take a long time
dhparam_generator              | ......
dhparam_generator exited with code 0
Creating pfx_generator ... done
Attaching to pfx_generator
pfx_generator exited with code 0
You can get your LetsEncrypt certificates at path: WebGL-my_example_domain.com/ProdSetup/certs/etc/letsencrypt/archive/my_example_domain.com/*
You can get your UnityServer pfx cert at: WebGL-my_example_domain.com/ProdSetup/certs/webgl/*
```
If you want to setup a cron job for automatically renewing your certificates, if using these on a website as well, you can find the configuration file needed for automatic renewal in `WebGL-<domain_name>/ProdSetup/certs/etc/letsencrypt/renewal`

# Manual Deploy
## The following expects you to follow it in order
Before starting anything be sure to do a global find and replace on the following:<br/>
`<domain_name>` -> your actual domain name, ex: `mysweetdomain.com`<br/>
`<email_address>` -> The email address you will register with letsencrypt, example `myemail@gmail.com`<br/>

### Generate LetsEncrypt Certificates
1. Run:
> This starts a basic port 80 website for checking on your domain
```
cd CertSetup
docker compose -f 01_basic_nginx_website.yml up -d
```
2. Test getting certs with certbot
```
docker compose -f 02_certbot_staging_certs.yml up
```
3. Verify certbot can recongize these testing certs:
```
docker compose -f 03_certbot_staging_verify.yml up
```
If it finds it find, then clear out the following directories:
```
ProdSetup/certs/etc/letsencrypt/*
ProdSetup/certs/var/lib/*
ProdSetup/certs/var/log/*
```
4. Generate your real/production certificates:
```
docker compose -f 04_certbot_prod_certs.yml up
```
5. Verify the production certificates:
```
docker compose -f 05_certbot_prod_certs_verify.yml up
```
You should now be able to find your certificates at the following location:
```
ProdSetup/certs/etc/letsencrypt/live/<domain_name>/*
```
If you don't find them there open an explorer window as sometimes the permissions will obscure these files. They are also copied to the `archive` directory here.
```
ProdSetup/certs/etc/letsencrypt/archive/<domain_name>/*
```

### Generate NGINX Website Certs
Now generate the openssl dhparam certificate:
```
docker compose -f 06_dhparam_generate.yml up
```
This will generate a dh param certificate and put it into:
```
ProdSetup/dhparam/dhparam-2048.pem
```

### Generate Unity WebGL Certs
Now generate the `cert.pfx` file needed for the WebGL transport layer:
```
docker compose -f 07_webgl_pfx_cert.yml
```
This will spit out a `cert.pfx` file at: `ProdSetup/certs/webgl/cert.pfx`.

### Start NGINX Website
Now we can stop the setup container and start the production docker that will have a long running server and website:
```
docker compose -f 01_basic_nginx_website.yml down
cd ../ProdSetup
docker compose -f website_v2.yml up
```

Then you can cleanup your system from the leftover dockers by running:
```
docker system prune
```
Then respond "Y".

### Start Unity WebGL Server
First copy over your built webgl unity server to the `unity_server` directory.
The exexcutable must be named `Server.x86_64`, or change the name in the `unity-webgl-server.yml` file.

Be sure to build for the `Linux` OS.
```
docker compose -f unity-webgl-server.yml up -d
```

### Start Unity WebGL Client
You can build your client and move your files into the previously build or your own hosted `https` domain. As if you try to run this from `localhost` it will not be coming from an `https` domain and will not successfully connect to your letsencrypt domain.

This was made possible from here: https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx/
