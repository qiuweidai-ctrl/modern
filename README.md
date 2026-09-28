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


