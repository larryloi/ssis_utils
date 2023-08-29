-- sqlcmd -S MO-STG-SSRS01 -d test -i exp_sp.sql -v WORK_BASE= "'D:\temp\export_4_report'" SVC="'aino_ndm'" TIMESTAMP="'2017-05-01_12'" PROJECT="'cert'" -b
DECLARE @SP_TEXT NVARCHAR(MAX)
DECLARE @SP_FILE NVARCHAR(2000)
DECLARE @sp_name NVARCHAR(128);
DECLARE @FN_TEXT NVARCHAR(MAX)
DECLARE @FN_FILE NVARCHAR(2000)
DECLARE @fn_name NVARCHAR(128);

DECLARE sp_cur CURSOR
  FOR SELECT name FROM sys.procedures WHERE name NOT LIKE '%gram%';
OPEN sp_cur 
FETCH NEXT FROM sp_cur INTO @sp_name;

WHILE @@FETCH_STATUS= 0
   BEGIN
      SELECT @SP_TEXT = definition from sys.sql_modules where object_id = object_id(@sp_name);
     
      SET @SP_FILE = $(WORK_BASE) + '\report\'+ $(SVC) + '_' + $(TIMESTAMP) +'\sp\' + $(PROJECT) + '\' + @sp_name + '.sql';
     
      EXEC ssis_utils.dbo.WriteToFile @SP_FILE, @SP_TEXT;

	  FETCH NEXT FROM sp_cur INTO @sp_name
   END
CLOSE sp_cur
DEALLOCATE sp_cur;

DECLARE fn_cur CURSOR
  FOR SELECT p.name FROM [sys].[sql_modules] m JOIN  [sys].[objects] p on m.object_id = p.object_id where p.type IN (N'IF') ;
OPEN fn_cur 
FETCH NEXT FROM fn_cur INTO @fn_name;

WHILE @@FETCH_STATUS= 0
   BEGIN
      SELECT @FN_TEXT = definition FROM [sys].[sql_modules] m JOIN  [sys].[objects] p on m.object_id = p.object_id where p.type IN (N'IF') AND p.name = @fn_name;
     
      SET @FN_FILE = $(WORK_BASE) + '\report\'+ $(SVC) + '_' + $(TIMESTAMP) +'\sp\' + $(PROJECT) + '\' + @fn_name + '.sql';
     
      EXEC ssis_utils.dbo.WriteToFile @FN_FILE, @FN_TEXT;

	  FETCH NEXT FROM fn_cur INTO @fn_name
   END
CLOSE fn_cur
DEALLOCATE fn_cur;