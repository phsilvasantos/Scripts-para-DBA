--Verifica login acessando através da conta DAC
SELECT 
	login_name,
	nt_user_name,
	[status]  
FROM 
	sys.tcp_endpoints as e 
JOIN 
	sys.dm_exec_sessions as s   
ON 
	e.endpoint_id = s.endpoint_id 
WHERE 
	e.name='Dedicated Admin Connection';  


--DMVs para monitoração do uso de memória
SELECT * FROM sys.dm_os_memory_clerks
SELECT * FROM sys.dm_os_memory_cache_clock_hands
SELECT * FROM sys.dm_os_buffer_descriptors
SELECT * FROM sys.dm_os_sys_info

--DMVs para monitoração dos schedulers e workers
SELECT * FROM sys.dm_os_schedulers
SELECT * FROM sys.dm_os_workers

--Verificar qual o database mais utilizado na instância
SELECT 
	count(*)AS cached_pages_count,
	CASE database_id 
    WHEN 32767 THEN 'ResourceDb' 
    ELSE db_name(database_id) 
    END AS Database_name
FROM 
	sys.dm_os_buffer_descriptors
GROUP BY 
	db_name(database_id),
	database_id
ORDER BY 
	cached_pages_count DESC;
	
--Qual Worker está como SUSPENDED ou RUNNABLE por mais tempo
SELECT 
	t1.session_id,
	CONVERT(varchar(10), t1.status) AS status,
	CONVERT(varchar(15), t1.command) AS command,
	CONVERT(varchar(10), t2.state) AS worker_state,
	w_suspended = 
	CASE t2.wait_started_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_started_ms_ticks
      END,
    w_runnable = 
      CASE t2.wait_resumed_ms_ticks
        WHEN 0 THEN 0
        ELSE 
          t3.ms_ticks - t2.wait_resumed_ms_ticks
      END
FROM 
	sys.dm_exec_requests AS t1
INNER JOIN 
	sys.dm_os_workers AS t2
ON 
	t2.task_address = t1.task_address
CROSS JOIN 
	sys.dm_os_sys_info AS t3
WHERE 
	t1.scheduler_id IS NOT NULL
ORDER BY 
	t1.session_id DESC;
GO