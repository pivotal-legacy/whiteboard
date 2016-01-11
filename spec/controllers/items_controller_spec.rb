require 'rails_helper'

describe ItemsController do
  let(:standup) { create(:standup) }
  let(:params) { {standup_id: standup.id} }
  before do
    request.session[:logged_in] = true
    Timecop.freeze(Time.zone.local(2001,1,1, 20,00))
  end

  after do
    Timecop.return
  end

  describe "#create" do
    let(:valid_params) { {item: attributes_for(:item).merge(standup_id: standup.to_param), standup_id: standup.to_param} }

    it "should allow you to create an item" do
      expect {
        post :create, valid_params
      }.to change { standup.items.count }.by(1)
    end

    it "should redirect to root on success" do
      post :create, valid_params
      expect(response.location).to eq "http://test.host/standups/#{standup.id}"
      expect(response.headers["Item-Id"]).to eq "1"
    end

    it "should render new on failure" do
      post :create, item: {}, standup_id: standup.to_param
      expect(response).to render_template 'items/new'
    end

    it "sets the post_id if one is provided" do
      standup_post = create(:post)
      expect {
        post :create, (valid_params.tap do |params|
          params[:item][:post_id] =  standup_post.to_param
        end)
      }.to change { standup_post.items.count }.by(1)
      expect(response).to redirect_to(edit_post_path(standup_post))
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { post :create, valid_params }
    end
  end

  describe '#new' do

    it "should create a new Item object" do
      get :new, params
      expect(assigns[:item]).to be_new_record
      expect(response).to render_template('items/new')
      expect(response).to be_ok
    end

    it "should render the custom template for the kind if there is one" do
      get :new, params.merge(item: { kind: 'New face' })
      expect(response).to render_template('items/new_new_face')
    end

    it "uses the params to create the new item so you can set defaults in the link" do
      get :new, params.merge(item: { kind: 'Interesting' })
      expect(assigns[:item].kind).to eq 'Interesting'
    end

    it "should set the author on the new Item" do
      session[:username] = "Barney Rubble"
      get :new, params
      item = assigns[:item]
      expect(item.author).to eq "Barney Rubble"
    end

    it "should set the date of the item with respect to the local time zone" do
      get :new, params
      item = assigns[:item]
      expect(item.date).to eq Date.new(2001, 1, 1)
    end
  end

  describe "#index" do
    it "generates a hash of items by type" do
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:new_face, standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)

      get :index, params
      expect(assigns[:items]['New face']).to eq [ new_face ]
      expect(assigns[:items]['Help']).to eq [ help ]
      expect(assigns[:items]['Interesting']).to eq [ interesting ]
      expect(response).to be_ok
    end

    it "sorts the hash by date asc" do
      new_help = create(:item, date: 1.days.ago, standup: standup)
      old_help = create(:item, date: 4.days.ago, standup: standup)

      get :index, params
      expect(assigns[:items]['Help']).to eq [ old_help, new_help ]
    end

    it "does not include items which are associated with a post" do
      post = create(:post, standup: standup)
      help = create(:item, kind: "Help", standup: standup)
      new_face = create(:new_face, standup: standup)
      interesting = create(:item, kind: "Interesting", standup: standup)
      create(:item, post: post, standup: standup)

      get :index, params
      expect(assigns[:items]['New face']).to eq [ new_face ]
      expect(assigns[:items]['Help']).to eq [ help ]
      expect(assigns[:items]['Interesting']).to eq [ interesting ]
      expect(response).to be_ok
    end

    it "does not include items associated with other standups" do
      other_standup = create(:standup)
      standup_event = create(:item, kind: "Event", standup: standup, date: Time.zone.tomorrow)
      other_standup_event = create(:item, kind: "Event", standup: other_standup, date: Time.zone.tomorrow)

      get :index, params

      expect(assigns[:items]['Event']).to include standup_event
      expect(assigns[:items]['Event']).to_not include other_standup_event
    end
  end

  describe "#presentation" do
    it "renders the deck template" do
      get :presentation, params
      expect(response).to render_template('deck')
    end

    it "loads the posts" do
      get :presentation, params
      expect(assigns[:items]).to be
    end

    it "only loads items from the current standup" do
      other_standup = create(:standup)
      other_standup_event = create(:item, standup: other_standup, date: Time.zone.tomorrow, kind: "Event")
      standup_event = create(:item, standup: standup, date: Time.zone.tomorrow, kind: "Event")

      get :presentation, params

      expect(assigns[:items]['Event']).to include standup_event
      expect(assigns[:items]['Event']).to_not include other_standup_event
    end
  end

  describe "#destroy" do
    it "should destroy the item" do
      request.env["HTTP_REFERER"] = "the url we came from"

      item = create(:item)
      delete :destroy, id: item.id
      expect(Item.find_by_id(item.id)).to_not be

      expect(response).to redirect_to "the url we came from"
    end
  end

  describe "#edit" do
    it "should edit the item" do
      item = create(:item)
      get :edit, id: item.id
      expect(assigns[:item]).to eq item
      expect(response).to render_template 'items/new'
    end

    it "should render the custom template for the kind if there is one" do
      item = create(:new_face)
      get :edit, id: item.id
      expect(response).to render_template('items/new_new_face')
    end
  end

  describe "#update" do
    it "should update the item" do
      item = create(:item)
      put :update, id: item.id, item: { title: "New Title" }
      expect(item.reload.title).to eq "New Title"
    end

    context "with a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the edit post page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }, redirect_to: '/foo'
        expect(response).to redirect_to('/foo')
      end
    end

    context "without a redirect_to param" do
      let(:item) { create(:item, post: create(:post)) }

      it "redirects to the standup page" do
        put :update, id: item.id, post_id: item.post, item: { title: "New Title" }
        expect(response).to redirect_to(item.standup)
      end
    end

    describe "when the item is invalid" do
      it "should render new" do
        item = create(:item)
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        expect(response).to render_template('items/new')
      end

      it "should render a custom template if there is one" do
        item = create(:new_face)
        put :update, id: item.id, post_id: item.post, item: { title: "" }
        expect(response).to render_template('items/new_new_face')
      end
    end
  end
end
