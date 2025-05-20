class ExecuteResponseWorker
  include Sidekiq::Worker
  sidekiq_options queue: :responses, retry: 3

  def perform(response_id, metric_value)
    response = AutomatedResponse.find(response_id)
    result = response.execute
    
    ResponseExecution.create!(
      automated_response: response,
      status: result[:success] ? 'success' : 'failure',
      result: result[:message],
      executed_at: Time.current
    )
  rescue => e
    ResponseExecution.create!(
      automated_response: response,
      status: 'failure',
      result: "Error: #{e.message}",
      executed_at: Time.current
    )
    raise e
  end
end