--Automation Script
--Used cursor to loop for multiple databases/ Pass the Database name Statically  for single Database Execution

DECLARE @SQL nvarchar(max), @CatalogName sysname, @OldRecords nvarchar(100);
TRUNCATE TABLE WR_Admin.dbo.Analytics_Log
TRUNCATE TABLE WR_Admin.dbo.Analytics_ErrorLogs
  DECLARE DBcursor CURSOR  FOR
    SELECT CatalogName FROM  WR_Admin.dbo.DTSCompanyConfig where CatalogName='2000'
    OPEN DBcursor; FETCH  DBcursor   INTO @CatalogName;
     WHILE (@@FETCH_STATUS = 0) -- loop through all db-s
	  BEGIN

 /***** CREATE TABLE SCRIPT: Below script for creating temporary table to backup data before droping the old table. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_ADMIN.dbo.[proc_Analytics_TempTables] @CatalogName;
		
/***** LOAD DATA to TEMP TABLE SCRIPT: Below script dumping the data to temporary table to backup data before droping the old table. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_Admin.[dbo].[proc_Analytics_TempLoadData] @CatalogName;
		
/***** CREATE TABLE SCRIPT: Below script for creating table with datekeys before loading the temp table data. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_Admin.dbo.[proc_Analytics_RefactorTables] @CatalogName;		

/***** LOAD DATA to LIVE TABLE SCRIPT: Below script to load the data from temporary table to live table. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_Admin.[dbo].[proc_Analytics_LiveLoadData] @CatalogName;

/***** CREATE DATEDIM TABLE SCRIPT: Below script for creating datedim table. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_Admin.dbo.[proc_Analytics_DateDimTable] @CatalogName;				

/***** LOAD DATA to DATEDIM TABLE SCRIPT: Below script to generate the data and load data to datedim table. *****/
		/*****-------------------------------------------------------------------------------------------------------------*****/
		EXECUTE WR_Admin.[dbo].[Proc_Analytics_DateDimLoad] @CatalogName,'2018-01-01','2026-12-31';

/***** Rename  Temp table as Live table if Data Loading is unsuccessfull
        ( oldRecords count and NewRecord count does not match in Analytics_Log table) *****/
		/******-----------------------------------------------------------------------------------------------------------------*****/

		IF ((SELECT MIN(ValidFlag) FROM  [WR_Admin].[dbo].[Analytics_Log] WHERE CatalogName = @CatalogName) = 0).
		 BEGIN
			EXECUTE WR_Admin.[dbo].[proc_Analytics_VerifyRecordCount] @CatalogName;
		 END
	  

     FETCH  DBcursor INTO @CatalogName;
	END; -- while
   CLOSE DBcursor; DEALLOCATE DBcursor;


