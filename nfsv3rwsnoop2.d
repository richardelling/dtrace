#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
	printf("%-16s %-18s %2s %-10s %-10s %6s %s\n", "TIME(us)",
	    "CLIENT", "OP", "OFFSET", "END", "BYTES", "PATHNAME");
}

nfsv3:::op-read-start
{
	printf("%-16d %-18s %2s %-10d %-10d %6d %s\n", timestamp / 1000,
	    args[0]->ci_remote, "R", args[2]->offset,
        args[2]->offset + args[2]->data.data_len,
	    args[2]->count, args[1]->noi_curpath);
}

nfsv3:::op-write-start
{
	printf("%-16d %-18s %2s %-10d %-10d %6d %s\n", timestamp / 1000,
	    args[0]->ci_remote, "W", args[2]->offset,
        args[2]->offset + args[2]->data.data_len,
	    args[2]->data.data_len, args[1]->noi_curpath);
}
