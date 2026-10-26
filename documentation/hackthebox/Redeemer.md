# 🔴 REDEEMER — HTB Starting Point

**Machine:** #004 — Day 04  
**Difficulty:** Very Easy  
**Platform:** Hack The Box — Starting Point  
**Operating System:** Linux  
**Target IP:** `10.129.52.206`

**Tags:** `#HTB` `#VeryEasy` `#Redis` `#Nmap` `#Port6379` `#Databases` `#Linux` `#Enumeration`

---

## 🎯 Objective

Discover the open Redis service, connect to the remote server using the Redis command-line client, investigate the database, identify its keys, and retrieve the flag.

## 🧰 Tools Used

- **Nmap** — Port scanning and service detection.
- **redis-cli** — Connecting to and interacting with Redis.
- **Redis commands** — `INFO`, `SELECT`, `KEYS`, and `GET`.
- **Linux terminal** — Checking installed commands and reading files.
- **Google** — Researching unfamiliar tools and troubleshooting errors.

---

# 📝 TASKS & SOLUTIONS

## Task 1 — Discovering the Open Port

**Question:** Which TCP port is open on the machine?

**Answer:** `6379`

### 🔍 Process

The first thing I did after the machine started was ping the target:

```bash
ping 10.129.52.206
```

I wanted to confirm that I could reach the target, and I received a response.

Next, I tried running two Nmap scans:

```bash
sudo nmap -p- -T4 10.129.52.206
```

And:

```bash
sudo nmap -sV -T4 10.129.52.206
```

The first command took a long time, so I interrupted it. The second returned:

```text
All 1000 scanned ports on 10.129.52.206
are in ignored states.
```

I didn't understand what was happening, so I searched online and found this command:

```bash
sudo nmap -sSCV 10.129.52.206 -p- --min-rate=1000 -oA redeemer-nmap
```

This scan eventually returned:

```text
Warning: 10.129.52.206 giving up on port because
retransmission cap hit (10).

Nmap scan report for 10.129.52.206
Host is up (0.44s latency).
Not shown: 65534 closed tcp ports (reset)

PORT     STATE SERVICE VERSION
6379/tcp open  redis   Redis key-value store
```

I found the answer: port `6379`. But I still didn't understand why my original commands had failed.

### 📚 Lesson — What happened to Nmap?

Nothing was necessarily wrong with Nmap. The important difference was **which ports each scan checked**.

My second command was:

```bash
sudo nmap -sV -T4 10.129.52.206
```

By default, Nmap scans a list of its 1,000 most commonly used ports when you don't specify a port range. Port `6379` isn't included in that default list, so the scan could miss Redis entirely.

My first command included:

```bash
-p-
```

This tells Nmap to scan all 65,535 TCP ports. However, scanning every port takes more time than checking the default selection, especially when the target has network latency.

The successful command combined several options:

| Option | Meaning |
|---|---|
| `-sS` | Perform a TCP SYN scan |
| `-sC` | Run Nmap's default set of scripts |
| `-sV` | Probe services to identify their versions |
| `-p-` | Scan all TCP ports, 1–65535 |
| `--min-rate=1000` | Ask Nmap to maintain a minimum sending rate of 1,000 packets per second, subject to practical limits |
| `-oA redeemer-nmap` | Save output in three formats using the specified filename prefix |

The combined scan option `-sSCV` is shorthand for using `-sS`, `-sC`, and `-sV` together.

### 💭 Note — What did “all 1000 scanned ports are in ignored states” mean?

Nmap had scanned its default 1,000 ports, but none produced a result that it needed to display individually. In this situation, the ports were in states such as `closed` or `filtered`, which Nmap summarizes rather than listing one by one.

It did **not** mean the target had no open ports anywhere. It meant the scan hadn't found an open port among the ports it checked.

The Redis port was outside that default selection, which explains why scanning all ports revealed it.

### 💭 Note — What about the retransmission warning?

The warning:

