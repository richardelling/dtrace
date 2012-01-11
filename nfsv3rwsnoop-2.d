#!/usr/sbin/dtrace -s 
#pragma D option quiet 
#pragma D option switchrate=10hz 
dtrace:::BEGIN 
{ 
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", 
        "time(us)", "time", 
        "client", "r/w", "offset", "end", "bytes", 
        "4K-aligned", "4K-size", "filename");
} 
nfsv3:::op-read-start 
{ 
    printf("%d\t%Y\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%s\n", 
        timestamp / 1000, walltimestamp,
        args[0]->ci_remote, "R", args[2]->offset,
        args[2]->offset + args[2]->count,
        args[2]->count,
        (args[2]->offset % 4096) == 0 ? "1" : "0",
        (args[2]->count % 4096) == 0 ? "1" : "0",
        args[1]->noi_curpath);
} 
nfsv3:::op-write-start 
{ 
    printf("%d\t%Y\t%s\t%s\t%d\t%d\t%d\t%s\t%s\t%s\n", 
        timestamp / 1000, walltimestamp,
        args[0]->ci_remote, "W", args[2]->offset, 
        args[2]->offset + args[2]->data.data_len,
        args[2]->data.data_len,
        (args[2]->offset % 4096) == 0 ? "1" : "0",
        (args[2]->data.data_len % 4096) == 0 ? "1" : "0",
        args[1]->noi_curpath); 
} 

