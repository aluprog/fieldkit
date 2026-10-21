# 🐱 MEOW
### Hack The Box · Starting Point · Tier 0

> **Machine #001 | Day 01 | Status: Completed**
>
> 🎯 **Objective:** Learn the basic workflow for connecting to a target, identifying exposed services, accessing a vulnerable system, and retrieving the flag.
>
> 🧭 **Difficulty:** Very Easy
>
> 🧰 **Tools:** Terminal, OpenVPN, `ping`, Nmap, Telnet
>
> 🏷️ **Tags:** `#HTB` `#FieldKit` `#StartingPoint` `#Easy` `#Linux` `#Nmap` `#Telnet` `#Port23` `#Enumeration` `#RootAccess`

---

## 📌 01. Machine Overview

**What is Meow?**

Meow is a beginner-level Hack The Box Starting Point machine designed to introduce fundamental penetration-testing concepts. The exercise involves connecting to the lab, checking connectivity, identifying an open port, discovering the service running on that port, accessing the target through Telnet, and retrieving a flag.

The machine demonstrates an important principle:

> 🔑 A successful penetration test starts with understanding the target, not blindly trying commands.

### 🗺️ Attack path

```text
HTB Dashboard
     |
     v
Connect through OpenVPN
     |
     v
Check target connectivity
     |
     v
Scan with Nmap
     |
     v
Discover TCP port 23
     |
     v
Identify Telnet
     |
     v
Connect and authenticate as root
     |
     v
Locate flag.txt
     |
     v
Read the flag
```

---

# 🧩 02. Task-by-Task Walkthrough

## 🟢 TASK 1 — Virtual Machines

**❓ Question**

In cybersecurity, isolated environments — like a sandbox or a vulnerable target — are often called VMs. What does VM stand for?

**✅ Answer**

Virtual Machine.

**⚙️ Process**

I read the question and recognized that VM is the abbreviation for Virtual Machine.

**💡 Lesson**

A virtual machine (VM) is a software-based computer that runs an operating system inside a virtualized environment.

Security professionals use VMs to create isolated labs, test software, study malware safely, and practice penetration testing without using their everyday computer as the target.

In this exercise, my computer is the system I use to interact with HTB, while Meow is the remote target machine.

**📝 Note — VM vs. sandbox**

These terms are related but not identical.

- **VM:** A virtualized computer that can run its own operating system.
- **Sandbox:** An isolated environment designed to restrict what an application or process can access or change.

A VM can be used as a sandbox, but not every sandbox is a VM.

---

## 🟡 TASK 2 — The Terminal

**❓ Question**

What tool do we use to interact with the operating system in order to issue commands through the command line?

**✅ Answer**

Terminal.

**⚙️ Process**

I initially froze even though the question was simple. After rereading it carefully, I understood what it was asking and answered correctly.

**💡 Lesson**

My difficulty was not a lack of technical knowledge. I had failed to process the wording of the question properly.

This is an important habit to develop: when a question seems confusing, pause and read it again before assuming I do not know the answer.

A terminal provides an interface for interacting with a command-line shell. The shell interprets commands and requests actions from the operating system.

For example:

```bash
pwd
ls
whoami
```

- `pwd` — shows the current working directory.
- `ls` — lists files and directories.
- `whoami` — prints the current user's username.

**📝 Note — Terminal vs. shell**

They are not technically the same thing.

The terminal is the interface through which I enter commands and see their output. The shell, such as Bash, interprets the commands I enter.

---

## 🟢 TASK 3 — VPN Connection

**❓ Question**

What tool do we use to establish our VPN connection to Hack The Box?

**✅ Answer**

OpenVPN.

**⚙️ Process**

I used OpenVPN to connect my machine to the HTB lab network. Once the connection was established, HTB indicated that I was connected.

**💡 Lesson**

A VPN creates a protected network connection that allows my computer to communicate with systems on a remote network.

For this lab, the connection makes it possible to reach the target through the network route provided by HTB.

However, seeing a successful VPN connection does not automatically prove that the target itself is reachable. The VPN connection and target connectivity are two separate things to verify.

**📝 Note — What happens when I connect?**

My computer does not become the target machine. Instead, the VPN provides a route into the lab network, allowing my computer to communicate with the target where network rules permit it.

---

## 🟡 TASK 4 — Testing Connectivity with ICMP

**❓ Question**

What tool do we use to test our connection to the target with an ICMP Echo Request?

**✅ Answer**

`ping`

**⚙️ Process**

