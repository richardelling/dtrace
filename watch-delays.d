#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
{
    printf("Watching for delays... Hit Ctrl-C to end.\n");
}

fbt:genunix:delay:entry,
fbt:zfs:txg_delay:entry,
fbt:rpcmod:clnt_delay:entry
{
	printf("%Y %s\n", walltimestamp, probefunc); 
    @[probefunc, stack()]=count();
}
