require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @user       = users(:michael)
    @event = Event.new(name: "Example Event", date_start: "2017-01-01", user_id: @user.id)
  end

  test "should be valid" do
    assert @event.valid?
  end
  
  test "name should be present" do
    @event.name = "     "
    assert_not @event.valid?
  end

  test "date_start should be present" do
    @event.date_start = nil
    assert_not @event.valid?
  end
  
  test "user_id should be present" do
    @event.user_id = nil
    assert_not @event.valid?
  end
end
