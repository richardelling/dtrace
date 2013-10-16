#!/usr/sbin/dtrace -Cs

/*
 * Look at I/Os and show their distributions.
 * For devices taking more than 1ms, show them as slow devices
 * Richard.Elling@RichardElling.com 
 */

#pragma D option quiet

dtrace:::BEGIN
{
        printf("Tracing... Hit Ctrl-C to end.\n");
}

io:::start
{
        start_time[arg0] = timestamp;
}

io:::done
/(this->start = start_time[arg0]) && (timestamp - this->start) > 1000000000/
{
        @devs["slow devs", args[1]->dev_pathname] = count();
}

io:::done
/(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/
{
        this->delta = (timestamp - this->start) / 1000;
        @plots["read I/O, us"] = quantize(this->delta);
        @avgs["average read I/O, us"] = avg(this->delta);
        start_time[arg0] = 0;
}

io:::done
/!(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/
{
        this->delta = (timestamp - this->start) / 1000;
        @plots["write I/O, us"] = quantize(this->delta);
        @avgs["average write I/O, us"] = avg(this->delta);
        start_time[arg0] = 0;
}

profile:::tick-10sec,
dtrace:::END
{
        printf("%Y\n", walltimestamp);
        printa("   %s\n%@d\n", @plots);
        printa(@avgs);
        printa(@devs);
        trunc(@plots); trunc(@avgs); trunc(@devs)
}
