# BPF

https://github.com/bpftools/linux-observability-with-bpf

## Running first BPF program

### Setup

```
sudo apt update
sudo apt install build-essential git make libelf-dev clang strace tar bpfcc-tools linux-headers-$(uname -r) gcc-multilib
cd /tmp
git clone --depth 1 git://kernel.ubuntu.com/ubuntu/ubuntu-focal.git
sudo mv ubuntu-focal /kernel-src
cd /kernel-src/tools/lib/bpf
sudo make && sudo make install prefix=/usr/local
sudo mv /usr/local/lib64/libbpf.* /lib/x86_64-linux-gnu/
```

Install Ubuntu kernel source:
```
echo "deb-src http://archive.ubuntu.com/ubuntu focal main" | tee -a /etc/apt/sources.list
echo "deb-src http://archive.ubuntu.com/ubuntu focal-updates main" | tee -a /etc/apt/sources.list
sudo apt update
#sudo apt build-dep linux linux-image-$(uname -r)
#sudo apt install libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
sudo apt install linux-source -y
cp /usr/src/linux-source-*.tar.bz2 /tmp
tar jxf /tmp/linux-source-*.tar.bz2
sudo mv /tmp/linux-source-5.4.0 /kernel-src
```

### Steps

The kernel uses syscall `bpf` to load programs into BPF VM.

Triggering bpf programs with tracepoint:
```
SEC("tracepoint/syscalls/sys_enter_execve")
```

List all kernel tracepoints:
```
sudo perf list | grep Tracepoint
```

Kernel tracing log location:
```
/sys/kernel/debug/tracing/trace_pipe
```

Compile with clang:
```
clang -O2 -target bpf -c hello.c -o hello.o
```

Disassembles BPF program:
```
llvm-objdump -S -no-show-raw-insn bpf_program.o
```