# The following expects you to follow it in order
Before starting anything be sure to do a global find and replace on the following:
`<domain_name>` -> your actual domain name, ex: mysweetdomain.com
`<email_address>` -> The email address you will register with letsencrypt, example `wes@cyberbulletgames.com`

## Generate LetsEncrypt Certificates
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

## Generate NGINX Website Certs
Now generate the openssl dhparam certificate:
```
docker compose -f 06_dhparam_generate.yml up
```
This will generate a dh param certificate and put it into:
```
ProdSetup/dhparam/dhparam-2048.pem
```

## Generate Unity WebGL Certs
Now generate the `cert.pfx` file needed for the WebGL transport layer:
```
docker compose -f 07_webgl_pfx_cert.yml
```
This will spit out a `cert.pfx` file at: `ProdSetup/certs/webgl/cert.pfx`.

## Start NGINX Website
Now we can stop the setup container and start the production docker that will have a long running server and website:
```
docker compose -f 01_basic_nginx_website.yml down
cd ../ProdSetup
docker compose up -d
```
On `Windows` you might come across this error: `The file cannot be accessed by the system.` when attempting to run the above command. To fixed this dreaded error simply run the `v2` of the file that I have prepared:
```
docker compose -f docker-compose_v2.yml up -d
```

Then you can cleanup your system from the leftover dockers by running:
```
docker system prune
```
Then respond "Y".

## Start Unity WebGL Server
First copy over your built webgl unity server to the `unity_server` directory.
The exexcutable must be named `Server.x86_64`, or change the name in the `unity-webgl-server.yml` file.

Be sure to build for the `Linux` OS.
```
docker compose -f unity-webgl-server.yml up -d
```

## Start Unity WebGL Client
You can build your client and move your files into the previously build or your own hosted `https` domain. As if you try to run this from `localhost` it will not be coming from an `https` domain and will not successfully connect to your letsencrypt domain.

This was made possible from here: https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx/