```text
giving up on port because retransmission cap hit (10)
```

means Nmap stopped retrying a probe after reaching its retransmission limit for that port. Network delay, packet loss, or filtering can contribute to retransmissions.

This warning does not automatically invalidate the entire scan. However, it is a reason to examine the results carefully if a port is important or the scan appears incomplete.

**Lesson:** A fast scan is useful, but a fast scan that misses the port you need isn't useful. Start with a sensible scan, expand to all ports when necessary, and interpret the output before drawing conclusions.

---

## Task 2 — Identifying the Service

**Question:** Which service is running on the port that is open on the machine?

**Answer:** `redis`

### 🔍 Process

I found the answer in the output of my successful Nmap scan:

```text
PORT     STATE SERVICE VERSION
6379/tcp open  redis   Redis key-value store
```

The service column said `redis`, so I entered that as my answer.

### 📚 Lesson

Nmap doesn't just tell us whether a port is open. With service detection enabled, it can also probe the service to identify what is listening on that port.

In this scan:

- `6379/tcp` identifies the port and protocol.
- `open` means a service accepted the TCP connection.
- `redis` is the identified service.
- `Redis key-value store` describes the type of service.

The port number is a useful clue, but the service-detection result gives us stronger evidence about what is running.

---

## Task 3 — Understanding Redis

**Question:** What type of database is Redis? Choose from the following options: (i) In-memory Database, (ii) Traditional Database.

**Answer:** `In-memory Database`

### 🔍 Process

I answered this using what I remembered from previous learning. I knew Redis was an in-memory database, but I didn't really understand what Redis was or how it worked.

### 📚 Lesson — What even is Redis?

Redis is a data store that primarily keeps data in memory, meaning it uses RAM to store and access data quickly.

It is commonly used for:

- Caching frequently requested information.
- Session storage.
- Counters and statistics.
- Queues and other data structures.
- Applications that need fast data access.

A traditional disk-based database often relies heavily on persistent storage for its data. Redis is designed around fast in-memory operations, although it can also save data to disk through persistence mechanisms.

The important distinction is that **in-memory does not necessarily mean the data disappears whenever the server restarts**. Redis can be configured to persist data to disk, depending on its settings.

### 💭 Note — What is a key-value database?

Redis stores data using keys to identify values.

Imagine a small digital filing cabinet:

| Key | Value |
|---|---|
| `username` | `alex` |
| `temperature` | `24` |
| `flag` | A flag string |

The key is the identifier. The value is the data associated with it.

When an application wants the value associated with `username`, it can ask Redis to retrieve that key. This model is central to understanding the rest of Redeemer.

---

## Task 4 — Finding the Redis Command-Line Utility

**Question:** Which command-line utility is used to interact with the Redis server? Enter the program name you would enter into the terminal without any arguments.

**Answer:** `redis-cli`

### 🔍 Process

I started by checking for a command called `redis`:

```bash
which redis
```

There was no output, so I installed Redis-related software and tried again. Still no output.

Then I tried:

```bash
redis --version
```

That didn't work either.

I looked back at the installation instructions and noticed the command `redis-server`. I checked it:

```bash
which redis-server
redis-server --version
```

This time, I got output.

I then tried:

```bash
sudo redis-server 10.129.52.206
```

The terminal returned an error saying it couldn't open a configuration file at:

```text
/home/user1/10.129.52.206
```

I searched online and discovered that the utility I actually needed was `redis-cli`.

However, when I tried:

```bash
sudo redis-cli 10.129.52.206
```

I received:

```text
(error) ERR unknown command '10.129.52.206',
with args beginning with:
```

At this point, I still didn't understand the difference between the two Redis programs.

### 📚 Lesson — `redis-server` versus `redis-cli`

These are two different programs with different jobs.

**`redis-server`** starts a Redis server. It accepts configuration options or a configuration file. When I supplied the IP address as a positional argument, Redis interpreted it as the path to a configuration file rather than as the address of a remote server.

