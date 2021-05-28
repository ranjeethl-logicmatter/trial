--Scripts of Logging Tables

USE [WR_Admin]
/****** Object:  Table [dbo].[Analytics_ErrorLogs]    ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Analytics_ErrorLogs](
	[CatalogName] [varchar](20) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Execution_DateTime] [date] NULL,
	[FlagValue] [smallint] NOT NULL
) ON [PRIMARY]


/****** Object:  Table [dbo].[Analytics_Log]    ******/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Analytics_Log](
	[CatalogName] [varchar](10) NOT NULL,
	[TableName] [varchar](50) NOT NULL,
	[OldRecords] [int] NOT NULL,
	[NewRecords] [int] NOT NULL,
	[ValidFlag] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CatalogName] ASC,
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


-- Procs for Logging
  
USE [WR_Admin]
GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_Log_Add]    Script Date: 5/17/2021 9:58:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_Log_Add]
	@CatalogName varchar(10),
	@TableName varchar(50),
	@OldRecordCount nvarchar(100),
	@NewRecordCount nvarchar(100)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@OldRecordCount >= 0)
	BEGIN 
    -- Insert statements for procedure here
	INSERT into [WR_Admin].[dbo].Analytics_Log (CatalogName,TableName,OldRecords,NewRecords,ValidFlag)
	SELECT @CatalogName,@TableName,@OldRecordCount,0,0
	END

	IF (@NewRecordCount >= 0)
	BEGIN
	-- Insert statements for procedure here
	UPDATE [WR_Admin].[dbo].Analytics_Log SET NewRecords=@NewRecordCount WHERE CatalogName=@CatalogName and TableName=@TableName

	IF ((SELECT OldRecords FROM [WR_Admin].[dbo].Analytics_Log WHERE CatalogName=@CatalogName and TableName=@TableName) = @NewRecordCount)
	UPDATE [WR_Admin].[dbo].Analytics_Log SET ValidFlag =1 WHERE CatalogName=@CatalogName and TableName=@TableName
	   	
	END
END



GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_ErrorLogs_Add]    Script Date: 5/17/2021 9:57:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_ErrorLogs_Add]
	@CatalogName varchar(10),
	@Description varchar(1000),
	@FlagValue smallint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT into [WR_Admin].[dbo].Analytics_ErrorLogs (CatalogName,[Description],Execution_DateTime,FlagValue)
	SELECT @CatalogName,@Description,getdate(),@FlagValue
END


-- Proc for creating Temp tables

GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_TempTables]    Script Date: 5/17/2021 9:59:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_TempTables]
	@CatalogName sysname
