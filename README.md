#  DevOpsLab: My Home IT Infrastructure Project

> *"Stay hungry. Stay foolish."*  
> *"Простота  высшая форма изысканности."*

This is my **hands-on DevOps journey**  building a scalable, automated, and documented IT environment from scratch.  
No cloud credits. No magic. Just **real hardware, real problems, and real solutions**.

I'm not just learning technologies  I'm building a **platform for my future**.

---

##  What Is This?

`DevOpsLab` is my personal **home lab and DevOps training ground**, designed to:
- Master Linux, networking, automation, and monitoring
- Remotely manage servers and workstations
- Prepare for real-world DevOps/SRE roles
- Build a portfolio project that proves my skills

>  **No Docker yet?** That's fine.  
> This project starts with the **basics**  because real infrastructure is built layer by layer.

---

##  Hardware Overview

| Device               | Specs |
|----------------------|-------|
| **Main Server**      | Intel Xeon E5-2650 v2, 16GB DDR3, 256GB SSD, Ubuntu 22.04 |
| **Gaming PC**        | i5-12600KF, RTX 3070, 32GB DDR5, Windows 10 |
| **Secondary PC**     | Xeon E5-2650 v2, RX 580, 16GB DDR3, Windows 10 |
| **Raspberry Pi 3B+** | Control terminal, script runner, SSH gateway |

All devices are mounted in a **4U rack** with managed power (smart plugs), UPS-ready power distribution, and physical safety (RCD + circuit breaker).

---

##  Network & Access

- **Switch**: HP 1810G-24 (managed, 24-port 1Gbps)
- **Remote Access**: ZeroTier (private virtual network)
- **Wake-on-LAN**: Full control over power state
- **Planned**: VLANs, static IPs, QoS

 **Security note**:  
All sensitive data (passwords, API keys, private IPs) are kept **out of this repo**.  
Configuration templates use placeholders like `<your_ip>`, `<your_token>`.

---

##  Key Technologies & Skills

| Area             | Tools & Skills |
|------------------|--------------|
| **Linux**        | Ubuntu Server, Bash, systemd, cron, ufw |
| **Networking**   | ZeroTier, DHCP, DNS, static routing |
| **Automation**   | Bash, Python, Ansible (in progress) |
| **Monitoring**   | Zabbix (planned), Prometheus (future) |
| **Virtualization** | KVM (setup guide in progress) |
| **CI/CD**        | GitHub Actions (pipeline for scripts) |
| **Git & Docs**   | Full documentation, MkDocs (planned) |

>  This project proves that you can **start DevOps without Kubernetes**.  
> Focus on **foundations**: automation, observability, version control.

---


##  Security & Privacy Policy

This repository follows strict rules:
-  **No passwords, tokens, or private IPs**
-  **No Wi-Fi credentials or ZeroTier secrets**
-  **No personal data (names, emails, etc.)**
-  All configs use **placeholders**
-  Sensitive scripts are **templated or omitted**
-  `.gitignore` blocks logs, configs, and credentials

> This is a **teaching and portfolio repo**, not a deployment one.

---

##  Whats Next?

### Phase 1: Foundations
- [x] Ubuntu server setup
- [x] ZeroTier network
- [ ] HP switch configuration
- [ ] WOL & smart plug automation

### Phase 2: Virtualization & AD
- [ ] Install KVM
- [ ] Deploy Windows Server VM
- [ ] Set up Active Directory, DNS, DHCP
- [ ] Join machines to domain

### Phase 3: Observability
- [ ] Install Zabbix Server
- [ ] Monitor host status, disk usage, uptime
- [ ] Set up alerts

### Phase 4: CI/CD & GitOps
- [ ] GitHub Actions: run scripts on push
- [ ] Test pipeline: "Is PC online?"
- [ ] Future: Argo CD + k3s

---

##  Why This Matters

> *"DevOps is not a job title. It's a culture: automation, collaboration, and continuous improvement."*  
>  [roadmap.sh/devops](https://roadmap.sh/devops)

On job interviews, Ill say:
> "I built a full home IT platform  from power distribution to CI/CD.  
> Its not perfect, but its **mine**.  
> Every line of config, every script, every mistake taught me something.  
> Im not just learning DevOps. Im **living it**."

---

##  Inspiration

- Steve Jobs: *"Technology should work for you, not the other way around."*
- Real DevOps engineers: *"Show projects, not just certificates."*
- Myself: *"I dont want to be a student forever. I want to be an engineer."*

---

##  Final Note

This is not a toy.  
This is a **career accelerator**.

