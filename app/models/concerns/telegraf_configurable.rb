module TelegrafConfigurable
  extend ActiveSupport::Concern

  included do
    has_many :host_configurations, as: :configurable, dependent: :destroy
    has_many :remote_hosts, through: :host_configurations
    belongs_to :alert_rule, optional: true

    validates :interval, presence: true, format: {
      with: /\A\d+[smh]\z/,
      message: "must be in format: 10s, 1m, 1h"
    }
    validates :name, presence: true, uniqueness: true

    after_save -> { TelegrafConfigService.generate(self, config) }
    after_destroy -> { TelegrafConfigService.remove(self) }

    scope :active, -> { where(active: true) }
  end

  def config_type
    self.class.name.demodulize.underscore.gsub('telegraf_', '').gsub('_config', '')
  end
end