I did not execute `ping` immediately after connecting. I trusted the connected status displayed by HTB and moved directly to the next step.

**💡 Lesson**

Next time, I should verify connectivity rather than assume everything is working.

The basic command is:

```bash
ping -c 4 10.129.40.126
```

This sends four ping requests to the target IP address and displays the responses received.

A successful response indicates that the target is responding to ICMP Echo Requests.

However, **a failed ping does not necessarily mean the target is unreachable.** The target or a firewall may block ICMP traffic while allowing connections to other services.

Also, being on the same subnet is not a requirement for a successful ping. Routing can allow communication between different subnets.

**📝 Note — What is ICMP?**

ICMP stands for Internet Control Message Protocol. It is used for network diagnostics and error reporting. The `ping` utility commonly uses ICMP Echo Requests and Echo Replies to test whether a host responds.

---

## 🟢 TASK 5 — Port Scanning

**❓ Question**

What is the name of the most common tool for finding open ports on a target?

**✅ Answer**

Nmap.

**⚙️ Process**

I used the following command:

```bash
sudo nmap 10.129.40.126
```

Nmap scanned the target and returned information about the ports it found, including an open TCP port on port 23.

**💡 Lesson**

Port scanning is one of the first major steps in reconnaissance.

Before attempting to log in or exploit a service, I need to discover which network services are exposed and investigate what they do.

My first scan was sufficient to discover the relevant port. However, a default Nmap scan does not identify every possible port or service.

Useful commands for future labs:

```bash
# Basic scan of common TCP ports
nmap 10.129.40.126

# Scan all TCP ports
nmap -p- 10.129.40.126

# Detect service versions on discovered ports
nmap -sV -p 23 10.129.40.126
```

The last command attempts to identify the service and its version on port 23.

**Important:** Use scans only against targets you own or are authorized to assess, such as your assigned HTB machine.

**📝 Note — What is a port?**

A port is a numbered endpoint used by network services to communicate over a transport protocol.

For example, a computer can run a web server and a remote-access service simultaneously, with each service listening on its own port.

An open port is a clue about what the target is offering. It is not, by itself, proof of a vulnerability.

---

## 🟢 TASK 6 — Identifying Telnet

**❓ Question**

What service did we identify on port `23/tcp` during our scan?

**✅ Answer**

Telnet.

**⚙️ Process**

I ran:

```bash
sudo nmap 10.129.40.126
```

The scan showed that TCP port 23 was open and associated it with Telnet.

The relevant result was essentially:

```text
PORT   STATE SERVICE
23/tcp open  telnet
```

**💡 Lesson**

I learned that Nmap can associate an open port with a commonly known service. This provides a starting point for deciding what to investigate next.

Port 23 is conventionally associated with Telnet, although port numbers alone do not guarantee which application is running. Service detection can help confirm the identification.

### 📝 Note — What even is Telnet?

Telnet is a network protocol that allows a client to establish a text-based session with a remote system.

In this lab, Telnet gives me a way to interact with the target's login prompt through my terminal.

A typical connection looks like this:

```bash
telnet 10.129.40.126
```

The command starts a Telnet client and attempts to connect to the target on TCP port 23 by default.

The target can then display a login prompt and request a username and password.

**Why is Telnet considered insecure?**

Traditional Telnet does not encrypt the session. Credentials and other transmitted data can be exposed to someone able to observe the network traffic.

For that reason, SSH is generally preferred for secure remote administration of Linux systems.

In this authorized HTB lab, Telnet is deliberately exposed so I can learn how service enumeration and weak access controls can lead to system access.

---

## 🟡 TASK 7 — Logging In Through Telnet

**❓ Question**

What username is able to log in to the target over Telnet with a blank password?

**✅ Answer**

`root`

**⚙️ Process — What I did and what happened**

**Step 1: I tried the browser.**

Because I was unsure how to interact with the target, I entered its IP address into Firefox.

The browser returned an error.

This happened because I was treating the target as though it were a website. A browser normally attempts to communicate using web protocols such as HTTP or HTTPS. The discovered service was Telnet, which requires a Telnet client rather than an ordinary browser.

**Step 2: I searched for the right approach.**

After searching online, I realized that I needed to connect from my terminal.

I ran:

```bash
telnet 10.129.40.126
```

The client attempted to establish a connection, and I saw the target's login prompt.

**Step 3: I tried some usernames and passwords.**

The target displayed a prompt similar to:

```text
Meow login:
```

I pressed Enter without providing a username, then tried `admin` when prompted for credentials.

