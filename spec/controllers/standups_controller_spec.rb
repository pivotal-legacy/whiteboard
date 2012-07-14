require 'spec_helper'

describe StandupsController do
  let(:standup) { create(:standup) }

  before do
    request.session[:logged_in] = true
  end

  describe "#create" do
    context "with valid params" do
      it "creates a standup" do
        expect do
          post :create, standup: { title: "Berlin", to_address: "berlin+standup@pivotallabs.com" }
        end.should change { Standup.count }.by(1)
        response.should be_redirect
      end
    end

    context "with invalid params" do
      it "creates a standup" do
        expect do
          post :create, standup: { }
        end.should change { Standup.count }.by(0)
        response.should render_template 'standups/new'
      end
    end
  end

  describe "#new" do
    it "renders the new standups template" do
      get :new
      response.should be_ok
      response.should render_template 'standups/new'
    end
  end

  describe "#index" do
    it "renders an index of standups" do
      standup = create(:standup)
      get :index
      response.should be_ok
      assigns[:standups].should == [ standup ]
    end
  end

  describe "#edit" do
    it "shows the post for editing" do
      get :edit, id:  standup.id
      assigns[:standup].should == standup
      response.should be_ok
    end
  end

  describe "#show" do
    it "redirects to the items page of the standup" do
      get :show, id: standup.id
      response.body.should redirect_to standup_items_path(standup)
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the post" do
        put :update, id: standup.id, standup: { title: "New Title" }
        standup.reload.title.should == "New Title"
      end
    end

    context "with invalid params" do
      it "does not update the post" do
        put :update, id: standup.id, standup: { title: nil }
        standup.reload.title.should == standup.title
        response.should render_template 'standups/edit'
      end
    end
  end

  describe "#destroy" do
    let!(:standup) { create(:standup) }

    it "destroys the specified standup" do
      expect {
        post :destroy, id: standup.id
      }.to change(Standup, :count).by(-1)
      response.should redirect_to standups_path
    end
  end
end
