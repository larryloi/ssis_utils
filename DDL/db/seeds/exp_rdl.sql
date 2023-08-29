-- sqlcmd -S MO-STG-SSRS01 -d ReportServer -i exp_rdl.sql -v WORK_BASE= "'D:\temp\export_4_report'" SVC="'aino_ndm'" TIMESTAMP="'2017-05-01_12'" PROJECT="'cert'" FilterReportPath="'/RP-001-FNC'" FilterReportName="'RP-001-FNC'" -b

DECLARE @FilterReportPath AS VARCHAR(500) = NULL  
DECLARE @FilterReportName AS VARCHAR(500) = NULL 
DECLARE @OutputPath AS VARCHAR(500) = 'd:\temp\' 
DECLARE @TSQL AS NVARCHAR(MAX) 

SET @OutputPath = $(WORK_BASE) + '\report\'+ $(SVC) + '_' + $(TIMESTAMP) +'\rdl\' + $(PROJECT) + '\'

--SET @FilterReportPath='/RP-001-FNC'
--SET @FilterReportName='RP-001-FNC'

--Reset the OutputPath separator. 
SET @OutputPath = REPLACE(@OutputPath,'\','/') 
  
--Simple validation of OutputPath; this can be changed as per ones need. 
IF LTRIM(RTRIM(ISNULL(@OutputPath,''))) = '' 
BEGIN 
  SELECT 'Invalid Output Path' 
END 
ELSE 
BEGIN 

   SET @TSQL = STUFF((SELECT 
                      ';EXEC master..xp_cmdshell ''bcp " ' + 
                      ' SELECT ' + 
                      ' CONVERT(VARCHAR(MAX), ' + 
                      '       CASE ' + 
                      '         WHEN LEFT(C.Content,3) = 0xEFBBBF THEN STUFF(C.Content,1,3,'''''''') '+ 
                      '         ELSE C.Content '+ 
                      '       END) ' + 
                      ' FROM ' + 
                      ' [ReportServer].[dbo].[Catalog] CL ' + 
                      ' CROSS APPLY (SELECT CONVERT(VARBINARY(MAX),CL.Content) Content) C ' + 
                      ' WHERE ' + 
                      ' CL.ItemID = ''''' + CONVERT(VARCHAR(MAX), CL.ItemID) + ''''' " queryout "' + @OutputPath + '' + CL.Name + '.rdl" ' + '-T -c -x -r ''' 
                    FROM 
                      [ReportServer].[dbo].[Catalog] CL 
                    WHERE 
                      CL.[Type] = 2 --Report 
					  AND CL.[Path] = $(FilterReportPath) AND CL.Name = $(FilterReportName)
                    FOR XML PATH('')), 1,1,'') 
  
  --Execute the Dynamic Query 
  EXEC SP_EXECUTESQL @TSQL 
END