-- L2_DeadlockDetectionExtendedEvents.sql
-- Deadlock detection using Extended Events
-- Summary: The above example first creates an event session on server to get xml_deadlock_report and saves it as a .xel file.  The session is then started and the Conversion Deadlock Scenario discussed in Lesson 1 is run to simulate a deadlock.  The event session saves the deadlock information captured at the specified location with .xel extension. The function sys.fn_xe_file_target_read_file is then used to get the xml format for the event captured. It takes four parameters, the xel file path, the corresponding Meta file path the initial_file_name which is the first file to read from (Null refers to read all files) and the initial_Offset to read part of the file. (Null refers to reading the complete file). 


-- Step 1: Set up the event to capture deadlock report
CREATE EVENT SESSION [extDeadlockGraph] ON SERVER 
    ADD EVENT sqlserver.xml_deadlock_report 
    ADD TARGET package0.event_file
    (
        SET
            FILENAME = N'D:\YourDirectory\Deadlock\Assets\extDeadlockGraph.xel',
            MAX_ROLLOVER_FILES = 0
    )
    WITH
    (
        EVENT_RETENTION_MODE = ALLOW_MULTIPLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 15 SECONDS,
        STARTUP_STATE = ON
    );

-- Start the event 
ALTER EVENT SESSION [extDeadlockGraph] ON SERVER
    STATE = START;
    
-- Step 2: Simulate a deadlock (example from Lesson 1 can be used)

-- Step 3: extract the deadlock information

-- Get the XML from the xel file created above
-- Save the file with .xml extension
SELECT
	object_name,
	CAST(event_data AS xml) AS EventXml
	FROM
		sys.fn_xe_file_target_read_file
		(
			'D:\YourDirectory\Deadlock\Assets\extDeadlockGraph_0_129953224793140000.xel',
			'D:\YourDirectory\Deadlock\Assets\extDeadlockGraph_0_129953224793140000.xem',
			NULL, NULL
		)

-- Step 4: Stop the event
-- Stop the event 
ALTER EVENT SESSION [extDeadlockGraph] ON SERVER
    STATE = STOP;