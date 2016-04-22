require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @event = events(:feast)
    @participant = @user.participants.build(event_id: @event.id, i_am_going: true)
  end

  test "should be valid" do
    assert @participant.valid?
  end

  test "user id should be present" do
    @participant.user_id = nil
    assert_not @participant.valid?
  end
end
