# NOTE: Must allow none digitially signed scripts to be run in your current session:
# * Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$Domain = Read-Host -Prompt 'Input your domain name'
if ($Domain -eq "") {
    Write-Output "You must put in a domain name to test and register with letsencrypt to continue, exiting."
    return 
}
$Email = Read-Host -Prompt 'Input the email you want to register with LetsEncrypt'
if ($Email -eq "") {
    Write-Output "You must put in a email address to register with letsencrypt to continue, exiting."
    return 
}

Write-Output "Performing pre-checks..."
Write-Output "Verifying docker installed..."
docker -v

Write-Output "Verifying docker-compose installed..."
docker-compose -v

Write-Output "Verifying port 80 is open..."
Write-Output ""
if (!$(New-Object System.Net.Sockets.TcpClient($Domain, 80)).Connected) {
    Write-Output "Port: 80, Not open. This means you cannot get certificates. Open this port to continue."
}
else {
    Write-Output "Port: 80, Open - Attempting to generate certs for domain: $Domain"
    
    Copy-Item -Path "WebGL" -Destination "WebGL-$Domain" -Recurse

    Write-Output "Modifying files at ./WebGL-$Domain/"
    (Get-Content -path ./WebGL-$Domain/CertSetup/01_basic_nginx_website.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/01_basic_nginx_website.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/02_certbot_staging_certs.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/02_certbot_staging_certs.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/03_certbot_staging_certs_verify.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/03_certbot_staging_certs_verify.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/04_certbot_prod_certs.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/04_certbot_prod_certs.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/05_certbot_prod_certs_verify.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/05_certbot_prod_certs_verify.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/06_dhparam_generate.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/06_dhparam_generate.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/07_webgl_pfx_cert.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/07_webgl_pfx_cert.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/nginx.conf -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/CertSetup/nginx.conf
    (Get-Content -path ./WebGL-$Domain/CertSetup/04_certbot_prod_certs.yml -Raw).replace('<email_address>',$Email) | Set-Content ./WebGL-$Domain/CertSetup/04_certbot_prod_certs.yml
    (Get-Content -path ./WebGL-$Domain/CertSetup/07_webgl_pfx_cert.yml -Raw).replace('<email_address>',$Email) | Set-Content ./WebGL-$Domain/CertSetup/07_webgl_pfx_cert.yml

    (Get-Content -path ./WebGL-$Domain/ProdSetup/unity-webgl-server.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/unity-webgl-server.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/unity-webgl-server.yml -Raw).replace('<email_address>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/unity-webgl-server.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/website_v1.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/website_v1.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/website_v1.yml -Raw).replace('<email_address>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/website_v1.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/website_v2.yml -Raw).replace('<domain_name>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/website_v2.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/website_v2.yml -Raw).replace('<email_address>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/website_v2.yml
    (Get-Content -path ./WebGL-$Domain/ProdSetup/production.conf -Raw).replace('<email_address>',$Domain) | Set-Content ./WebGL-$Domain/ProdSetup/production.conf

    Write-Output "Starting basic nginx server on port 80..."
    docker-compose -f ./WebGL-$Domain/CertSetup/01_basic_nginx_website.yml up -d
    sleep 5
    do {
        sleep 0.1
    } while ("$(docker inspect -f "{{.State.Running}}" "letsencrypt-nginx-container")" -ne "true")
    Write-Output "Verifying port 80 open on nginx docker..."
    $connection = New-Object System.Net.Sockets.TcpClient("localhost", 80)
    if ($connection.Connected) {
        Write-Output "Attempting to request LetsEncrypt certificates for domain: $Domain..."
        docker-compose -f ./WebGL-$Domain/CertSetup/04_certbot_prod_certs.yml up
        
        Write-Output "Verifying LetsEncrypt certificates for domain: $Domain..."
        docker-compose -f ./WebGL-$Domain/CertSetup/05_certbot_prod_certs_verify.yml up

        docker-compose -f ./WebGL-$Domain/CertSetup/06_dhparam_generate.yml up
        docker-compose -f ./WebGL-$Domain/CertSetup/07_webgl_pfx_cert.yml up

        Write-Output "You can get your LetsEncrypt certificates at path: WebGL-$Domain/ProdSetup/certs/etc/letsencrypt/archive/$Domain/*"
        Write-Output "You can get your UnityServer pfx cert at: WebGL-$Domain/ProdSetup/certs/webgl/*"
    }
    else 
    {
        Write-Output "Failed starting nginx container."
    }
}
