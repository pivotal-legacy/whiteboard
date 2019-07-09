require 'rails_helper'

describe PostsController do
  let(:standup) { create(:standup) }
  before do
    request.session[:logged_in] = true
    Timecop.freeze(Time.zone.local(2001, 1, 1, 20, 00))
  end

  after do
    Timecop.return
  end

  describe "#create" do
    let(:standup) { create(:standup) }

    it "creates a post" do
      expect {
        post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      }.to change { Post.count }.by(1)
    end

    it "redirects to the standup" do
      post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      expect(response).to redirect_to(standup_path(standup))
    end

    it "adopts all items" do
      item = create(:item, standup: standup)
      post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      expect(standup.posts.last.items).to eq [item]
    end

    it "sends the email" do
      post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      expect(ActionMailer::Base.deliveries).to_not be_empty
      expect(ActionMailer::Base.deliveries.last.to).to eq [standup.to_address]
    end

    it "archives the post" do
      post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      expect(standup.posts.last).to be_archived
    end

    it "sets a flash notifying that the email was sent and the post was archived" do
      post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      expect(flash[:notice]).to eq("Successfully sent Standup email!")
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id} }
    end

    context "when sending email fails" do
      before do
        allow(PostMailer).to receive(:send_to_all).and_raise("SOME ARBITRARY ERROR")
        post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
      end

      it "displays an error message that the email could not be sent" do
        expect(flash[:error]).to eq("Failed to send email. Please try again.")
      end

      it "raises an error and does not archive the post if sending email fails" do
        expect(standup.posts.last).to_not be_archived
      end

      it "redirects to the post" do
        post :create, params: {post: {title: "Standup 12/12/12"}, standup_id: standup.id}
        expect(response).to redirect_to(edit_post_path(standup.posts.last))
      end
    end
  end

  describe "#edit" do
    let(:post) { create(:post) }

    it "shows the post for editing" do
      get :edit, params: {id: post.id}
      expect(assigns[:post]).to eq post
      expect(response).to be_ok
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :edit, params: {id: post.id, standup_id: 1} }
    end
  end

  describe "#show" do
    let(:post) { create(:post) }

    it "shows the post" do
      get :show, params: {id: post.id}
      expect(assigns[:post]).to eq post
      expect(response).to be_ok
      expect(response.body).to include(post.title)
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :show, params: {id: post.id, standup_id: 1} }
    end
  end

  describe "#update" do
    let(:post) { create(:post) }

    it "updates the post" do
      put :update, params: {id: post.id, post: {title: "New Title", from: "Matthew & Matthew"}}
      expect(post.reload.title).to eq "New Title"
      expect(post.from).to eq "Matthew & Matthew"
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { put :update, params: {id: post.id, post: {title: "New Title", from: "Matthew & Matthew"}, standup_id: 1} }
    end
  end

  describe "#index" do
    let(:standup) { create(:standup) }

    it "renders an index of posts" do
      post = create(:post, standup: standup)
      get :index, params: {standup_id: standup.id}
      expect(assigns[:posts]).to eq [post]
    end

    it "does not include archived" do
      unarchived_post = create(:post, standup: standup)
      create(:post, archived: true, standup: standup)
      get :index, params: {standup_id: standup.id}
      expect(assigns[:posts]).to eq [unarchived_post]
    end

    it "does not include posts associated with other standups" do
      standup_post = create(:post, standup: standup)
      create(:post, standup: create(:standup))
      get :index, params: {standup_id: standup.id}
      expect(assigns[:posts]).to eq [standup_post]
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :index, params: {standup_id: standup.id} }
    end
  end

  describe "#archived" do
    let(:standup) { create(:standup) }

    it "lists the archived posts" do
      create(:post, standup: standup)
      archived_post = create(:post, archived: true, standup: standup)

      get :archived, params: {standup_id: standup.id}

      expect(assigns[:posts]).to match [archived_post]
      expect(response).to render_template('archived')
      expect(response.body).to include(archived_post.title)
    end

    it "lists the archived posts associated with the standup" do
      standup_post = create(:post, standup: standup, archived: true)
      other_post = create(:post, standup: create(:standup), archived: true)

      get :archived, params: {standup_id: standup.id}

      expect(assigns[:posts]).to match [standup_post]
      expect(response.body).to include(standup_post.title)
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :archived, params: {standup_id: standup.id} }
    end
  end

  describe "#send_email" do
    it "sends the email" do
      post = create(:post, items: [create(:item)])
      put :send_email, params: {id: post.id}
      expect(response).to redirect_to(edit_post_path(post))
      expect(ActionMailer::Base.deliveries.last.to).to eq [post.standup.to_address]
    end

    it "does not allow resending" do
      post = create(:post, sent_at: Time.now)
      put :send_email, params: {id: post.id}
      expect(response).to redirect_to(edit_post_path(post))
      expect(flash[:error]).to eq "The post has already been emailed"
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      let(:post) { create(:post, sent_at: Time.now) }
      after { put :send_email, params: {id: post.id, standup_id: 1} }
    end
  end

  describe "#archive" do
    let(:post) { create(:post) }

    it "archives the post" do
      put :archive, params: {id: post.id}
      expect(post.reload).to be_archived
      expect(response).to redirect_to post.standup
    end

    it "redirects back to index with a flash if it fails" do
      put :archive, params: {id: 1234}
      expect(response).to be_not_found
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { put :archive, params: {id: post.id, standup_id: 6 } }
    end
  end
end
