require 'spec_helper'

describe ItemsController do
  let(:standup) { create(:standup) }
  let(:params) { {standup_id: standup.id} }
  before do
    request.session[:logged_in] = true
  end

  describe "#create" do
    let(:valid_params) { {item: attributes_for(:item).merge(standup_id: standup.to_param)} }

    it "should allow you to create an item" do
      expect {
        post :create, valid_params
      }.to change { standup.items.count }.by(1)
    end

    it "should redirect to root on success" do
      post :create, valid_params
      response.location.should == "http://test.host/standups/#{standup.id}"
    end

    it "should render new on failure" do
      post :create, item: {}
      response.should render_template 'items/new'
    end

    it "sets the post_id if one is provided" do
      standup_post = create(:post)
      expect {
        post :create, (valid_params.tap do |params|
          params[:item][:post_id] =  standup_post.to_param
        end)
      }.to change { standup_post.items.count }.by(1)
      response.should redirect_to(edit_post_path(standup_post))
    end
  end

  describe '#new' do
    it "should create a new Item object" do
      get :new, params
      assigns[:item].should be_new_record
      response.should render_template('items/new')
      response.should be_ok
    end

    it "should render the custom template for the kind if there is one" do
      get :new, params.merge(item: { kind: 'New face' })
      response.should render_template('items/new_new_face')
    end

    it "uses the params to create the new item so you can set defaults in the link" do
      get :new, params.merge(item: { kind: 'Interesting' })
      assigns[:item].kind.should == 'Interesting'
    end

    it "should set the author on the new Item" do
      session[:username] = "Barney Rubble"
      get :new, params
      item = assigns[:item]
      item.author.should == "Barney Rubble"
    end
  end

  describe "#index" do
    it "generates a hash of items by type" do
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:item, kind: "New face", standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)

      get :index, params
      assigns[:items]['New face'].should    == [ new_face ]
      assigns[:items]['Help'].should        == [ help ]
      assigns[:items]['Interesting'].should == [ interesting ]
      response.should be_ok
    end

    it "sorts the hash by created_at desc" do
      new_help = create(:item, created_at: 1.days.ago, standup: standup)
      old_help = create(:item, created_at: 4.days.ago, standup: standup)

      get :index, params
      assigns[:items]['Help'].should == [ old_help, new_help ]
    end

    it "does not include items which are associated with a post" do
      post = create(:post, standup: standup)
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:item, kind: "New face", standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)
      posted_item = create(:item, post: post, standup: standup)

      get :index, params
      assigns[:items]['New face'].should    == [ new_face ]
      assigns[:items]['Help'].should        == [ help ]
      assigns[:items]['Interesting'].should == [ interesting ]
      response.should be_ok
    end

    it "does not include items associated with other standups" do
      other_standup = create(:standup)
      standup_event = create(:item, kind: "Event", standup: standup, date: Date.tomorrow)
      other_standup_event = create(:item, kind: "Event", standup: other_standup, date: Date.tomorrow)

      get :index, params

      assigns[:items]['Event'].should include standup_event
      assigns[:items]['Event'].should_not include other_standup_event
    end
  end

  describe "#presentation" do
    it "renders the deck template" do
      get :presentation, params
      response.should render_template('deck')
    end

    it "loads the posts" do
      get :presentation, params
      assigns[:items].should be
    end

    it "only loads items from the current standup" do
      other_standup = create(:standup)
      other_standup_event = create(:item, standup: other_standup, date: Date.tomorrow, kind: "Event")
      standup_event = create(:item, standup: standup, date: Date.tomorrow, kind: "Event")

      get :presentation, params

      assigns[:items]['Event'].should include standup_event
      assigns[:items]['Event'].should_not include other_standup_event
    end
  end

  describe "#destroy" do
    it "should destroy the item" do
      request.env["HTTP_REFERER"] = "the url we came from"

      item = create(:item)
      delete :destroy, id: item.id
      Item.find_by_id(item.id).should_not be

      response.should redirect_to "the url we came from"
    end
  end

  describe "#edit" do
    it "should edit the item" do
      item = create(:item)
      get :edit, id: item.id
      assigns[:item].should == item
      response.should render_template 'items/new'
    end

    it "should render the custom template for the kind if there is one" do
      item = create(:item, kind: 'New face')
      get :edit, id: item.id
      response.should render_template('items/new_new_face')
    end
  end

  describe "#update" do
    it "should update the item" do
      item = create(:item)
      put :update, id: item.id, item: { title: "New Title" }
      item.reload.title.should == "New Title"
    end

    context "with a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the edit post page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }, redirect_to: '/foo'
        response.should redirect_to('/foo')
      end
    end

    context "without a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the standup page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }
        response.should redirect_to(item.standup)
      end
    end

    describe "when the item is invalid" do
      it "should render new" do
        item = create(:item)
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        response.should render_template('items/new')
      end

      it "should render a custom template if there is one" do
        item = create(:item, kind: 'New face')
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        response.should render_template('items/new_new_face')
      end
    end
  end
end
