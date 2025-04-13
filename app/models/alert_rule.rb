class AlertRule < ApplicationRecord
  METRIC_TYPES = %w[cpu_usage memory_usage disk_usage].freeze
  OPERATORS = %w[> < >= <= ==].freeze
  SEVERITIES = %w[critical warning info].freeze

  has_many :automated_responses, dependent: :destroy
  accepts_nested_attributes_for :automated_responses, allow_destroy: true

  validates :metric_type, presence: true, inclusion: { in: METRIC_TYPES }
  validates :operator, presence: true, inclusion: { in: OPERATORS }
  validates :threshold, presence: true, numericality: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :duration, presence: true, format: { with: /\A\d+[smh]\z/ }
end