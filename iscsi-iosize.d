#!/usr/sbin/dtrace -qs
dtrace:::BEGIN
{
	printf("iSCSI I/O size by client and read/write operations\n");
}
iscsi:::xfer-start
{
	@[args[0]->ci_remote,arg8 ? "R" : "W"]=quantize(args[2]->xfer_len)
}
profile:::tick-10sec
{
	printf("%Y\n", walltimestamp);
	printa(@);
	trunc(@);
}

