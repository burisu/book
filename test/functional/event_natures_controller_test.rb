require 'test_helper'

class EventNaturesControllerTest < ActionController::TestCase
  setup do
    @event_nature = event_natures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_natures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_nature" do
    assert_difference('EventNature.count') do
      post :create, event_nature: { comment: @event_nature.comment, name: @event_nature.name }
    end

    assert_redirected_to event_nature_path(assigns(:event_nature))
  end

  test "should show event_nature" do
    get :show, id: @event_nature
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_nature
    assert_response :success
  end

  test "should update event_nature" do
    put :update, id: @event_nature, event_nature: { comment: @event_nature.comment, name: @event_nature.name }
    assert_redirected_to event_nature_path(assigns(:event_nature))
  end

  test "should destroy event_nature" do
    assert_difference('EventNature.count', -1) do
      delete :destroy, id: @event_nature
    end

    assert_redirected_to event_natures_path
  end
end
