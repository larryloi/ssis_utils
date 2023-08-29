class EtlJob < ActiveRecord::Base
  has_many :etl_job_steps
end
