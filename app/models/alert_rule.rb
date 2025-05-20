class AlertRule < ApplicationRecord
  has_many :automated_responses, dependent: :destroy
  has_many :telegraf_cpu_configs
  has_many :telegraf_ram_configs

  validates :name, presence: true
  validates :metric_type, presence: true
  validates :operator, presence: true
  validates :threshold, presence: true
  validates :severity, presence: true
  validates :duration, presence: true

  scope :active, -> { where(active: true) }

  def self.operators
    %w[> >= < <= == !=]
  end

  def self.severities
    %w[info warning critical]
  end

  def self.metric_types
    %w[cpu_usage memory_usage disk_usage]
  end
end