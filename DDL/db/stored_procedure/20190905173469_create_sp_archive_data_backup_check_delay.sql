CREATE PROCEDURE [dbo].[sp_archive_data_backup_check_delay]
    AS
BEGIN
DECLARE @ID VARCHAR(100),@name VARCHAR(100),@backup_delay_interval_hour VARCHAR(100),
@backup_data_start_at DATETIME,@backup_data_end_at DATETIME,@HostName VARCHAR(50)=host_name(),@RowCount INT=0
DECLARE Jcursor1 CURSOR FOR

SELECT id, name ,backup_delay_interval_hour,backup_data_start_at,backup_data_end_at
FROM arc_tables 
WHERE  dateadd(HOUR,36,dateadd(HOUR,backup_delay_interval_hour,backup_data_start_at)) < GETUTCDATE() AND state in (1,2) 

DECLARE @ENV VARCHAR(45)
DECLARE @TableBody1 VARCHAR(max)
DECLARE @TableHead VARCHAR(max)
DECLARE @TableTail VARCHAR(max)
DECLARE @Body VARCHAR(max)
DECLARE @HtmlHead VARCHAR(max)
DECLARE @HtmlTail VARCHAR(400)
DECLARE @mail_subject VARCHAR(100)
DECLARE @check_time int

SET @check_time=DATEPART(HOUR, GETDATE())

SET @ENV = right(DB_NAME(),(LEN(DB_NAME()) - 11))

SET @mail_subject = '[Sev2]['+left(DB_NAME(),10)+']['+@ENV+'] Archive data backup table delay alert found.'

SET @HtmlHead = '<html><head>' +
 '</head><body>' + 
 'Report Detail: <br>
Severity: Sev.2<br>
Host: '+@HostName+'<br>
Service: '+DB_NAME()+'<br>
Environment: '+@ENV+'<br>
Detected at: '+convert(varchar,getdate(),121)+'+800<br>
===============================================================================
<h4>Delay Tables</h4>'
SET @TableHead=
 '<style>' +
 'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;color:Black;} ' +
 '</style>' +
 '<table cellpadding=0 cellspacing=0 border=0>' +
 '<tr bgcolor=#FC6D4F>'+
 '<td align=center><b>Id</b></td>' +
 '<td align=center><b>Table_name</b></td>' +
 '<td align=center><b>Backup_data_start_at</b></td>'+
 '<td align=center><b>backup_data_end_at</b></td>'+
 '</tr>';
SET @HtmlTail ='</body></html>';
SET @TableTail = '</table>';
SET @TableBody1='';


OPEN Jcursor1
FETCH NEXT FROM Jcursor1 INTO @ID,@name,@backup_delay_interval_hour,@backup_data_start_at,@backup_data_end_at
WHILE @@FETCH_STATUS = 0
BEGIN
SET @RowCount=@RowCount+1
SET @TableBody1=@TableBody1+'<TR>'+'<TD>'+@ID+'</TD>'+'<TD>'+@name+'</TD>'+'<TD>'+convert(varchar,@backup_data_start_at,121)+'</TD>'+'<TD>'+convert(varchar,@backup_data_end_at,121)+'</TD></TR>'
FETCH NEXT FROM Jcursor1 INTO @ID,@name,@backup_delay_interval_hour,@backup_data_start_at,@backup_data_end_at
END
CLOSE Jcursor1
DEALLOCATE Jcursor1

SET @Body = @HtmlHead + 
			@TableHead + @TableBody1 + @TableTail + @HtmlTail


		
IF (@RowCount>0 AND @check_time in (1,7,13,19))
BEGIN
EXEC msdb.dbo.sp_send_dbmail
 @profile_name ='SQL Server mail',
 @recipients='dba@gamesourcecloud.com',
 @copy_recipients='alert.ds@gamesourcecloud.com',
 @subject = @mail_subject,
 @body = @Body,
 @body_format = 'HTML'; 
 END
END