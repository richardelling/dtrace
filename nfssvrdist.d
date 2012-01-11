#!/usr/sbin/dtrace -s

#pragma D option quiet

nfsv3:nfssrv::op-commit-start,
nfsv3:nfssrv::op-read-start,
nfsv3:nfssrv::op-write-start,
nfsv4:nfssrv::op-commit-start,
nfsv4:nfssrv::op-read-start,
nfsv4:nfssrv::op-write-start
{
    this->ts = timestamp;
}

nfsv3:nfssrv::op-commit-start,
nfsv3:nfssrv::op-read-start,
nfsv4:nfssrv::op-commit-start,
nfsv4:nfssrv::op-read-start
{
    this->len = args[2]->count;
}

nfsv3:nfssrv::op-write-start
{
    this->len = args[2]->data.data_len;
}

nfsv4:nfssrv::op-write-start
{
    this->len = args[2]->data_len;
}

nfsv3:nfssrv::op-commit-done,
nfsv3:nfssrv::op-read-done,
nfsv3:nfssrv::op-write-done,
nfsv4:nfssrv::op-commit-done,
nfsv4:nfssrv::op-read-done,
nfsv4:nfssrv::op-write-done
/this->ts > 0/
{
    this->d = (timestamp - this->ts) / 1000;
    this->bdp = this->d * this->len;
    @plots[probefunc, "us"] = quantize(this->d);
    @plots[probefunc, "bytes"] = quantize(this->len);
    @plots[probefunc, "us*bytes"] = quantize(this->bdp);
    @avgs[probefunc, "us"] = avg(this->d);
    @avgs[probefunc, "bytes"] = avg(this->len);
    @avgs[probefunc, "us*bytes"] = avg(this->bdp);
    this->len = 0;
    this->ts = 0;
}

profile:::tick-10sec,
dtrace:::END
{
    printf("%Y\n", walltimestamp);
    printa("   %s (%s)\n%@d\n", @plots);
    printa("%s (%s) average %@d\n", @avgs);
    trunc(@plots); trunc(@avgs);
}
