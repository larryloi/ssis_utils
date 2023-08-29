#$env=Rails.env
$env = (Rails.env && Rails.env =~ /test|development|production0|sandbox0|staging0|staging1|sandbox5|sandbox3|production5|production3|ias_production|simulation/)? Rails.env : "development"

data_archive_seed_file = Rails.root.join("db", "seeds", "data_archive_#{$env}.yml")
data_archive_config = YAML::load_file(data_archive_seed_file)


### Loading arc_databases table
arc_database_config = data_archive_config["databases"]
arc_database_config.each do |conf| 
    if ArcDatabase.find_by_id(conf["arc_database"]["id"]).nil?
       ArcDatabase.create(:id => conf["arc_database"]["id"],
                          :name => conf["arc_database"]["name"],
                          :state => conf["arc_database"]["state"],
                          :created_at => Time.now.utc(),
                          :updated_at => Time.now.utc()
                      )
    end
end

### Loading arc_tables table
arc_table_list = data_archive_config["arc_tables"]
arc_table_list.each do |arc_table|
    if ArcTable.find_by(:arc_database_id => arc_table[0], :schema_name => arc_table[1], :name => arc_table[2]).nil?
       ArcTable.create(:arc_database_id => arc_table[0],
                       :schema_name => arc_table[1],
                       :name => arc_table[2],
                       :state => arc_table[3],
                       :date_key => arc_table[4],
                       :backup_batch_interval_hour => arc_table[5],
                       :backup_delay_interval_hour => arc_table[6],
                       :backup_data_start_at => arc_table[7],
                       :backup_data_end_at => arc_table[8],
                       :delete_batch_interval_hour => arc_table[9],
                       :delete_delay_interval_day => arc_table[10],
                       :delete_data_start_at => arc_table[11],
                       :delete_data_end_at => arc_table[12],
                       :created_at => Time.now.utc(),
                       :updated_at => Time.now.utc()
                      )
    end
end


### Loading system_parameters table
system_params = data_archive_config["archive_params"]
    if SystemParameter.find_by(:feature => 'arc', :parameter => 'environment').nil?
       SystemParameter.create(:feature => 'arc',
                              :parameter => 'environment',
                              :value => $env,
                              :description => 'Environment',
                              :created_at => Time.now.utc(),
                              :updated_at => Time.now.utc()
                             )
    end
system_params.each do |sys_param|
    if SystemParameter.find_by(:feature => sys_param[0], :parameter => sys_param[1]).nil?
       SystemParameter.create(:feature => sys_param[0],
                              :parameter => sys_param[1],
                              :value => sys_param[2],
                              :description => sys_param[3],
                              :created_at => Time.now.utc(),
                              :updated_at => Time.now.utc()
                             )
    end
end


### Loading util_cmds table
util_cmd_list = [
['create_svc_path.bat','Batch script for creating service paths','db/seeds/create_svc_path.bat'],
['exp_rdl.sql','SQL script that exporting report definition by particular report path and report name','db/seeds/exp_rdl.sql'],
['ftp_to_sv.bat','Batch script for ftp put report related files to SV server','db/seeds/ftp_to_sv.bat'],
['exp_dtsx.bat','Batch script for exporting ssis catalog project','db/seeds/exp_dtsx.bat'],
['exp_sp.sql','SQL script that exporting stored procedure by particular DB','db/seeds/exp_sp.sql']
]
UtilCmd.delete_all
util_cmd_list.each do |util_cmd|
#create_svc_path_file = Rails.root.join('db', 'seeds', 'create_svc_path.bat')
   file = Rails.root.join(util_cmd[2])
   data = File.read(file)
      if UtilCmd.find_by_name(util_cmd[0]).nil?
         UtilCmd.create(:name => util_cmd[0],
                        :description => util_cmd[1],
                        :cmd_text => data,
                        :created_at => Time.now.utc(),
                        :updated_at => Time.now.utc()
                       )
   end
end




etl_job_seed_file = Rails.root.join("db", "seeds", "etl_job_#{$env}.yml")
etl_job_config = YAML::load_file(etl_job_seed_file)

