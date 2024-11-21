require 'sidekiq-scheduler'

class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    MarkCartAsAbandoned.call
  end
end
