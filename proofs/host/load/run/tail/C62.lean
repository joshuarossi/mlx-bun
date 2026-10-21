import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1984
host_chunk_read_tail_eager P 1985
host_chunk_read_tail_eager P 1986
host_chunk_read_tail_eager P 1987
host_chunk_read_tail_eager P 1988
host_chunk_read_tail_eager P 1989
host_chunk_read_tail_eager P 1990
host_chunk_read_tail_eager P 1991
host_chunk_read_tail_eager P 1992
host_chunk_read_tail_eager P 1993
host_chunk_read_tail_eager P 1994
host_chunk_read_tail_eager P 1995
host_chunk_read_tail_eager P 1996
host_chunk_read_tail_eager P 1997
host_chunk_read_tail_eager P 1998
host_chunk_read_tail_eager P 1999
host_chunk_read_tail_eager P 2000
host_chunk_read_tail_eager P 2001
host_chunk_read_tail_eager P 2002
host_chunk_read_tail_eager P 2003
host_chunk_read_tail_eager P 2004
host_chunk_read_tail_eager P 2005
host_chunk_read_tail_eager P 2006
host_chunk_read_tail_eager P 2007
host_chunk_read_tail_eager P 2008
host_chunk_read_tail_eager P 2009
host_chunk_read_tail_eager P 2010
host_chunk_read_tail_eager P 2011
host_chunk_read_tail_eager P 2012
host_chunk_read_tail_eager P 2013
host_chunk_read_tail_eager P 2014
host_chunk_read_tail_eager P 2015

/- Chunks 1984 … 2015: boundary 1984 to boundary 2016 for every unread suffix. -/
tail_compose P P.tailGroup62 :=
  P.tac1984 P.tac1985 P.tac1986 P.tac1987 P.tac1988 P.tac1989 P.tac1990 P.tac1991
  P.tac1992 P.tac1993 P.tac1994 P.tac1995 P.tac1996 P.tac1997 P.tac1998 P.tac1999
  P.tac2000 P.tac2001 P.tac2002 P.tac2003 P.tac2004 P.tac2005 P.tac2006 P.tac2007
  P.tac2008 P.tac2009 P.tac2010 P.tac2011 P.tac2012 P.tac2013 P.tac2014 P.tac2015

end Host.Load.Run.Full