That's why it tried to open:

```text
/home/user1/10.129.52.206
```

**`redis-cli`** is the command-line client used to connect to a Redis server and issue Redis commands.

A useful comparison:

| Program | Purpose |
|---|---|
| `redis-server` | Run a Redis server |
| `redis-cli` | Connect to a Redis server and interact with it |

### 💭 Note — Why did `redis-cli 10.129.52.206` fail?

Because the client did not interpret the bare IP address as the hostname argument.

Without the correct option, `redis-cli` can interpret a positional argument as a Redis command to execute. The server then received `10.129.52.206` as though it were a command name and rejected it.

The next task introduces the option that fixes this.

---

## Task 5 — Specifying the Hostname

**Question:** Which flag is used with the Redis command-line utility to specify the hostname?

**Answer:** `-h`

### 🔍 Process

I read the question and noticed the word *hostname*. I guessed that `-h` was the answer.

I then tried:

```bash
redis-cli -h 10.129.52.206
```

This time, I was connected to the remote Redis service. My prompt changed to:

```text
10.129.52.206:6379>
```

That was the first time I had successfully interacted with Redis.

### 📚 Lesson — What just happened?

The `-h` option tells `redis-cli` which host to connect to.

```bash
redis-cli -h 10.129.52.206
```

The client connected to the Redis server running at that address. Because Redis uses TCP port `6379` by default, I didn't need to specify the port explicitly.

If I needed a different port, I could use `-p`:

```bash
redis-cli -h 10.129.52.206 -p 6379
```

The prompt:

```text
10.129.52.206:6379>
```

shows that I am now interacting with the Redis server at that address and port.

**Important distinction:** This is no longer an ordinary Linux shell. I am inside the Redis command-line interface, where I enter Redis commands.

---

## Task 6 — Getting Server Information

**Question:** Once connected to a Redis server, which command is used to obtain the information and statistics about the Redis server?

**Answer:** `INFO`

### 🔍 Process

I entered:

```text
ls
```

I got an error:

```text
(error) ERR unknown command `ls`, with args beginning with:
```

That confused me because `ls` is a command I use all the time in Linux.

Then I entered:

```text
INFO
```

Redis returned a large amount of information divided into sections:

```text
# Server
# Clients
# Memory
# Persistence
# Stats
# Replication
# CPU
# Cluster
# Keyspace
```

Each section contained its own collection of details.

### 📚 Lesson — Why did `ls` fail?

Because I was no longer in my Linux terminal. I was inside the Redis CLI.

The `ls` command belongs to a regular shell such as Bash. Redis expects Redis commands, so it treated `ls` as an unknown Redis command.

This is a very important concept when using command-line tools: **the prompt tells you which environment you are operating in**.

For example:

```text
user1@computer:~$
```

usually indicates a Linux shell, while:

```text
10.129.52.206:6379>
```

indicates a Redis CLI session.

### 📚 Lesson — What does `INFO` do?

`INFO` returns information about the Redis server and its current state. Depending on the server version, the output can contain sections such as:

| Section | What it tells you |
|---|---|
| `Server` | Version, operating details, and server uptime |
| `Clients` | Information about connected clients |
| `Memory` | Memory usage and related statistics |
| `Persistence` | Information about saving data and persistence |
| `Stats` | General server activity and counters |
| `Replication` | Replication configuration and status |
| `CPU` | CPU usage statistics |
| `Cluster` | Cluster-related details, where applicable |
| `Keyspace` | Summary information about the logical databases and their keys |

The exact output depends on the Redis version and configuration.

You can also request a specific section:

```text
INFO server
INFO memory
INFO keyspace
```

This makes it easier to find the information you need without reading the entire report.

---

## Task 7 — Identifying the Redis Version

**Question:** What is the version of the Redis server being used on the target machine?

**Answer:** `5.0.7`

### 🔍 Process

I returned to my Nmap scan and looked at the service-detection output. It said:

