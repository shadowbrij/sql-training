1. Restart SQL Server
2. Setup perfmon to look at Total and Target Server Memory
3. Load up find_the_leak_dmvs.sql and 
4. Run confmaxmem.cmd to lower the target to 512Mb
5. Load find_the_leak_dmvs.sql and clock_hands_dmvs.sql
6. Run leakme.cmd
7. Observe perfmon counters target and totals. 
8. Observe in our command window. In about 10-15 seconds notice 00M errors
9. Let's look at ERRORLOG. What clerks have the highest Pages Allocated?
10. Go through results of find_the_leak_dmvs.sql
11. What is the highest memory object user? Cursors
12. What about clock_hands_dmvs.sql results?
13. Show the script for leakme.cmd and leakme.sql. TIP: The trace flags for ostress are to tell it NOT to close orphaned cursors
close orphaned cursors as it is designed by default to do so.
14. Reset max memory by running resetmaxmem.cmd and restarting SQL Server