# Practical sessions 2,3,4

## Task 1. Install Git
Command:
```bash
apt update
apt install git -y
# modern
modern programmming platforms


# Practical sessions 5, 6: Installing and Using FreeIPA

## 1. Configure the firewall
Open required ports for FreeIPA service in firewall.
```bash
# Install firewall tool
apt install ufw -y
# Allow FreeIPA required ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 389/tcp
ufw allow 636/tcp
ufw allow 88/tcp
ufw allow 464/tcp
ufw allow 53/tcp
ufw allow 88/udp
ufw allow 464/udp
# Enable firewall
ufw enable
# Check firewall status
ufw status

Status: active
To                         Action      From
--                         ------      ----
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
389/tcp                    ALLOW       Anywhere
636/tcp                    ALLOW       Anywhere
88/tcp                     ALLOW       Anywhere
464/tcp                    ALLOW       Anywhere
53/tcp                     ALLOW       Anywhere
88/udp                     ALLOW       Anywhere
464/udp                    ALLOW       Anywhere


## Task 2: Install and run FreeIPA
### Commands:
```bash
apt update -y
apt install freeipa-server -y
ipa-server-install


The IPA Master Server will be configured with:
Hostname: ipa-server.ipa.local
IP address: 127.0.0.1
Domain name: ipa.local
Realm name: IPA.LOCAL

Continue to configure the system with these values? [no]: yes

The ipa-server-install command was successful



## Task 3: Configure and connect the client
### Commands:
```bash
apt update -y
apt install freeipa-client -y
ipa-client-install --domain=ipa.local --realm=IPA.LOCAL --server=ipa-server.ipa.local



Provide the administrator credentials to join the domain:
Username: admin
Password: ********
Successfully enrolled client "client.ipa.local"
The ipa-client-install command was successful



## Task 4: Create user
### Commands:
```bash
ipa user-add student --first=Student --last=User --password


Password:
Enter password again to verify:
Added user "student"
-----------------------
User login: student
First name: Student
Last name: User
Full name: Student User




## Task 5: Create group and add user to group
### Commands:
```bash
ipa group-add student_group
ipa group-add-member student_group --users=student

Added group "student_group"
Group name: student_group
Description: student_group
------------------------
Number of members added 1



## Task 6: Check user and group information
### Commands:
```bash
ipa user-show student
ipa group-show student_group



User login: student
First name: Student
Last name: User
Group memberships: student_group

Group name: student_group
Members: student




## Task 7: Modify user information
### Commands:
```bash
ipa user-mod student --city=Grodno


Modified user "student"
User login: student
First name: Student
Last name: User
City: Grodno
Group memberships: student_group
