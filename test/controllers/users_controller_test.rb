require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @admin_user = users(:three)
    @official_user = users(:two)
    @resident_user = users(:one)
    @resident_user_2 = users(:four)
  end

  test "should get index if admin or official" do
    sign_in @admin_user
    get users_url
    assert_response :success
    sign_out @admin_user
    sign_in @official_user
    get users_url
    assert_response :success
  end

  test "should not get index if resident" do
    sign_in @resident_user
    get users_url
    assert_response :redirect
  end

  test "should get new if admin" do
    sign_in @admin_user
    get new_user_url
    assert_response :success
  end

  test "should not get new if resident or official" do
    sign_in @official_user
    get new_user_url
    assert_response :redirect
    sign_out @official_user
    sign_in @resident_user
    get new_user_url
    assert_response :redirect
  end

  test "should create user" do
    sign_in @admin_user
    assert_difference('User.count') do
      post users_url, params: { user: { first_name: 'Sally', last_name: "Thompson", address1: '123 West St.', city: 'Omaha', state: 'NE', zip: '50099', phone: '333-444-5555', username: 'test_username', active: 'true', role: 'resident', email: 'test_email@email.com', password: 'test123' } }
    end
    assert_redirected_to user_url(User.last)
  end

  test "should show user if admin or official" do
    sign_in @admin_user
    get user_url(@official_user)
    assert_response :success
    sign_out @admin_user
    sign_in @official_user
    get user_url(@resident_user_2)
    assert_response :success
  end

  test "should not show user if resident user" do
    sign_in @resident_user
    get user_url(@resident_user_2)
    assert_response :redirect
  end

  test "should not show user if invalid user id passed" do
    sign_in @admin_user
    get user_url(2000)
    assert_response :redirect
  end

  test "should get edit if admin user" do
    sign_in @admin_user
    get edit_user_url(@official_user)
    assert_response :success
  end

  test "should not get edit if admin user and invalid user id passed" do
    sign_in @admin_user
    get edit_user_url(2000)
    assert_response :redirect
  end

  test "should not get edit if official or resident user" do
    sign_in @official_user
    get edit_user_url(@resident_user_2)
    assert_response :redirect
    sign_out @official_user
    sign_in @resident_user
    get edit_user_url(@resident_user_2)
    assert_response :redirect
  end

  test "should update user" do
    sign_in @admin_user
    patch user_url(@official_user), params:  { user: { first_name: 'Charles', last_name: @official_user.last_name, address1: @official_user.address1, address2: @official_user.address2, city: @official_user.city, state: @official_user.state, zip: @official_user.zip, phone: @official_user.phone, username: @official_user.username, active: @official_user.active, role: @official_user.role, email: @official_user.email, password: @official_user.password } }
    assert_redirected_to user_url(@official_user)
  end

  test "should populate deactivated_at date when user is deactivated" do
    sign_in @admin_user
    patch user_url(@official_user), params:  { user: { first_name: 'Charles', last_name: @official_user.last_name, address1: @official_user.address1, address2: @official_user.address2, city: @official_user.city, state: @official_user.state, zip: @official_user.zip, phone: @official_user.phone, username: @official_user.username, active: false, role: @official_user.role, email: @official_user.email, password: @official_user.password } }
    @official_user.reload
    assert_equal @official_user.active, false
    assert_not_nil @official_user.deactivated_at
  end

  test "should show nil for deactivated_at when user is active" do
    sign_in @admin_user
    patch user_url(@official_user), params:  { user: { first_name: 'Charles', last_name: @official_user.last_name, address1: @official_user.address1, address2: @official_user.address2, city: @official_user.city, state: @official_user.state, zip: @official_user.zip, phone: @official_user.phone, username: @official_user.username, active: true, role: @official_user.role, email: @official_user.email, password: @official_user.password } }
    @official_user.reload
    assert_equal @official_user.active, true
    assert_nil @official_user.deactivated_at
  end

  test "should return record on username search" do
    sign_in @admin_user
    get users_url
    assert_response :success

    @search_type = "Username"
    @search_term = @resident_user.username

    get '/users?search_type=' + @search_type + '&search_term=' + @search_term + '&commit=Search'
    assert_response :success
    assert_select "th", text: "Username"
  end

  test "should return record on name search" do
    sign_in @admin_user
    get users_url
    assert_response :success

    @search_type = "Name"
    @search_term = @resident_user.first_name

    get '/users?search_type=' + @search_type + '&search_term=' + @search_term + '&commit=Search'
    assert_response :success
    assert_select "th", text: "Username"
  end

  test "should return no records on search where none exist" do
    sign_in @admin_user
    get users_url
    assert_response :success

    @search_type = "Username"
    @search_term = "fakeusername"

    get '/users?search_type=' + @search_type + '&search_term=' + @search_term + '&commit=Search'
    assert_response :success
    assert_select "p.info-message", text: "No users found."
  end

  test "should show all users on 'clear' button click" do
    sign_in @admin_user
    get users_url
    assert_response :success

    @search_type = "Username"
    @search_term = @resident_user.username

    get '/users?search_type=' + @search_type + '&search_term=' + @search_term + '&commit=Search'
    assert_response :success
    get '/users?search_type=' + @search_type + '&search_term=' + @search_term + '&commit=Clear'
    assert_response :redirect
    follow_redirect!
    assert_select "tbody tr", 5
  end

end