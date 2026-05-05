# Lesson 13 Monitoring Activity
- 13.1 Exploring Jobs and Processes
- 13.2 Managing Shell Jobs
- 13.3 Understanding Process States
- 13.4 Observing Process Information with `ps`
- 13.5 Monitoring Memory Usage
- 13.6 Observing CPU load
- 13.7 Monitoring System Activity with `top`

## 13.1 Exploring Jobs and Proceses
- All tasks are started as processes
- Processses have a PID
- Common Process Management tasks include scheduling priority and sending signals
- Some processes are starting multiple threads, individual threads cannot be managed
- Shell jobs can be started in the foreground or background

## 13.2 Managing Shell Jobs
- Use `command  &` to start a job in the background
- To move a job to the background
    - First, stop it using `Ctrl-Z`
    - Next. type `bg` to move it to the background
- Use `jobs` for a complete overview of running jobs
- Use `fg [n]` to move the last job back to the foreground

## 13.3 Understanding Process States
### Understanding Runnable Process State
- When a new process is started (forked) it is scheduled and after being scheduled, it will get a runnable state (R)
    - In this state it is waiting in the queue to be scheduled
- Runnable processes will get a time slice, which allows them to get a running state, in either kernel space or user space
- Runnable processes can get preempted or rescheduled
    - In that case, they will return to a runnable state and wait in the queue for a new time slice
- A runnable process can be stopped (ctrl-z) and will show as TASK_STOPPED (T), and after being stopped it can receive another signal to resume and return to a runnable state

### Understanding Waiting Process State
- While running, the process may have to wait
    - This is also referred as "blocking" state, which is not an official state yet
- Waiting processes can have different flags
    - `TASK_INTERRUPTIBLE (S)`: the process is waiting for hardware request, system resource access or a signal
    - `TASK_UNINTERUPTIBLE (D)`: the process is waiting but does not respond to signals
    - `TASK_KILLABLE (K)`: the process is waiting by may be killed
    - `TASK_REPORT_IDLE (I)`: used for kernel threads, this process will not count for the load average

### Understanding Exit States
- When a process exits, it will briefly enter the EXIT_ZOMBIE (Z) state. This is where it signals the parent process that it exits and all resources except for the PID are released
- In the next state the process will enter the EXIT_DEAD (X) state. In this state it will be reaped and all remaining processes are cleaned up

### Understanding Zombies
- A process becomes a Zombie when it has completed its task, but the parent process hasn't collected its execution state
- Zombies are already dead so they can't and don't have to be killed
- The most import disadvantage is that Zombies occupy a PID
- To get rid of the Zombie, the parent process must collect the child execution status
    - Send `SIGCHLD` to the parent to ask the parent to reap the Zombie
    - Kill the parent process
    - When the parent is killed, the Zombie becomes an orphan and will be adopted by the init process

## 13.4 Observing Process Information with `ps`
### Using `ps`
- The `ps` command has two different dialects: BSD and System V
    - In BSD, options do not have a leading `-`
    - In System V, options do have a leading `-`
- Therefore `ps -L` and `ps L` are two different commands
- `ps` shows an overview of current processes
- Use `ps aux` for an overview of all processes

- `ps -fax` shows hierarchical relations between processes
- `ps -fU linda` shows all processes owned by linda
- `ps -d --forest -C sshd` shows a process tree for a specific process
- `ps L` shows format soecifiers
- `ps -eo pid,ppid,user,cmd` uses some of thesess specifiers to show a list of processes

## 13.5 Monitoring Memory Usage
- Linux places as many files as possible in cache to guarantee fast access to the files
- For that reason, Linux memory often shows as saturated
- Swap is used as an overflow buffer of emulated RAM on disk
- The Linux kernl moves inactive application memory to swap first
- Inactive cache memory will just be dropped
- Use `free -m` to get details about current memory usage
- More detailed memory information is in `/proc/meminfo`

### Understanding Write Cache
- While writing files, a write cache (buffers) is used
- This write cache is periodically committed to disk bu the `pdflush` kernel thread
- As a result, after committing a file write, it's not immediately secure
- To ensure that a file is commited to disk immediately, use `sync` command

## 13.6 Observing CPU Load
- CPU load is checked through `uptime`
- CPU load is expressed as the average number fo runnable processes over the last 1, 5 and 15 minutues
- As a rough guideline, this number should not exceed the number of CPU cores on a system
- Use `lscpu` to check the number of CPU cores

## Lesson 13 Lab: Observing Processes
- Use the appropriate utilities to find out if you machine performance is in good shape