AS
DECLARE @SQL nvarchar(max)
BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Employee_Benefit_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Employee_Benefit_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Employee_Benefit_Temp](
			[EmployeeNo] [varchar](24) NOT NULL,[Benefit_Class_Code] [varchar](10) NOT NULL,[Benefit_Class_Desc] [varchar](50) NULL,
			[Coverage_Category_Code] [varchar](6) NOT NULL,[Coverage_Category_Desc] [varchar](50) NULL,[Enrollment_Date] [datetime] NULL,
			[Eligibility_Date] [datetime] NULL,[Benefit_Plan_Code] [varchar](8) NOT NULL,[Benefit_Plan_Desc] [varchar](50) NULL,
			[Benefit_Option_Code] [varchar](8) NULL,[Benefit_Option_Desc] [varchar](50) NULL,[Employee_Cost] [money] NULL,
			[Employer_Cost] [money] NULL,[Coverage_Amount] [money] NULL,[FSA_Plan_Indicator] [varchar](8) NULL,
		CONSTRAINT [PK_Employee_Benefit_Temp] PRIMARY KEY CLUSTERED 
			([EmployeeNo] ASC,[Benefit_Class_Code] ASC,[Coverage_Category_Code] ASC,[Benefit_Plan_Code] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit_Temp Table Created.'',0'
	EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Emp_By_Month_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Emp_By_Month_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Emp_By_Month_Temp](
			[EmployeeNo] [varchar](30) NOT NULL,[First_Name] [varchar](50) NULL,[Last_Name] [varchar](50) NULL,[Month] [int] NOT NULL,
			[Quarter] [int] NULL,[Year] [int] NOT NULL,[Org_Level_1_Code] [varchar](5) NULL,[Org_Level_1_Desc] [varchar](50) NULL,
			[Org_Level_2_Code] [varchar](5) NULL,[Org_Level_2_Desc] [varchar](50) NULL,[Org_Level_3_Code] [varchar](5) NULL,
			[Org_Level_3_Desc] [varchar](50) NULL,[Org_Level_4_Code] [varchar](5) NULL,[Org_Level_4_Desc] [varchar](50) NULL,
			[Org_Level_5_Code] [varchar](5) NULL,[Org_Level_5_Desc] [varchar](50) NULL,[Org_Level_6_Code] [varchar](5) NULL,
			[Org_Level_6_Desc] [varchar](50) NULL,[Org_Level_7_Code] [varchar](5) NULL,[Org_Level_7_Desc] [varchar](50) NULL,
			[Employee_Status_Code] [varchar](5) NULL,[Employee_Status_Desc] [varchar](50) NULL,[Active] [varchar](5) NULL,
			[Status_Reason_Code] [varchar](10) NULL,[Status_Reason_Desc] [varchar](50) NULL,[Status_Eff_Date] [datetime] NULL,
			[EEO_Race_Code] [varchar](10) NULL,[EEO_Race_Name] [varchar](50) NULL,[EEO_Job_Category_Code] [varchar](10) NULL,
			[EEO_Job_Category_Desc] [varchar](50) NULL,[Gender_Code] [varchar](5) NULL,[Gender_Desc] [varchar](50) NULL,[FLSA] [varchar](5) NULL,
			[Title_Code] [varchar](10) NULL,[Title_Desc] [varchar](50) NULL,[Labor_Group] [varchar](10) NULL,[Labor_Group_Desc] [varchar](50) NULL,
			[PTO_Group] [varchar](10) NULL,[PTO_Group_Desc] [varchar](50) NULL,[PTO_Elig_Date] [datetime] NULL,[Benefit_Group] [varchar](10) NULL,
			[Benefit_Group_Desc] [varchar](50) NULL,[Benefit_Elig_Date] [datetime] NULL,[Security_Class] [varchar](10) NULL,
			[Security_Class_Desc] [varchar](50) NULL,[Rate_Type_Code] [varchar](10) NULL,[Rate_Type_Desc] [varchar](50) NULL,
			[Salary] [money] NULL,[Annual_Salary] [money] NULL,[Hourly_Rate] [money] NULL,[City] [varchar](50) NULL,[State] [varchar](10) NULL,
			[Date_of_Birth] [datetime] NULL,[Adj_Hire_Date] [datetime] NULL,[Orig_Hire_Date] [datetime] NULL,[Proj_Ret_Date] [datetime2](7) NULL,
			[Age_Range] [varchar](20) NULL,[Service_Year_Range] [varchar](20) NULL,[Proj_Retire_Range] [varchar](20) NULL,
			[Shift_Code] [varchar](10) NULL,[Shift_Desc] [varchar](50) NULL,[Reports_To] [varchar](30) NULL,[Reports_To_Name] [varchar](150) NULL,
			[Salary_Class] [varchar](10) NULL,[Salary_Class_Desc] [varchar](50) NULL,[Salary_Grade] [varchar](10) NULL,
			[Salary_Grade_Desc] [varchar](50) NULL,[Salary_Range_Min] [money] NULL,[Salary_Range_Mid] [money] NULL,[Salary_Range_Max] [money] NULL,
			[Compa_Ratio] [decimal](15, 2) NULL,[Job_Title_Class_Code] [varchar](10) NULL,[Job_Title_Class_Desc] [varchar](50) NULL,
			[Job_Title_FLSA_Code] [varchar](10) NULL,[Job_Title_FLSA_Desc] [varchar](50) NULL,[Job_Title_Job_Group_Code] [varchar](10) NULL,
			[Job_Title_Job_Group_Desc] [varchar](50) NULL,[Age] [int] NULL,[Service_Years] [int] NULL,[Last_Actual_Review_Date] [datetime] NULL,
			[Last_Review_Type] [varchar](10) NULL,[Last_Review_Type_Desc] [varchar](50) NULL,[Last_Review_Rating] [varchar](10) NULL,
			[Last_Review_Rating_Desc] [varchar](50) NULL,
		CONSTRAINT [PK_Emp_By_Month_Temp] PRIMARY KEY CLUSTERED 
			([EmployeeNo] ASC,[Month] ASC,[Year] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Mast_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Mast_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Mast_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Legal_Entity] [varchar](5) NULL,[Legal_Entity_Name] [varchar](50) NULL,[Pay_Group] [varchar](4) NULL,
			[Pay_Group_Name] [varchar](50) NULL,[Employee#] [varchar](24) NULL,[Pay_Ending_Date] [datetime] NULL,[Check_Date] [datetime] NULL,
			[Status_Date] [datetime] NULL,[Check_Status] [varchar](1) NULL,[Check_Status_Desc] [varchar](50) NULL,[Gross_Amount] [money] NULL,
			[Total_Net_Amount] [money] NULL,[Standard_Pay] [varchar](5) NULL,[Resident_Locality] [varchar](4) NULL,[Resident_Locality_Desc] [varchar](50) NULL,
			[Resident_State] [varchar](2) NULL,[Workers_Comp] [varchar](5) NULL,[Workers_Comp_Desc] [varchar](50) NULL,[Work_State] [varchar](2) NULL,
			[Weeks_Worked] [int] NULL,[Hours_Worked] [decimal](18, 3) NULL,[Hourly_Rate] [decimal](18, 3) NULL,[Org_Level_1_Code] [varchar](5) NULL,
			[Org_Level_2_Code] [varchar](5) NULL,[Org_Level_3_Code] [varchar](5) NULL,[Org_Level_4_Code] [varchar](5) NULL,
			[Org_Level_5_Code] [varchar](5) NULL,[Org_Level_6_Code] [varchar](5) NULL,[Org_Level_7_Code] [varchar](5) NULL,[Batch_Number] [int] NULL,
		CONSTRAINT [PK_Check_Mast_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Deduct_Temp]'') AND type in (N''U''))
			DROP TABLE [Check_Deduct_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [Check_Deduct_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Deduction_Code] [varchar](3) NOT NULL,
			[Deduction_Code_Desc] [varchar](50) NULL,[Employee_Amount] [money] NULL,[Employer_Amount] [money] NULL,
			[Enrollment_Year] [int] NULL,[Enrollment_Date] [datetime] NULL,[Benefit_Class_Code] [varchar](5) NULL,
			[Benefit_Class_Desc] [varchar](50) NULL,[Benefit_Plan_Code] [varchar](5) NULL,[Benefit_Plan_Desc] [varchar](50) NULL,
			[Benefit_Option_Code] [varchar](5) NULL,[Benefit_Option_Desc] [varchar](50) NULL,[FSA_Group_Code] [varchar](3) NULL,
			[FSA_Group_Code_Desc] [varchar](50) NULL,[FSA_Code] [varchar](3) NULL,[FSA_Desc] [varchar](50) NULL,
			[Deduction_Payee_Code] [varchar](5) NULL,[Deduction_Payee_Name] [varchar](50) NULL,[Docket#] [varchar](30) NULL,
			[Employee_Adjustment_Used] [money] NULL,[Employer_Adjustment_Used] [money] NULL,[Admin_Fee] [money] NULL,
			[Arrear_Amount] [money] NULL,[Date_Paid] [datetime] NULL,[Override] [varchar](5) NULL,[Reference_From_Date] [datetime] NULL,
			[Reference_To_Date] [datetime] NULL,
		CONSTRAINT [PK_Check_Deduct_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Deduction_Code] ASC)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY] 
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;	
	  
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_DirDep_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_DirDep_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_DirDep_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Account_Type] [varchar](3) NOT NULL,
			[Account_Type_Desc] [varchar](50) NULL,[ABA_Number] [int] NOT NULL,[Account#] [varchar](17) NOT NULL,[Amount] [money] NULL,
		CONSTRAINT [PK_Check_DirDep_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Account_Type] ASC,[ABA_Number] ASC,[Account#] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep_Temp Table Created.'',0';
	 EXEC sp_executesql @SQL;	

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Entl_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Entl_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Entl_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Entitlement_Group] [varchar](3) NOT NULL,
			[Entitlement_Group_Desc] [varchar](50) NULL,[Entitlement_Code] [varchar](3) NOT NULL,[Entitlement_Code_Desc] [varchar](50) NULL,
			[Entitlement_Bucket] [varchar](3) NOT NULL,[Entitlement_Bucket_Desc] [varchar](50) NULL,[Plan_Date] [datetime] NOT NULL,
			[Hours_Required] [decimal](18, 3) NULL,[Units_Used] [decimal](18, 3) NULL,[Units_Accrued] [decimal](18, 3) NULL,
			[Units_Lost] [decimal](18, 3) NULL,[Units_Omitted] [decimal](18, 3) NULL,
		CONSTRAINT [PK_Check_Entl_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Entitlement_Group] ASC,[Entitlement_Code] ASC,[Entitlement_Bucket] ASC,[Plan_Date] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl_Temp Table Created.'',0';
	 EXEC sp_executesql @SQL;	

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Pay_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Pay_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Pay_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Pay_Type] [varchar](3) NOT NULL,[Pay_Type_Desc] [varchar](50) NULL,
			[Amount] [money] NULL,[Hours_Worked] [decimal](18, 3) NULL,[Legal_Entity] [varchar](5) NULL,
		CONSTRAINT [PK_Check_Pay_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Pay_Type] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;	

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_PayDst_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_PayDst_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_PayDst_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Pay_Type] [varchar](3) NOT NULL,
			[Pay_Type_Desc] [varchar](50) NULL,[Account#] [varchar](32) NOT NULL,[Amount] [money] NULL,[Hours_Worked] [decimal](18, 3) NULL,
		CONSTRAINT [PK_Check_PayDst_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Pay_Type] ASC,[Account#] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;	

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Tax_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Tax_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Tax_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Tax_Class] [varchar](4) NOT NULL,[Tax_Class_Desc] [varchar](50) NULL,
			[State] [varchar](2) NOT NULL,[Locality] [varchar](4) NOT NULL,[Locality_Desc] [varchar](100) NULL,[Employee_Tax_Amount] [money] NULL,
			[Employee_Tax_Base] [money] NULL,[Employer_Tax_Amount] [money] NULL,[Employer_Tax_Base] [money] NULL,[Tax_Hours] [decimal](18, 3) NULL,
			[Supplemental_Tax_Wages] [money] NULL,[Is_Employee_Tax] [varchar](3) NULL,[Is_Employer_Tax] [varchar](3) NULL,
		CONSTRAINT [PK_Check_Tax_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Tax_Class] ASC,[State] ASC,[Locality] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;	

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Types_Temp]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Types_Temp]
		SET ANSI_NULLS ON
		SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Types_Temp](
			[Tranaction_ID] [varchar](255) NOT NULL,[Check_Type] [varchar](1) NOT NULL,[Check_Type_Desc] [varchar](50) NULL,
			[Payment_Number] [int] NULL,[Net_Amount] [money] NULL,[Recon_Date] [datetime] NULL,[ABA_Number] [int] NULL,[Account#] [varchar](17) NULL,
			[Stock_ID] [varchar](3) NULL,[Stock_ID_Desc] [varchar](50) NULL,[Old_Payment_Number] [int] NULL,[Check_Distribution_Code] [varchar](5) NULL,
		CONSTRAINT [PK_Check_Types_Temp] PRIMARY KEY CLUSTERED 
			([Tranaction_ID] ASC,[Check_Type] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types_Temp Table Created.'',0';
	EXEC sp_executesql @SQL;	

END


-- Proc  for Loading Data from Live Tables to Temp Tables

GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_TempLoadData]    Script Date: 5/17/2021 9:58:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_TempLoadData]
	@CatalogName sysname
AS
DECLARE @SQL nvarchar(max)
BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Employee_Benefit_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Employee_Benefit_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Employee_Benefit]'') AND type in (N''U''))
				BEGIN --Employee_Benefit
				IF (SELECT count(*) FROM Employee_Benefit)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Employee_Benefit_Temp
						SELECT * FROM Employee_Benefit
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Employee_Benefit'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Employee_Benefit to Employee_Benefit_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Employee_Benefit to Employee_Benefit_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Employee_Benefit'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Emp_By_Month_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Emp_By_Month_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Emp_By_Month]'') AND type in (N''U''))
				BEGIN --Emp_By_Month
				IF (SELECT count(*) FROM Emp_By_Month)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Emp_By_Month_Temp
						SELECT * FROM Emp_By_Month
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Emp_By_Month'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Emp_By_Month to Emp_By_Month_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Emp_By_Month to Emp_By_Month_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Emp_By_Month'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Mast_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Mast_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Mast]'') AND type in (N''U''))
				BEGIN --Check_Mast
				IF (SELECT count(*) FROM Check_Mast)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Mast_Temp
						SELECT * FROM Check_Mast
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Mast'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Mast to Check_Mast_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Mast to Check_Mast_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Mast'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Deduct_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Deduct_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Deduct]'') AND type in (N''U''))
				BEGIN --Check_Deduct
				IF (SELECT count(*) FROM Check_Deduct)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Deduct_Temp
						SELECT * FROM Check_Deduct
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Deduct'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Deduct to Check_Deduct_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Deduct to Check_Deduct_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Deduct'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_DirDep_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_DirDep_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_DirDep]'') AND type in (N''U''))
				BEGIN --Check_DirDep
				IF (SELECT count(*) FROM Check_DirDep)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_DirDep_Temp
						SELECT * FROM Check_DirDep
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_DirDep'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_DirDep to Check_DirDep_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_DirDep to Check_DirDep_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_DirDep'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Entl_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Entl_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Entl]'') AND type in (N''U''))
				BEGIN --Check_Entl
				IF (SELECT count(*) FROM Check_Entl)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Entl_Temp
						SELECT * FROM Check_Entl
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Entl'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Entl to Check_Entl_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Entl to Check_Entl_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Entl'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Pay_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Pay_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Pay]'') AND type in (N''U''))
				BEGIN --Check_Pay
				IF (SELECT count(*) FROM Check_Pay)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Pay_Temp
						SELECT * FROM Check_Pay
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Pay'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Pay to Check_Pay_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Pay to Check_Pay_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Pay'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_PayDst_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_PayDst_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_PayDst]'') AND type in (N''U''))
				BEGIN --Check_PayDst
				IF (SELECT count(*) FROM Check_PayDst)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_PayDst_Temp
						SELECT * FROM Check_PayDst
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_PayDst'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_PayDst to Check_PayDst_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_PayDst to Check_PayDst_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_PayDst'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Tax_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Tax_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Tax]'') AND type in (N''U''))
				BEGIN --Check_Tax
				IF (SELECT count(*) FROM Check_Tax)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Tax_Temp
						SELECT * FROM Check_Tax
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Tax'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Tax to Check_Tax_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Tax to Check_Tax_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Tax'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @oldRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Types_Temp]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Types_Temp
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Types]'') AND type in (N''U''))
				BEGIN --Check_Types
				IF (SELECT count(*) FROM Check_Types)>0
					BEGIN
					BEGIN TRANSACTION
						INSERT INTO Check_Types_Temp
						SELECT * FROM Check_Types
						SET @OldRecords = @@ROWCOUNT
   						IF (@OldRecords > 0)
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Types'',@OldRecords,-1
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Types to Check_Types_Temp table. '',0
								COMMIT TRANSACTION
								RETURN
							END
						ELSE 
							BEGIN
								EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Types to Check_Types_Temp table. '',2
								ROLLBACK TRANSACTION
								RETURN
							END					
					END
				ELSE
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Types'',0,-1
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types table has ZERO records. '',0
					END
				END
			ELSE 
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types table not found. '',2 
				END
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types_Temp table not found. '',2 
				END';
    EXEC sp_executesql @SQL;

