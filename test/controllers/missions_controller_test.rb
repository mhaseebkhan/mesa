require 'test_helper'

class MissionsControllerTest < ActionController::TestCase
  setup do
    @mission = missions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:missions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mission" do
    assert_difference('Mission.count') do
      post :create, mission: { brief: @mission.brief, build_intent: @mission.build_intent, from_date: @mission.from_date, is_authorized: @mission.is_authorized, place: @mission.place, shared_motivation: @mission.shared_motivation, status: @mission.status, time: @mission.time, title: @mission.title, to_date: @mission.to_date }
    end

    assert_redirected_to mission_path(assigns(:mission))
  end

  test "should show mission" do
    get :show, id: @mission
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mission
    assert_response :success
  end

  test "should update mission" do
    patch :update, id: @mission, mission: { brief: @mission.brief, build_intent: @mission.build_intent, from_date: @mission.from_date, is_authorized: @mission.is_authorized, place: @mission.place, shared_motivation: @mission.shared_motivation, status: @mission.status, time: @mission.time, title: @mission.title, to_date: @mission.to_date }
    assert_redirected_to mission_path(assigns(:mission))
  end

  test "should destroy mission" do
    assert_difference('Mission.count', -1) do
      delete :destroy, id: @mission
    end

    assert_redirected_to missions_path
  end
end
