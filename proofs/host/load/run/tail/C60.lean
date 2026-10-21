import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1920
host_chunk_read_tail_eager P 1921
host_chunk_read_tail_eager P 1922
host_chunk_read_tail_eager P 1923
host_chunk_read_tail_eager P 1924
host_chunk_read_tail_eager P 1925
host_chunk_read_tail_eager P 1926
host_chunk_read_tail_eager P 1927
host_chunk_read_tail_eager P 1928
host_chunk_read_tail_eager P 1929
host_chunk_read_tail_eager P 1930
host_chunk_read_tail_eager P 1931
host_chunk_read_tail_eager P 1932
host_chunk_read_tail_eager P 1933
host_chunk_read_tail_eager P 1934
host_chunk_read_tail_eager P 1935
host_chunk_read_tail_eager P 1936
host_chunk_read_tail_eager P 1937
host_chunk_read_tail_eager P 1938
host_chunk_read_tail_eager P 1939
host_chunk_read_tail_eager P 1940
host_chunk_read_tail_eager P 1941
host_chunk_read_tail_eager P 1942
host_chunk_read_tail_eager P 1943
host_chunk_read_tail_eager P 1944
host_chunk_read_tail_eager P 1945
host_chunk_read_tail_eager P 1946
host_chunk_read_tail_eager P 1947
host_chunk_read_tail_eager P 1948
host_chunk_read_tail_eager P 1949
host_chunk_read_tail_eager P 1950
host_chunk_read_tail_eager P 1951

/- Chunks 1920 … 1951: boundary 1920 to boundary 1952 for every unread suffix. -/
tail_compose P P.tailGroup60 :=
  P.tac1920 P.tac1921 P.tac1922 P.tac1923 P.tac1924 P.tac1925 P.tac1926 P.tac1927
  P.tac1928 P.tac1929 P.tac1930 P.tac1931 P.tac1932 P.tac1933 P.tac1934 P.tac1935
  P.tac1936 P.tac1937 P.tac1938 P.tac1939 P.tac1940 P.tac1941 P.tac1942 P.tac1943
  P.tac1944 P.tac1945 P.tac1946 P.tac1947 P.tac1948 P.tac1949 P.tac1950 P.tac1951

end Host.Load.Run.Full
