class ResponseExecution < ApplicationRecord
  belongs_to :automated_response
  
  validates :status, presence: true, inclusion: { in: %w[success failure] }
  validates :executed_at, presence: true
  
  before_validation :set_executed_at, on: :create
  
  private
  
  def set_executed_at
    self.executed_at ||= Time.current
  end
end