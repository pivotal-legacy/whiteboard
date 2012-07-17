require 'spec_helper'

describe ItemsController do
  let(:standup) { create(:standup) }
  let(:params) { {standup_id: standup.id} }
  before do
    request.session[:logged_in] = true
  end

  describe "#create" do
    it "should allow you to create an item" do
      expect {
        post :create, params.merge(item: attributes_for(:item))
      }.should change { standup.items.count }.by(1)
    end

    it "should redirect to root on success" do
      post :create, params.merge(item: attributes_for(:item))
      response.location.should == "http://test.host/standups/#{standup.id}"
    end

    it "should render new on failure" do
      post :create, params.merge(item: {})
      response.should render_template 'items/new'
    end

    it "sets the post_id if one is provided" do
      standup_post = create(:post)
      expect {
        post :create, params.merge(item: attributes_for(:item, post_id: standup_post.id))
      }.should change { standup_post.items.count }.by(1)
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
  end

  describe "#destroy" do
    it "should destroy the item" do
      item = create(:item)
      standup = item.standup
      delete :destroy, id: item.id
      Item.find_by_id(item.id).should_not be
      response.should redirect_to(standup)
    end

    it "redirects to the post if there is one" do
      item = create(:item, post: create(:post))
      delete :destroy, id: item.id, post_id: item.post
      Item.find_by_id(item.id).should_not be
      response.should redirect_to(edit_post_path(item.post))
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

    context "with a post" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the edit post page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }
        response.should redirect_to(edit_post_path(item.post))
      end
    end

    context "without a post" do
      let(:item) { create(:item, post: nil) }

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
