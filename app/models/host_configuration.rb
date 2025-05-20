class HostConfiguration < ApplicationRecord
  belongs_to :remote_host
  belongs_to :configurable, polymorphic: true

  validates :remote_host_id, uniqueness: { scope: [:configurable_type, :configurable_id] }

  scope :active, -> { where(active: true) }
end