### Loading etl_jobs table
sql_agent_login = etl_job_config["login"]
etl_job_list = etl_job_config["etl_job_list"]
EtlJob.delete_all
etl_job_list.each do |etl_job|
EtlJob.create(:id => etl_job[0],
              :name => etl_job[1],
              :enabled => etl_job[2],
              :notify_level_eventlog => etl_job[3],
              :notify_level_email => etl_job[4],
              :notify_level_netsend => etl_job[5],
              :notify_level_page => etl_job[6],
              :delete_level => etl_job[7],
              :description => etl_job[8],
              :category_name => etl_job[9],
              :owner_login_name => sql_agent_login,
              :ssis_folder => etl_job[10],
              :ssis_project => etl_job[11],
              :created_at => Time.now.utc(),
              :updated_at => Time.now.utc()
              )
end

### Loading etl_job_steps table, etl_job_step_params table
proxy_name = etl_job_config["proxy_name"] || nil
etl_job_step_list = etl_job_config["etl_job_step_list"]
EtlJobStep.delete_all
EtlJobStepParam.delete_all
ActiveRecord::Base.connection.execute("DBCC CHECKIDENT ('[etl_job_steps]', RESEED, 0); ")
ActiveRecord::Base.connection.execute("DBCC CHECKIDENT ('[etl_job_step_params]', RESEED, 0); ")
etl_job_step_list.each do |etl_job_step|
   etl_job_step[10] == 'SSIS' ? ssis_proxy = proxy_name : ssis_proxy = nil
   new_step = EtlJobStep.create(
                  :etl_job_id => etl_job_step[0],
                  :name => etl_job_step[1],
                  :cmdexec_success_code => etl_job_step[2],
                  :on_success_action => etl_job_step[3],
                  :on_success_step_id => etl_job_step[4],
                  :on_fail_action => etl_job_step[5],
                  :on_fail_step_id => etl_job_step[6],
                  :retry_attempts => etl_job_step[7],
                  :retry_interval => etl_job_step[8],
                  :os_run_priority => etl_job_step[9],
                  :subsystem => etl_job_step[10],
                  :command => etl_job_step[11],
                  :database_name => etl_job_step[12],
                  :flags => etl_job_step[13],
                  :ssis_package => etl_job_step[14],
                  :proxy_name => ssis_proxy,
                  :created_at => Time.now.utc(),
                  :updated_at => Time.now.utc()
                 )
   unless etl_job_step[15].nil?
      b = eval(etl_job_step[15])
      b.each do |k,v|
      EtlJobStepParam.create(:etl_job_step_id => new_step[:id],
                             :parameter => k,
                             :value => v,
                             :created_at => Time.now.utc(),
                             :updated_at => Time.now.utc()
                            )
      end
   end
end


### Loading etl_job_schedules table
freq_subday_type = etl_job_config["etl_job_schedule"]["freq_subday_type"]
freq_subday_interval = etl_job_config["etl_job_schedule"]["freq_subday_interval"]
schedule_enabled = etl_job_config["etl_job_schedule"]["schedule_enabled"]
freq_type = etl_job_config["etl_job_schedule"]["freq_type"]
freq_interval = etl_job_config["etl_job_schedule"]["freq_interval"]

etl_job_schedule_list = etl_job_config["etl_job_schedule_list"]
EtlJobSchedule.delete_all
ActiveRecord::Base.connection.execute("DBCC CHECKIDENT ('[etl_job_schedules]', RESEED, 0); ")
etl_job_schedule_list.each do |etl_job_schedule|
EtlJobSchedule.create(
              :etl_job_id => etl_job_schedule[0],
              :enabled => schedule_enabled,
              :freq_type => freq_type,
              :freq_interval => freq_interval,
              :freq_subday_type => freq_subday_type,
              :freq_subday_interval => freq_subday_interval,
              :freq_relative_interval => etl_job_schedule[1],
              :freq_recurrence_factor => etl_job_schedule[2],
              :active_start_date => etl_job_schedule[3],
              :active_end_date => etl_job_schedule[4],
              :active_start_time => etl_job_schedule[5],
              :active_end_time => etl_job_schedule[6],
              :created_at => Time.now.utc(),
              :updated_at => Time.now.utc()
              )
end