```text
6379/tcp open redis Redis key-value store
```

But that didn't include a version number, so I didn't understand how to find `5.0.7`.

I then tried checking the version with a Redis server command on my own machine, but that didn't tell me the version running on the target.

Eventually, I searched online and found the answer, but I still wanted to know where it came from.

### 📚 Lesson — Local version versus remote version

Running:

```bash
redis-server --version
```

checks the version of the Redis server executable installed on **my own machine**.

It does not automatically tell me which version is running on a remote server.

For this task, I was interested in the Redis server at `10.129.52.206`. Since I was already connected through `redis-cli`, I could query the remote server directly:

```text
INFO server
```

The output includes a field like:

```text
redis_version:5.0.7
```

That field identifies the version of the Redis server responding to the request.

Nmap's `-sV` can also identify service versions when its probes obtain enough information. In my scan, the output identified Redis but did not display a specific version, so querying the server's information was a useful next step.

**Lesson:** Always distinguish between the software installed locally and the software running on the target.

---

## Task 8 — Selecting a Redis Database

**Question:** Which command is used to select the desired database in Redis?

**Answer:** `SELECT`

### 🔍 Process

I read the question carefully and realized the command was probably `SELECT`. To test it, I typed:

```text
SELECT memory
```

Redis returned:

```text
(error) ERR invalid DB index
```

I knew the command was recognized, but I didn't understand why it rejected the argument.

### 📚 Lesson — What does `SELECT` do?

Redis can contain multiple logical databases, identified by numeric indexes. The `SELECT` command changes which logical database the current connection uses.

For example:

```text
SELECT 0
```

selects database index `0`.

```text
SELECT 1
```

selects database index `1`, if that database index is supported by the server's configuration.

The argument must be a valid database index, not a descriptive word such as `memory`. That's why my command returned an invalid database index error.

Redis commonly starts a client session in database `0`, so it is often the default database.

### 💭 Note — Why have multiple databases?

Logical databases let one Redis server separate keys into different numbered spaces. For example, a developer might use one database for a test environment and another for a different purpose.

However, separate logical databases are not the same as separate Redis servers, and they are not a strong security boundary. The actual use of logical databases depends on the application and server configuration.

For Redeemer, database `0` is the one we investigate.

---

## Task 9 — Counting Keys in Database 0

**Question:** How many keys are present inside the database with index 0?

**Answer:** `4`

### 🔍 Process

When I ran `INFO` earlier, I noticed a section called `Keyspace`. It contained:

```text
db0:keys=4,expires=0,avg_ttl=0
```

I read that output and concluded that database `0` contained four keys. That was the answer.

### 📚 Lesson — What are keys?

A Redis key is an identifier used to access a stored value.

Think of a key like the label on a box. The key tells Redis which stored value you want.

For example:

```text
username  → alex
temperature → 24
flag      → some_flag_value
```

The key is the name on the left; the value is the information associated with it.

### 📚 Lesson — Understanding the `Keyspace` output

This line:

```text
db0:keys=4,expires=0,avg_ttl=0
```

means:

- `db0` — Logical database index 0.
- `keys=4` — Four keys are present in that database.
- `expires=0` — None of those keys currently has an expiration set.
- `avg_ttl=0` — There is no positive average remaining expiration time to report because no keys have an expiration set.

This information is a summary. It tells us how many keys exist, but it does not list the names of those keys or show their values.

To discover the actual key names, we need another command.

---

## Task 10 — Listing Keys

**Question:** Which command is used to obtain all the keys in a database?

**Answer:** `KEYS *`

### 🔍 Process

I initially tried to work the answer out myself by using:

```bash
redis-server -h
```

and:

```bash
man redis-server
```

But I found the output confusing. I wasn't sure whether the answer was there or whether I simply didn't know how to locate it.

Eventually, I searched online and found:

```text
KEYS *
```

I understood that this was the answer, but I still wanted to know why the command looked like that.

