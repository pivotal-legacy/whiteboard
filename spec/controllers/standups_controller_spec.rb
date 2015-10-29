require 'rails_helper'

describe StandupsController do
  let(:standup) { create(:standup) }

  before do
    request.session[:logged_in] = true
  end

  describe "#create" do
    context "with valid params" do
      it "creates a standup" do
        expect do
          post :create, standup: {title: "Berlin", to_address: "berlin+standup@pivotallabs.com"}
        end.to change { Standup.count }.by(1)
        expect(response).to be_redirect
      end
    end

    context "with invalid params" do
      it "creates a standup" do
        expect do
          post :create, standup: {}
        end.to change { Standup.count }.by(0)
        expect(response).to render_template 'standups/new'
      end
    end
  end

  describe "#new" do
    it "renders the new standups template" do
      get :new
      expect(response).to be_ok
      expect(response).to render_template 'standups/new'
    end
  end

  describe "#index" do
    context 'when the user is logged in' do
      it 'renders an index of all of the standups' do
        standup1 = create(:standup)
        standup2 = create(:standup)

        get :index

        expect(response).to be_ok
        expect(assigns[:standups]).to include(standup1, standup2)
      end
    end

    it 'sorts all standups alphabetically' do
      second = create(:standup, title: 'Bravo Badger')
      first = create(:standup, title: 'Alpha Aardvark')
      fourth = create(:standup, title: 'ZULU Zebra')
      third = create(:standup, title: 'Zooloo Zebra')

      get :index

      expect(response).to be_ok
      expect(assigns[:standups]).to eq [first, second, third, fourth]
    end
  end

  describe "#edit" do
    it "shows the post for editing" do
      get :edit, id: standup.id
      expect(assigns[:standup]).to eq standup
      expect(response).to be_ok
    end
  end

  describe "#show" do
    it "redirects to the items page of the standup" do
      get :show, id: standup.id
expect(response.body).to redirect_to standup_items_path(standup)
    end

    it 'saves standup id to cookie' do
      get :show, id: standup.id
      expect(session[:last_visited_standup]).to eq(standup.id.to_s)
    end

    it 'shows error and redirects to standups#index when standup does not exist' do
      get :show, id: 12831
      expect(flash[:error]).to eq('A standup with the ID 12831 does not exist.')
      expect(response).to redirect_to(standups_path)
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the post" do
        put :update, id: standup.id, standup: {title: "New Title"}
        expect(standup.reload.title).to eq "New Title"
      end
    end

    context "with invalid params" do
      it "does not update the post" do
        put :update, id: standup.id, standup: {title: nil}
        expect(standup.reload.title).to eq standup.title
        expect(response).to render_template 'standups/edit'
      end
    end
  end

  describe "#destroy" do
    let!(:standup) { create(:standup) }

    it "destroys the specified standup" do
      expect {
        post :destroy, id: standup.id
      }.to change(Standup, :count).by(-1)
      expect(response).to redirect_to standups_path
    end
  end

  describe '#last_or_index' do
    context 'when user has never visited whiteboard' do
      it 'redirects to index' do
        session[:last_visited_standup] = nil

        get :last_or_index

        expect(response).to redirect_to(standups_path)
      end
    end

    context 'when user has previously visited a standup' do
      it 'redirects to index' do
        session[:last_visited_standup] = standup.id

        get :last_or_index

        expect(response).to redirect_to(standup_path(standup.id))
      end

      it 'does not redirect to a standup that no longer exists' do
        session[:last_visited_standup] = 4000
        standup = Standup.find_by(id: 4000)
        standup.destroy if standup

        get :last_or_index

        expect(response).to redirect_to(standups_path)
      end
    end
  end

end