END


--Proc for Creating Live tables  with datekeys

GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_RefactorTables]    Script Date: 5/17/2021 9:58:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_RefactorTables]
	@CatalogName sysname
AS
DECLARE @SQL nvarchar(max)
BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Employee_Benefit]'') AND type in (N''U''))
			DROP TABLE [dbo].[Employee_Benefit]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Employee_Benefit](
			[Datekey] [int] NOT NULL,[EmployeeNo] [varchar](24) NOT NULL,[Benefit_Class_Code] [varchar](10) NOT NULL,[Benefit_Class_Desc] [varchar](50) NULL,
			[Coverage_Category_Code] [varchar](6) NOT NULL,[Coverage_Category_Desc] [varchar](50) NULL,[Enrollment_Date] [datetime] NULL,
			[Eligibility_Date] [datetime] NULL,[Benefit_Plan_Code] [varchar](8) NOT NULL,[Benefit_Plan_Desc] [varchar](50) NULL,[Benefit_Option_Code] [varchar](8) NULL,
			[Benefit_Option_Desc] [varchar](50) NULL,[Employee_Cost] [money] NULL,[Employer_Cost] [money] NULL,[Coverage_Amount] [money] NULL,[FSA_Plan_Indicator] [varchar](8) NULL,
		CONSTRAINT [PK_Employee_Benefit] PRIMARY KEY CLUSTERED 
			([Datekey] ASC,[EmployeeNo] ASC,[Benefit_Class_Code] ASC,[Coverage_Category_Code] ASC,[Benefit_Plan_Code] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Emp_By_Month]'') AND type in (N''U''))
			DROP TABLE [dbo].[Emp_By_Month]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Emp_By_Month](
			[Datekey] [int] NOT NULL,[EmployeeNo] [varchar](30) NOT NULL,[First_Name] [varchar](50) NULL,[Last_Name] [varchar](50) NULL,[Month] [int] NOT NULL,
			[Quarter] [int] NULL,[Year] [int] NOT NULL,[Org_Level_1_Code] [varchar](5) NULL,[Org_Level_1_Desc] [varchar](50) NULL,[Org_Level_2_Code] [varchar](5) NULL,
			[Org_Level_2_Desc] [varchar](50) NULL,[Org_Level_3_Code] [varchar](5) NULL,[Org_Level_3_Desc] [varchar](50) NULL,[Org_Level_4_Code] [varchar](5) NULL,
			[Org_Level_4_Desc] [varchar](50) NULL,[Org_Level_5_Code] [varchar](5) NULL,[Org_Level_5_Desc] [varchar](50) NULL,[Org_Level_6_Code] [varchar](5) NULL,
			[Org_Level_6_Desc] [varchar](50) NULL,[Org_Level_7_Code] [varchar](5) NULL,[Org_Level_7_Desc] [varchar](50) NULL,[Employee_Status_Code] [varchar](5) NULL,
			[Employee_Status_Desc] [varchar](50) NULL,[Active] [varchar](5) NULL,[Status_Reason_Code] [varchar](10) NULL,[Status_Reason_Desc] [varchar](50) NULL,
			[Status_Eff_Date] [datetime] NULL,[EEO_Race_Code] [varchar](10) NULL,[EEO_Race_Name] [varchar](50) NULL,[EEO_Job_Category_Code] [varchar](10) NULL,
			[EEO_Job_Category_Desc] [varchar](50) NULL,[Gender_Code] [varchar](5) NULL,[Gender_Desc] [varchar](50) NULL,[FLSA] [varchar](5) NULL,[Title_Code] [varchar](10) NULL,
			[Title_Desc] [varchar](50) NULL,[Labor_Group] [varchar](10) NULL,[Labor_Group_Desc] [varchar](50) NULL,[PTO_Group] [varchar](10) NULL,[PTO_Group_Desc] [varchar](50) NULL,
			[PTO_Elig_Date] [datetime] NULL,[Benefit_Group] [varchar](10) NULL,[Benefit_Group_Desc] [varchar](50) NULL,[Benefit_Elig_Date] [datetime] NULL,[Security_Class] [varchar](10) NULL,
			[Security_Class_Desc] [varchar](50) NULL,[Rate_Type_Code] [varchar](10) NULL,[Rate_Type_Desc] [varchar](50) NULL,[Salary] [money] NULL,[Annual_Salary] [money] NULL,
			[Hourly_Rate] [money] NULL,[City] [varchar](50) NULL,[State] [varchar](10) NULL,[Date_of_Birth] [datetime] NULL,[Adj_Hire_Date] [datetime] NULL,
			[Orig_Hire_Date] [datetime] NULL,[Proj_Ret_Date] [datetime2](7) NULL,[Age_Range] [varchar](20) NULL,[Service_Year_Range] [varchar](20) NULL,[Proj_Retire_Range] [varchar](20) NULL,
			[Shift_Code] [varchar](10) NULL,[Shift_Desc] [varchar](50) NULL,[Reports_To] [varchar](30) NULL,[Reports_To_Name] [varchar](150) NULL,[Salary_Class] [varchar](10) NULL,
			[Salary_Class_Desc] [varchar](50) NULL,[Salary_Grade] [varchar](10) NULL,[Salary_Grade_Desc] [varchar](50) NULL,[Salary_Range_Min] [money] NULL,
			[Salary_Range_Mid] [money] NULL,[Salary_Range_Max] [money] NULL,[Compa_Ratio] [decimal](15, 2) NULL,[Job_Title_Class_Code] [varchar](10) NULL,
			[Job_Title_Class_Desc] [varchar](50) NULL,[Job_Title_FLSA_Code] [varchar](10) NULL,[Job_Title_FLSA_Desc] [varchar](50) NULL,[Job_Title_Job_Group_Code] [varchar](10) NULL,
			[Job_Title_Job_Group_Desc] [varchar](50) NULL,[Age] [int] NULL,[Service_Years] [int] NULL,[Last_Actual_Review_Date] [datetime] NULL,[Last_Review_Type] [varchar](10) NULL,
			[Last_Review_Type_Desc] [varchar](50) NULL,[Last_Review_Rating] [varchar](10) NULL,[Last_Review_Rating_Desc] [varchar](50) NULL,
		CONSTRAINT [PK_Emp_By_Month] PRIMARY KEY CLUSTERED 
			([Datekey] ASC,[EmployeeNo] ASC,[Month] ASC,[Year] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Mast]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Mast]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Mast](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Legal_Entity] [varchar](5) NULL,[Legal_Entity_Name] [varchar](50) NULL,
			[Pay_Group] [varchar](4) NULL,[Pay_Group_Name] [varchar](50) NULL,[Employee#] [varchar](24) NULL,[Pay_Ending_Date] [datetime] NULL,[Check_Date] [datetime] NULL,
			[Status_Date] [datetime] NULL,[Check_Status] [varchar](1) NULL,[Check_Status_Desc] [varchar](50) NULL,[Gross_Amount] [money] NULL,[Total_Net_Amount] [money] NULL,
			[Standard_Pay] [varchar](5) NULL,[Resident_Locality] [varchar](4) NULL,[Resident_Locality_Desc] [varchar](50) NULL,[Resident_State] [varchar](2) NULL,
			[Workers_Comp] [varchar](5) NULL,[Workers_Comp_Desc] [varchar](50) NULL,[Work_State] [varchar](2) NULL,[Weeks_Worked] [int] NULL,[Hours_Worked] [decimal](18, 3) NULL,
			[Hourly_Rate] [decimal](18, 3) NULL,[Org_Level_1_Code] [varchar](5) NULL,[Org_Level_2_Code] [varchar](5) NULL,[Org_Level_3_Code] [varchar](5) NULL,
			[Org_Level_4_Code] [varchar](5) NULL,[Org_Level_5_Code] [varchar](5) NULL,[Org_Level_6_Code] [varchar](5) NULL,[Org_Level_7_Code] [varchar](5) NULL,[Batch_Number] [int] NULL,
		CONSTRAINT [PK_Check_Mast] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Deduct]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Deduct]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Deduct](
			[CheckDateKey] [int] NOT NULL,[PEDateKey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Deduction_Code] [varchar](3) NOT NULL,
			[Deduction_Code_Desc] [varchar](50) NULL,[Employee_Amount] [money] NULL,[Employer_Amount] [money] NULL,[Enrollment_Year] [int] NULL,[Enrollment_Date] [datetime] NULL,
			[Benefit_Class_Code] [varchar](5) NULL,[Benefit_Class_Desc] [varchar](50) NULL,[Benefit_Plan_Code] [varchar](5) NULL,[Benefit_Plan_Desc] [varchar](50) NULL,
			[Benefit_Option_Code] [varchar](5) NULL,[Benefit_Option_Desc] [varchar](50) NULL,[FSA_Group_Code] [varchar](3) NULL,[FSA_Group_Code_Desc] [varchar](50) NULL,
			[FSA_Code] [varchar](3) NULL,[FSA_Desc] [varchar](50) NULL,[Deduction_Payee_Code] [varchar](5) NULL,[Deduction_Payee_Name] [varchar](50) NULL,
			[Docket#] [varchar](30) NULL,[Employee_Adjustment_Used] [money] NULL,[Employer_Adjustment_Used] [money] NULL,[Admin_Fee] [money] NULL,[Arrear_Amount] [money] NULL,
			[Date_Paid] [datetime] NULL,[Override] [varchar](5) NULL,[Reference_From_Date] [datetime] NULL,[Reference_To_Date] [datetime] NULL,
		CONSTRAINT [PK_Check_Deduct] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Deduction_Code] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_DirDep]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_DirDep]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_DirDep](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,
			[Account_Type] [varchar](3) NOT NULL,[Account_Type_Desc] [varchar](50) NULL,[ABA_Number] [int] NOT NULL,[Account#] [varchar](17) NOT NULL,[Amount] [money] NULL,
		CONSTRAINT [PK_Check_DirDep] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Account_Type] ASC,[ABA_Number] ASC,[Account#] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Entl]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Entl]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Entl](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Entitlement_Group] [varchar](3) NOT NULL,
			[Entitlement_Group_Desc] [varchar](50) NULL,[Entitlement_Code] [varchar](3) NOT NULL,[Entitlement_Code_Desc] [varchar](50) NULL,[Entitlement_Bucket] [varchar](3) NOT NULL,
			[Entitlement_Bucket_Desc] [varchar](50) NULL,[Plan_Date] [datetime] NOT NULL,[Hours_Required] [decimal](18, 3) NULL,[Units_Used] [decimal](18, 3) NULL,
			[Units_Accrued] [decimal](18, 3) NULL,[Units_Lost] [decimal](18, 3) NULL,[Units_Omitted] [decimal](18, 3) NULL,
		CONSTRAINT [PK_Check_Entl] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Entitlement_Group] ASC,[Entitlement_Code] ASC,[Entitlement_Bucket] ASC,[Plan_Date] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Pay]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Pay]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Pay](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Pay_Type] [varchar](3) NOT NULL,
			[Pay_Type_Desc] [varchar](50) NULL,[Amount] [money] NULL,[Hours_Worked] [decimal](18, 3) NULL,[Legal_Entity] [varchar](5) NULL,
		CONSTRAINT [PK_Check_Pay] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Pay_Type] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_PayDst]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_PayDst]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_PayDst](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Pay_Type] [varchar](3) NOT NULL,
			[Pay_Type_Desc] [varchar](50) NULL,[Account#] [varchar](32) NOT NULL,[Amount] [money] NULL,[Hours_Worked] [decimal](18, 3) NULL,
		CONSTRAINT [PK_Check_PayDst] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Pay_Type] ASC,[Account#] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Tax]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Tax]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Tax](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Tax_Class] [varchar](4) NOT NULL,
			[Tax_Class_Desc] [varchar](50) NULL,[State] [varchar](2) NOT NULL,[Locality] [varchar](4) NOT NULL,[Locality_Desc] [varchar](100) NULL,
			[Employee_Tax_Amount] [money] NULL,[Employee_Tax_Base] [money] NULL,[Employer_Tax_Amount] [money] NULL,[Employer_Tax_Base] [money] NULL,
			[Tax_Hours] [decimal](18, 3) NULL,[Supplemental_Tax_Wages] [money] NULL,[Is_Employee_Tax] [varchar](3) NULL,[Is_Employer_Tax] [varchar](3) NULL,
		CONSTRAINT [PK_Check_Tax] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Tax_Class] ASC,[State] ASC,[Locality] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[Check_Types]'') AND type in (N''U''))
			DROP TABLE [dbo].[Check_Types]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
		CREATE TABLE [dbo].[Check_Types](
			[CheckDatekey] [int] NOT NULL,[PEDatekey] [int] NOT NULL,[Tranaction_ID] [varchar](255) NOT NULL,[Employee#] [varchar](24) NULL,[Check_Type] [varchar](1) NOT NULL,
			[Check_Type_Desc] [varchar](50) NULL,[Payment_Number] [int] NULL,[Net_Amount] [money] NULL,[Recon_Date] [datetime] NULL,[ABA_Number] [int] NULL,
			[Account#] [varchar](17) NULL,[Stock_ID] [varchar](3) NULL,[Stock_ID_Desc] [varchar](50) NULL,[Old_Payment_Number] [int] NULL,[Check_Distribution_Code] [varchar](5) NULL,
		CONSTRAINT [PK_Check_Types] PRIMARY KEY CLUSTERED 
			([CheckDatekey] ASC,[PEDatekey] ASC,[Tranaction_ID] ASC,[Check_Type] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
		EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types Table Created with Datekeys.'',0';
    EXEC sp_executesql @SQL;

END

--Loading Data from Temp tables into Live Tables


GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_LiveLoadData]    Script Date: 5/17/2021 9:58:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_LiveLoadData]
	@CatalogName sysname
AS
DECLARE @SQL nvarchar(max),@oldRecords nvarchar(100)
BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Employee_Benefit]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Employee_Benefit
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Employee_Benefit_Temp]'') AND type in (N''U''))
			 BEGIN --Employee_Benefit
			  IF (SELECT count(*) FROM Employee_Benefit_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Employee_Benefit
				 SELECT Cast(Cast(year(getdate()) as varchar(4))+Case When DATALENGTH(cast(month(getdate()) as varchar(2)))=1 Then ''0''+Cast(month(getdate()) as varchar(2))+''00'' Else Cast(month(getdate()) as varchar(2))+''00'' End as int), * FROM Employee_Benefit_Temp
				SET @NewRecords = @@ROWCOUNT
   				IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Employee_Benefit'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Employee_Benefit_Temp to Employee_Benefit table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Employee_Benefit_Temp to Employee_Benefit table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Employee_Benefit'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Employee_Benefit table not found. '',2 
		END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		'  DECLARE @NewRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Emp_By_Month]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Emp_By_Month
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Emp_By_Month_Temp]'') AND type in (N''U''))
			 BEGIN --Emp_By_Month
			  IF (SELECT count(*) FROM Emp_By_Month_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Emp_By_Month
				 SELECT Cast([Year] as varchar(4))+ Case When DATALENGTH(cast([Month] as varchar(2)))=1 Then ''0''+Cast([Month] as varchar(2))+''00'' Else Cast([Month] as varchar(2))+''00'' End, * FROM Emp_By_Month_Temp
				SET @NewRecords = @@ROWCOUNT
   				IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Emp_By_Month'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Emp_By_Month_Temp to Emp_By_Month table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Emp_By_Month_Temp to Emp_By_Month table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Emp_By_Month'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Emp_By_Month table not found. '',2 
		END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Mast]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Mast
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Mast_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Mast
			  IF (SELECT count(*) FROM Check_Mast_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Mast 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int), * FROM [Check_Mast_Temp]  
				SET @NewRecords = @@ROWCOUNT
   				IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Mast'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Mast_Temp to Check_Mast table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Mast_Temp to Check_Mast table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Mast'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Mast table not found. '',2 
		END';
    EXEC sp_executesql @SQL;

	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		   IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Deduct]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Deduct
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Deduct_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Deduct
			  IF (SELECT count(*) FROM Check_Deduct_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Deduct
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				CM.[Tranaction_ID],[Employee#],[Deduction_Code],[Deduction_Code_Desc],[Employee_Amount],[Employer_Amount],[Enrollment_Year],[Enrollment_Date],[Benefit_Class_Code],[Benefit_Class_Desc]
				,[Benefit_Plan_Code],[Benefit_Plan_Desc],[Benefit_Option_Code],[Benefit_Option_Desc],[FSA_Group_Code],[FSA_Group_Code_Desc],[FSA_Code],[FSA_Desc],[Deduction_Payee_Code],[Deduction_Payee_Name],[Docket#]
				,[Employee_Adjustment_Used],[Employer_Adjustment_Used],[Admin_Fee],[Arrear_Amount],[Date_Paid],[Override],[Reference_From_Date],[Reference_To_Date]
				FROM [Check_Deduct_Temp] CD inner Join [Check_Mast_Temp] CM on CD.Tranaction_ID=CM.Tranaction_ID
				SET @NewRecords = @@ROWCOUNT
   				IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Deduct'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Deduct_Temp to Check_Deduct table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Deduct_Temp to Check_Deduct table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Deduct'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Deduct table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_DirDep]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_DirDep
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_DirDep_Temp]'') AND type in (N''U''))
			 BEGIN --Check_DirDep
			  IF (SELECT count(*) FROM Check_DirDep_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_DirDep 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CDI.[Tranaction_ID],[Employee#],[Account_Type],[Account_Type_Desc],[ABA_Number],[Account#],[Amount]
				 FROM [Check_DirDep_Temp] CDI inner Join [Check_Mast_Temp] CM on CDI.Tranaction_ID=CM.Tranaction_ID
				 SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_DirDep'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_DirDep_Temp to Check_DirDep table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_DirDep_Temp to Check_DirDep table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_DirDep'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_DirDep table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Entl]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Entl
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Entl_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Entl
			  IF (SELECT count(*) FROM Check_Entl_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Entl 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CE.[Tranaction_ID],[Employee#],[Entitlement_Group],[Entitlement_Group_Desc],[Entitlement_Code],[Entitlement_Code_Desc]
				,[Entitlement_Bucket],[Entitlement_Bucket_Desc],[Plan_Date],[Hours_Required],[Units_Used],[Units_Accrued],[Units_Lost],[Units_Omitted]
				FROM [Check_Entl_Temp] CE inner Join [Check_Mast_Temp] CM on CE.Tranaction_ID=CM.Tranaction_ID
				SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Entl'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Entl_Temp to Check_Entl table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Entl_Temp to Check_Entl table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Entl'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Entl table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Pay]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Pay
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Pay_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Pay
			  IF (SELECT count(*) FROM Check_Pay_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Pay 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CP.[Tranaction_ID],[Employee#],[Pay_Type],[Pay_Type_Desc],[Amount],CP.[Hours_Worked],CP.[Legal_Entity]
				FROM [Check_Pay_Temp] CP inner Join [Check_Mast_Temp] CM on CP.Tranaction_ID=CM.Tranaction_ID
				SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Pay'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Pay_Temp to Check_Pay table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Pay_Temp to Check_Pay table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Pay'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Pay table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_PayDst]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_PayDst
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_PayDst_Temp]'') AND type in (N''U''))
			 BEGIN --Check_PayDst
			  IF (SELECT count(*) FROM Check_PayDst_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_PayDst 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CPD.[Tranaction_ID],[Employee#],[Pay_Type],[Pay_Type_Desc],CPD.[Account#],[Amount],CPD.[Hours_Worked]
				FROM [Check_PayDst_Temp] CPD inner Join [Check_Mast_Temp] CM on CPD.Tranaction_ID=CM.Tranaction_ID   
				SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_PayDst'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_PayDst_Temp to Check_PayDst table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_PayDst_Temp to Check_PayDst table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_PayDst'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_PayDst table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Tax]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Tax
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Tax_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Tax
			  IF (SELECT count(*) FROM Check_Tax_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Tax 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CT.[Tranaction_ID],[Employee#],[Tax_Class],[Tax_Class_Desc],[State],[Locality],[Locality_Desc],[Employee_Tax_Amount],[Employee_Tax_Base],
				 [Employer_Tax_Amount],[Employer_Tax_Base],[Tax_Hours],[Supplemental_Tax_Wages],[Is_Employee_Tax],[Is_Employer_Tax]
				FROM [Check_Tax_Temp] CT inner Join [Check_Mast_Temp] CM on CT.Tranaction_ID=CM.Tranaction_ID
				SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Tax'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Tax_Temp to Check_Tax table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Tax_Temp to Check_Tax table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Tax'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Tax table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
	
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @NewRecords nvarchar(100)
		  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Types]'') AND type in (N''U''))
		   BEGIN
		    TRUNCATE TABLE Check_Types
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[Check_Types_Temp]'') AND type in (N''U''))
			 BEGIN --Check_Types
			  IF (SELECT count(*) FROM Check_Types_Temp)>0
				BEGIN
				BEGIN TRANSACTION
				 INSERT INTO Check_Types 
				 SELECT cast((cast(year(check_date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Check_Date) as Varchar(1))
				    Else cast(month(Check_Date) as Varchar(2))End) +
				 (Case 
				    When DataLength(cast(Day(Check_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Check_Date) as Varchar(1)) 
				    Else Cast(Day(Check_Date) as varchar(2))End)) as int),
			      cast((cast(year(Pay_Ending_Date) as varchar(4))+ 
			     (Case 
				    When DataLength(cast(month(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(month(Pay_Ending_Date) as Varchar(1))
					Else cast(month(Pay_Ending_Date) as Varchar(2))End)+
				(Case 
				    When DataLength(cast(Day(Pay_Ending_Date) as Varchar(2)))=1
				    Then ''0''+cast(Day(Pay_Ending_Date) as Varchar(1)) 
					Else Cast(Day(Pay_Ending_Date) as varchar(2))End)) as int),
				 CTYP.[Tranaction_ID],[Employee#],[Check_Type],[Check_Type_Desc],[Payment_Number],[Net_Amount],[Recon_Date],[ABA_Number]
				,[Account#],[Stock_ID],[Stock_ID_Desc],[Old_Payment_Number],[Check_Distribution_Code]
				FROM [Check_Types_Temp] CTYP inner Join [Check_Mast_Temp] CM on CTYP.Tranaction_ID=CM.Tranaction_ID
				SET @NewRecords = @@ROWCOUNT
   				 IF (@NewRecords > 0)
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Types'',-1,@NewRecords
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data from Check_Types_Temp to Check_Types table. '',0
						COMMIT TRANSACTION
						RETURN
					END
				ELSE 
					BEGIN
						EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Load data from Check_Types_Temp to Check_Types table. '',2
						ROLLBACK TRANSACTION
						RETURN
					END					
			END
			ELSE
				BEGIN
					EXEC WR_admin.dbo.proc_Analytics_Log_Add '+@CatalogName+',''Check_Types'',-1,0
					EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types_Temp table has ZERO records. '',0
				END
		END
		ELSE 
			BEGIN
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types_Temp table not found. '',2 
			END
	END
	ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Check_Types table not found. '',2 
		END';
    EXEC sp_executesql @SQL;
END


-- Script for creating Date dimension table


GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_DateDimTable]    Script Date: 5/17/2021 9:56:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_Analytics_DateDimTable]
	@CatalogName sysname
AS
DECLARE @SQL nvarchar(max)
BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[DateDimension]'') AND type in (N''U''))
			DROP TABLE [dbo].[DateDimension]
			SET ANSI_NULLS ON
			SET QUOTED_IDENTIFIER ON
			CREATE TABLE [dbo].[DateDimension]([DateKey] [int] NOT NULL,[DayKey] [int] NULL,[Date] [date] NULL,[Year] [int] NOT NULL,
				[Year_Desc] [varchar](4) NOT NULL,[Month] [int] NOT NULL,[Month_Desc] [varchar](10) NOT NULL,[Month_by_Year] [varchar](10) NULL,
				[Quarter] [int] NOT NULL,[Quarter_Desc] [varchar](10) NOT NULL,[StartOfMonth] [date] NULL,[EndOfMonth] [date] NULL,
				[DayOfMonth] [int]  NULL,[DayOfWeek] [int]  NULL,
				PRIMARY KEY CLUSTERED 
				( [DateKey] ASC )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
			) ON [PRIMARY]
			EXEC WR_Admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''DateDimension Table Created.'',0';
	  EXEC sp_executesql @SQL;
END

-- script for Loading Data into Date Dimension


GO
/****** Object:  StoredProcedure [dbo].[Proc_Analytics_DateDimLoad]    Script Date: 5/17/2021 9:55:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Proc_Analytics_DateDimLoad]
	@CatalogName sysname,
	@StartDate DATE,
	@EndDate DATE
AS
	DECLARE @SQL nvarchar(max)
	BEGIN
	SET @SQL = N'USE '+QUOTENAME(@CatalogName)+
	' DECLARE @startingDate nvarchar(10),@EndingDate nvarchar(10)
		 SET @startingDate='''+Convert(nvarchar(10),@StartDate,110)+'''
		 SET @EndingDate='''+Convert(nvarchar(10),@EndDate,110)+'''
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[DateDimension]'') AND type in (N''U''))
		 BEGIN
		 BEGIN TRANSACTION
		  WHILE (convert(date,@startingDate) <= Convert(date,@EndingDate))
		   BEGIN
			IF NOT EXISTS ( SELECT * FROM [DateDimension] where DateKey = cast(YEAR(@startingDate) AS VARCHAR(5))+(SELECT RIGHT(''0''+RTRIM(MONTH(@startingDate)),2)) + ''00'')
			 BEGIN
			   INSERT INTO [dbo].[DateDimension] 
			    VALUES (cast(YEAR(@startingDate) AS VARCHAR(5))+(SELECT RIGHT(''0''+RTRIM(MONTH(@startingDate)),2))+''00'',
					NULL,NULL,
					YEAR(@startingDate),
					cast(YEAR(@startingDate) AS VARCHAR(4)),
					Month(@startingDate),
					(Case cast(MONTH(@startingDate) as int) 
						When 1 Then ''January'' When 2 Then ''Febuary'' When 3 Then ''March'' When 4 Then ''April'' When 5 Then ''May''
						When 6 Then ''Jun'' When 7 Then ''July'' When 8 Then ''August'' When 9 Then ''September'' When 10 Then ''October''
						When 11 Then ''November''
						Else ''December''
					END),
					Cast(Month(@startingDate) as varchar(2))+'' - ''+Cast(YEAR(@startingDate) as varchar(4)),
					DATEPART(Quarter, @startingDate),
					(Case Cast(DATEPART(Quarter, @startingDate) as int) 
						When 1 Then ''Quarter-1'' When 2 Then ''Quarter-2'' When 3 Then ''Quarter-3''
						Else ''Quarter-4''
					End),NULL,NULL,NULL,NULL);
			 END
			INSERT INTO [dbo].[DateDimension] 
				VALUES (cast(YEAR(@startingDate) AS VARCHAR(5))+(SELECT RIGHT(''0''+RTRIM(MONTH(@startingDate)),2))+(SELECT RIGHT(''0''+RTRIM(DAY(@startingDate)),2)),
				cast(YEAR(@startingDate) AS VARCHAR(5)) + cast(datepart(DayOFYear, @startingDate) AS VARCHAR(5)),
				@startingDate,
				YEAR(@startingDate),
				cast(YEAR(@startingDate) AS VARCHAR(4)),
				Month(@startingDate),
				(Case cast(MONTH(@startingDate) as int) 
					When 1 Then ''January'' When 2 Then ''Febuary'' When 3 Then ''March'' When 4 Then ''April'' When 5 Then ''May''
					When 6 Then ''Jun'' When 7 Then ''July'' When 8 Then ''August'' When 9 Then ''September'' When 10 Then ''October''
					When 11 Then ''November''
					Else ''December''
				END),
				Cast(Month(@startingDate) as varchar(2))+'' - ''+Cast(YEAR(@startingDate) as varchar(4)),
				DATEPART(Quarter, @startingDate),
				(Case Cast(DATEPART(Quarter, @startingDate) as int) 
					When 1 Then ''Quarter-1'' When 2 Then ''Quarter-2'' When 3 Then ''Quarter-3''
					Else ''Quarter-4''
				End),
				DATEADD(D, 1, EOMONTH(@startingDate, - 1)),
				EOMONTH(@startingDate),
				DATEPART(Day, @startingDate),
				(DATEPART(week, @startingDate) - DATEPART(week, DATEADD(day, 1, EOMONTH(@startingDate, - 1)))) + 1);
	
			SET @startingDate = DATEADD(day, 1, convert(date,@startingDate))
		END
		IF (SELECT count(*) FROM DateDimension)>0
		 BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Loaded data to DateDimension table. '',0
			COMMIT TRANSACTION
			RETURN
		 END
		ELSE 
		 BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''Failed to Loaded data to DateDimension table. '',2
			ROLLBACK TRANSACTION
			RETURN
		 END		
	  END
	 ELSE
		BEGIN
			EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',''DateDimension table not found. '',2
		END'
	PRINT @SQL;
	Execute sp_executesql @SQL;
END


--- Rename  Temp table as Live table if Data Loading is unsuccessfull
      --  ( oldRecords count and NewRecord count does not match in Analytics_Log table) 


GO
/****** Object:  StoredProcedure [dbo].[proc_Analytics_VerifyRecordCount]    Script Date: 5/21/2021 11:45:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[proc_Analytics_VerifyRecordCount]
	@CatalogName varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max)
	SET @SQL = N'USE '+QUOTENAME(@CatalogName) +
		' DECLARE @TableName varchar(30)
		  DECLARE vCursor CURSOR FOR 
			SELECT [TableName] FROM  [WR_Admin].[dbo].[Analytics_Log] WHERE [CatalogName] = '+@CatalogName+' and [validFlag] = 0
		   OPEN vCursor;
		   FETCH vCursor INTO @TableName;
		   WHILE(@@FETCH_STATUS = 0)
			BEGIN
				DECLARE @TempTableName varchar(30),@InfoLogs varchar(120)
				IF @TableName=''Employee_Benefit'' BEGIN DROP TABLE Employee_Benefit END
				IF @TableName=''Emp_by_Month'' BEGIN DROP TABLE Emp_by_Month END
				IF @TableName=''Check_Mast'' BEGIN DROP TABLE Check_Mast END
				IF @TableName=''Check_Deduct'' BEGIN DROP TABLE Check_Deduct END
				IF @TableName=''Check_DirDep'' BEGIN DROP TABLE Check_DirDep END
				IF @TableName=''Check_Entl'' BEGIN DROP TABLE Check_Entl END
				IF @TableName=''Check_Pay'' BEGIN DROP TABLE Check_Pay END
				IF @TableName=''Check_PayDst'' BEGIN DROP TABLE Check_PayDst END
				IF @TableName=''Check_Tax'' BEGIN DROP TABLE Check_Tax END
				IF @TableName=''Check_Types'' BEGIN DROP TABLE Check_Types END
				SET @TempTableName = cast(@TableName as varchar(30))
				SET @TempTableName = Concat(@TempTableName,''_Temp'')
				Execute sp_rename @TempTableName,@TableName
				SET @InfoLogs = Concat(''Rolled back '',@TempTableName,'' table to '',@TableName,'' live table.'')
				EXEC WR_admin.dbo.proc_Analytics_ErrorLogs_Add '+@CatalogName+',@InfoLogs,2
			FETCH  vCursor INTO @TableName;
			END; -- while
		CLOSE vCursor;
		DEALLOCATE vCursor;'
		EXEC sp_executesql @SQL;
END