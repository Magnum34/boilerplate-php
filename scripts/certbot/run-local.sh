#!/bin/bash

cd /var/www/localhost
# Generate Root Certificate and Key

openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=PL/CN=Example-Root-CA"
# Generate Certificate Signing Request

openssl x509 -outform pem -in RootCA.pem -out RootCA.crt

# Create a Configuration File

openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=US/ST=YourState/L=YourCity/O=Example-Certificates/CN=localhost.local"
openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile /usr/local/bin/domains.ext -out localhost.crt