That attempt did not work, and I was disconnected or returned to the login process.

**Step 4: I tried again with the correct username.**

I reconnected and learned that the expected username was `root`. I entered `root` at the login prompt and pressed Enter at the password prompt without typing a password.

The login succeeded.

I was then presented with a shell prompt resembling:

```text
root@meow:~#
```

**💡 Lesson — Why the earlier attempts failed**

There were three different issues in my process:

1. **Using Firefox was the wrong approach.** I had discovered a Telnet service, not a web service. I needed to use the appropriate client for the protocol.
2. **An empty username was not the same as an empty password.** The question specified a username that could log in with a blank password. The username still had to be supplied.
3. **`admin` was an unsupported guess.** The target expected `root`. A username that sounds plausible is not necessarily a valid account.

The failed login was useful feedback: I had to reconsider what the prompt was asking instead of continuing to guess.

I should also distinguish the error I observed from what I can prove. I did not preserve the exact Telnet error text, so I cannot reliably say whether the target rejected the credentials, closed the session, or timed out. My notes should record the exact message in future attempts.

### 🔐 What does `root` mean?

On Linux, `root` is the superuser account. It normally has unrestricted administrative privileges over the system.

Logging in as root means that I am operating with powerful permissions. A mistake at this level can affect the entire system.

### 🔐 What does a blank password mean?

A blank password means that the password field is empty. It does not mean the account has no username.

In this machine, the intended login uses the username `root` and an empty password. This is an insecure configuration and one of the key weaknesses demonstrated by the exercise.

**📝 Note — How do I recognize successful access?**

A prompt such as:

```text
root@meow:~#
```

is a strong indication that I have reached a shell as root on a host named `meow`.

The `#` symbol is commonly used for a privileged shell prompt, although prompt styles can be customized. I can confirm my identity with:

```bash
whoami
hostname
pwd
```

Expected results should identify the user as `root`, the host as `meow`, and the current working directory.

---

## 🔵 TASK 8 — Understanding the System Information

**❓ Question**

What is the output I saw after successfully logging in?

**📋 Observed information**

I saw a list containing entries similar to:

- Documentation
- Management
- Support
- System information
- System load
- Usage of `/`
- Memory usage
- Swap usage
- Processes
- Users logged in
- Last login

**✅ Answer**

This is system status information, commonly displayed through a login banner or the Message of the Day (MOTD) system.

**⚙️ Process**

After logging in successfully, the system displayed a summary of its status before I began exploring the filesystem.

**💡 Lesson**

The information is not a list of commands I need to execute. It is a summary of the machine's configuration, resource usage, and recent activity.

Here is what each item generally means:

| Item | Meaning |
|---|---|
| Documentation | Where to find system documentation or help |
| Management | Information or links related to system administration |
| Support | Support resources or contact information |
| System information | General details about the operating system or host |
| System load | An indication of the system's recent workload |
| Usage of `/` | Disk space used by the root filesystem |
| Memory usage | How much RAM is in use |
| Swap usage | How much swap space is being used |
| Processes | Information about running processes |
| Users logged in | Accounts currently logged in |
| Last login | Information about a previous login session |

The exact contents depend on the operating system and its configuration. A Linux MOTD may be assembled from multiple scripts and system utilities.

**📝 Note — Why is this useful in cybersecurity?**

System information can provide useful context during an assessment. It may reveal the operating system, host details, resource constraints, logged-in users, or other clues.

However, not every login banner reveals sensitive information, and its contents should be treated as clues rather than proof of a vulnerability.

---

## 🏁 TASK 9 — Retrieving the Flag

**❓ Question**

Submit the flag.

**✅ Answer**

The flag I recorded in my original notes was:

`b4038dhaklfj38dk`

**⚙️ Process**

After successfully logging in, I saw the root shell prompt:

```text
root@meow:~#
```

I ran:

```bash
ls
```

The output showed `flag.txt` and `snap`.

I then read the flag file:

```bash
cat flag.txt
```

The command printed the file's contents, which I used for the flag submission.

**💡 Lesson**

This was the final step of the machine. I had established network connectivity, discovered an exposed service, identified the correct login, and obtained access to the filesystem.

The commands served different purposes:

- `ls` lists directory contents.
- `cat flag.txt` prints the contents of the file.
- The flag is the evidence that the task was completed.

I should avoid assuming that every directory contains a flag or that every machine will allow direct root access. This was the intended path for this particular beginner exercise.

**📝 Note — Verify the recorded flag**

