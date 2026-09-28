# Practical work: FreeIPA user and group management
This practical work demonstrates FreeIPA server installation, client enrollment, certificate management and SSH authentication. All operations are prepared for Ubuntu Linux environment.

## Task 1: Configure the firewall
### Commands:
```bash
sudo firewall-cmd --add-service={http,https,dns,ldap,ldaps,kerberos,kpasswd} --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --list-services


Expected output:

success
success
http https dns ldap ldaps kerberos kpasswd


## Task 2: Install and run FreeIPA server
### Comands:
```bash
sudo dnf install ipa-server ipa-server-dns -y
sudo ipa-server-install
ipa server status


Expected output:

Installation completed successfully
Server is configured and running.
IPA server: READY


## Task 3: Configure and connect the client to FreeIPA domain
### Commands:
```bash
sudo ipa-client-install --domain=ipa.local --server=server.ipa.local
ipa user-find


Expected output:

Client enrolled into IPA domain ipa.local successfully
Discovery of server completed.
User list displayed.


## Task 4: Create and test the user
### Commands:
```bash
ipa user-add student --first=Student --last=User
ipa user-show student


Expected output:

Added user "student"
User login: student
First name: Student
Last name: User



## Task 5: Create a security group
### Commands:
```bash
ipa group-add student_group
ipa group-add-member student_group --users=student
ipa group-show student_group


Expected output:

Added group "student_group"
Group members added.
Group name: student_group
Members: student



## Task 6: Issue a certificate for the computer
### Commands:
```bash
ipa-getcert request -f /etc/pki/tls/certs/client.crt -k /etc/pki/tls/private/client.key -N CN=client.ipa.local
ipa-getcert list


Expected output:

New signing request "20260928152000" added.
Status: MONITORING
Storing key in /etc/pki/tls/private/client.key
Storing cert in /etc/pki/tls/certs/client.crt
Certificate issued successfully



## Task 7: Perform SSH authentication via FreeIPA
### Commands:
kinit student
ssh -GSSAPIAuthentication yes student@client.ipa.local
klist


Expected output:

Password for student@IPA.LOCAL:
Ticket cache obtained successfully
Connected to client.ipa.local without password prompt
Valid Kerberos tickets are listed in klist output



## Task 8: Remove the client from the domain
### Commands:
```bash
ipa-client-install --uninstall


Expected output:

Unenrolling client from IPA server
Removing IPA client configuration
Client uninstall complete.
System restored to pre‑IPA state