### 📚 Lesson — Breaking down `KEYS *`

The command consists of two parts:

- `KEYS` — Requests keys whose names match a specified pattern.
- `*` — A wildcard pattern that matches any sequence of characters, including an empty sequence.

Together:

```text
KEYS *
```

asks Redis to return all key names in the currently selected database.

For example, Redis might return:

```text
1) "numb"
2) "temp"
3) "stor"
4) "flag"
```

Those are the names of the keys. They are not their stored values.

### 💭 Note — Why didn't `man redis-server` help?

`man redis-server` opens the manual page for the Redis server program. It is primarily about starting and configuring the server, not about every command available inside the Redis CLI.

I was searching in the wrong place for the information I needed.

A useful distinction:

- Linux manual pages explain local programs and their options.
- `redis-cli --help` explains how to use the Redis client program.
- Redis commands such as `INFO`, `SELECT`, `KEYS`, and `GET` are entered after connecting to the Redis server.

For this authorized lab, `KEYS *` is useful for discovering all the key names. In production Redis deployments, however, `KEYS *` can block the server while scanning a large keyspace, so `SCAN` is often preferred for incremental exploration.

---

## Task 11 — Retrieving the Flag

**Question:** Submit the flag located in the database.

**Answer:** `03e1d2b376c37ab3f5319922053953eb`

### 🔍 Process

I ran the key-listing command but initially forgot the `s` and typed:

```text
key *
```

That returned an error because `KEY` wasn't the correct command.

I corrected it to:

```text
KEYS *
```

Redis returned:

```text
1) "numb"
2) "temp"
3) "stor"
4) "flag"
```

I could see the key named `flag`, so I tried entering `4`, thinking that might retrieve it. That didn't work either.

I searched online and found the missing step: I needed to use `GET flag`.

I entered:

```text
GET flag
```

Redis returned the flag:

```text
03e1d2b376c37ab3f5319922053953eb
```

### 📚 Lesson — A key name is not the value

This was the final piece of the Redis puzzle.

`KEYS *` lists the names of the keys. It does not automatically display their associated values.

When Redis returned:

```text
4) "flag"
```

the `4)` was just the fourth item in the output. It wasn't a command or an instruction to enter the number `4`.

The actual key name was `flag`.

To retrieve the value associated with that key, I used:

```text
GET flag
```

The general pattern is:

```text
GET key_name
```

For example:

```text
GET username
GET temp
GET flag
```

The key must exist, and `GET` is appropriate when the key stores a string value.

**The workflow was:**

1. `INFO` — Inspect the server and learn about the keyspace.
2. `KEYS *` — Discover the names of the keys.
3. `GET flag` — Retrieve the value stored under the key named `flag`.

That is how I retrieved the flag.

---

# 🧠 OVERALL LESSONS

## 1. Port scanning depends on the ports you ask Nmap to check

My initial service scan didn't find Redis because it checked Nmap's default selection of 1,000 common ports. Redis was listening on TCP port `6379`, which I discovered after scanning all TCP ports.

## 2. Learn the difference between a server and a client

- `redis-server` runs the server.
- `redis-cli` connects to a server and sends commands.

Trying to use a server program as if it were a client created unnecessary confusion.

## 3. Every command-line environment has its own commands

`ls` is a Linux shell command, not a Redis command. Once I saw the Redis prompt, I needed to use Redis commands instead.

## 4. Read the output instead of guessing

The `INFO` output revealed the Redis version and the number of keys in database 0. Later, `KEYS *` revealed the names of those keys. Each command gave me a different piece of evidence.

## 5. Understand the relationship between keys and values

A key is the identifier. A value is the information stored under that identifier.

`KEYS *` helped me discover `flag`. `GET flag` retrieved the value associated with it.

## 6. Local information isn't necessarily remote information

Checking `redis-server --version` on my machine tells me about my local installation. To learn about the target, I needed to query the remote Redis server.

---

# 📖 COMMAND REFERENCE