The value in my original notes may contain a transcription error. Before treating it as the verified flag, I should compare it with the exact value printed by `cat flag.txt` and the value accepted by HTB.

For future reports, I should record whether the flag was actually accepted by the platform, rather than relying solely on memory.

---

# 📚 03. Overall Lessons and Reflection

## 🧠 What I learned technically

1. A virtual machine provides an environment in which I can practice against a target without using my everyday computer as the target.
2. A terminal gives me access to a command-line interface, and a shell interprets the commands I enter.
3. OpenVPN provides a way to connect to HTB's lab network.
4. `ping` can help test connectivity, but a failed ping is not conclusive proof that a host is unreachable.
5. Nmap helps identify open ports and provides clues about the services running on a target.
6. TCP port 23 is conventionally associated with Telnet.
7. Telnet provides a text-based remote session but does not encrypt traditional Telnet traffic.
8. An account with an empty password can represent a serious security weakness.
9. The Linux `root` account has extensive privileges.
10. Linux commands such as `whoami`, `hostname`, `pwd`, `ls`, and `cat` help me understand my current environment and inspect files.

## 🧩 What I learned about my own problem-solving

The most valuable part of this exercise was noticing how I reacted when I became confused.

I initially struggled with a question I actually understood. I tried the browser when I needed a protocol-specific client. I guessed credentials before fully understanding the login prompt. In each case, slowing down and identifying what the system was asking me to do helped me move forward.

### My new troubleshooting rule

> 🛑 Stop → Read → Identify → Test → Observe → Adjust.

- **Stop:** Do not immediately guess.
- **Read:** Understand the question or error message.
- **Identify:** Determine which protocol, tool, or concept applies.
- **Test:** Run one appropriate command.
- **Observe:** Record the actual output.
- **Adjust:** Change the approach based on evidence.

## 🔁 What I would do differently next time

- Verify that the VPN is connected and test the target where appropriate.
- Record the target IP and the exact commands I run.
- Begin with an Nmap scan and preserve the results.
- Investigate the discovered service before choosing a client.
- Read login prompts carefully instead of guessing.
- Capture exact errors rather than describing them from memory.
- Verify the flag and platform completion status before marking the report complete.

## 📅 Review plan

- **Tomorrow:** Revisit the commands without reading the solution first.
- **In one week:** Explain the difference between VPN connectivity, host reachability, port scanning, and service identification.
- **In one month:** Repeat the workflow on another authorized beginner machine and compare the methodology.

The objective is not merely to remember answers. It is to make the reasoning repeatable.

---

# 🛠️ 04. Command Reference

| Purpose | Command |
|---|---|
| Connect to Telnet | `telnet TARGET_IP` |
| Test connectivity | `ping -c 4 TARGET_IP` |
| Scan common ports | `nmap TARGET_IP` |
| Scan all TCP ports | `nmap -p- TARGET_IP` |
| Identify service versions | `nmap -sV -p PORT TARGET_IP` |
| Check current user | `whoami` |
| Check hostname | `hostname` |
| Check current directory | `pwd` |
| List files | `ls` |
| Read a text file | `cat flag.txt` |

Replace `TARGET_IP` and `PORT` with the actual values for the assigned lab target.

---

# 🗃️ 05. Suggested FieldKit Location

Following the existing FieldKit documentation structure, I would store this report at:

```text
documentation/
└── hackthebox/
    └── meow/
        ├── README.md
        ├── notes/
        ├── evidence/
        └── lessons-learned.md
```

For this first machine, the main walkthrough can live in `README.md`, with screenshots or terminal output in `evidence/` and a shorter review checklist in `lessons-learned.md`. There is no need to split the report into multiple files until the collection grows.

---

# 💭 06. My Assessment

**The real achievement was not getting root. It was recovering when you got confused.**

Meow is intentionally simple, so completing it is a starting point rather than a measure of your overall cybersecurity ability. The important thing is that you recognized gaps in your understanding and worked through them.

My strongest recommendation is to preserve the mistakes alongside the successful commands. When you revisit this report later, those mistakes will help you recognize the same situations faster.

One technical habit I would especially reinforce is evidence-based troubleshooting. Do not assume that a connected VPN means the target is reachable, that a port number proves a service's identity, or that a failed login means the whole connection is broken. Observe the actual output and narrow down the problem.

**Final takeaway:** Meow taught you the basic flow of a penetration-testing exercise, but your documentation habit is what can turn that experience into lasting knowledge.

*Machine status: Completed in your notes. Confirm the exact flag and HTB submission status before considering every recorded detail verified.*
