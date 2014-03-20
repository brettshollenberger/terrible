class NotPermitted < StandardError
  def message
    "You are not permitted to view that resource"
  end
end