## Nmap

```bash
# Check the target's responsiveness
ping 10.129.52.206

# Scan Nmap's default selection of common ports
sudo nmap -sV -T4 10.129.52.206

# Scan all TCP ports
sudo nmap -p- -T4 10.129.52.206

# Scan all TCP ports, detect services, run default scripts,
# and save results in three formats
sudo nmap -sSCV 10.129.52.206 -p- --min-rate=1000 -oA redeemer-nmap
```

## Check the local Redis installation

```bash
# Check whether the programs are available
command -v redis-cli
command -v redis-server

# Check the local program version
redis-server --version

# Display Redis CLI usage information
redis-cli --help
```

## Connect to the remote Redis server

```bash
redis-cli -h 10.129.52.206
```

If a different port is required:

```bash
redis-cli -h 10.129.52.206 -p 6379
```

## Redis commands

Enter these after connecting to Redis:

```text
INFO
INFO server
INFO keyspace

SELECT 0

KEYS *

GET flag

QUIT
```

### What each command does

| Command | Purpose |
|---|---|
| `INFO` | Display server information and statistics |
| `INFO server` | Display server-specific information, including version |
| `INFO keyspace` | Display database keyspace summaries |
| `SELECT 0` | Switch to logical database 0 |
| `KEYS *` | List keys matching the wildcard pattern |
| `GET flag` | Retrieve the value stored under `flag` |
| `QUIT` | Close the Redis client connection |

---

# 🔁 REVIEW PLAN

## Tomorrow — recall without looking

1. Which port was open on Redeemer?
2. Why did the default Nmap scan miss Redis?
3. What does `-p-` do?
4. What is the difference between `redis-server` and `redis-cli`?
5. What does the `-h` option specify?
6. Why did `ls` fail inside Redis?
7. Which `INFO` section summarizes the number of keys?
8. What does `SELECT 0` do?
9. What does `KEYS *` return?
10. Why did `GET flag` retrieve the flag when entering `4` did not?

## Later — repeat the workflow

Using an authorized lab environment, practice the sequence:

1. Discover the target's open ports.
2. Identify the service running on the discovered port.
3. Connect with the appropriate client.
4. Inspect the service's information.
5. Identify the database and its keys.
6. Retrieve a value using its key name.

Try to explain why each command is necessary instead of memorizing the sequence alone.

---

# 💭 PERSONAL REFLECTION

Redeemer felt overwhelming because it introduced a completely new tool and a new way of interacting with data.

I had several moments where I thought I was doing the right thing, but I was using the wrong program or entering commands in the wrong environment. I also struggled to understand why the output showed key names instead of giving me the flag immediately.

However, I eventually connected the pieces: Nmap discovered Redis, `redis-cli` connected to the service, `INFO` gave me information about the server, `KEYS *` listed the keys, and `GET flag` retrieved the value.

I relied on Google several times, but I also used the questions and command output to work out some answers independently. That is progress. The next step is to become more deliberate about troubleshooting before looking up a solution.

**The biggest lesson today: understanding what a command does is more valuable than remembering the command itself.**

---

# 🤖 MY ASSESSMENT

Redeemer introduced two major concepts: full-port service discovery and Redis database enumeration.

Your Nmap confusion is understandable. A default scan can miss a service simply because the service is listening on a port outside the default selection. Your Redis confusion was also understandable: a Redis CLI prompt looks nothing like a normal Linux terminal, and commands that are familiar in one environment may not exist in another.

The most important command sequence to remember from this machine is:

```text
INFO
KEYS *
GET flag
```

These commands answer three different questions:

- What information can I learn about this Redis server?
- Which keys are present in the selected database?
- What value is stored under the key named `flag`?

As the machines get harder, keep using the same approach: investigate, read the evidence, make a focused change, and test again. Don't measure progress by how little you Google. Measure it by how much more you understand after each machine.

**Day 04: Redeemer — completed. Another machine documented, another service understood a little better.**
