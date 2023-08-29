class EtlJobStepsAddColumnProxyName < ActiveRecord::Migration
  def self.up
    add_column :etl_job_steps, :proxy_name, :string, :limit =>128 , null: true
  end

  def self.down
    remove_column :etl_job_steps, :proxy_name
  end
end
