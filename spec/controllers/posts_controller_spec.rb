require 'rails_helper'

describe PostsController do
  let(:standup) { create(:standup) }
  before do
    request.session[:logged_in] = true
    Timecop.freeze(Time.zone.local(2001,1,1, 20,00))
  end

  after do
    Timecop.return
  end

  describe "#create" do

    context "standup has one click posting enabled" do
      let(:standup_with_one_click_post) { create(:standup, one_click_post: true) }

      it "creates a post" do
        expect do
          post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        end.to change { Post.count }.by(1)
      end

      it "redirects to the standup" do
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        expect(response).to redirect_to(standup_path(standup_with_one_click_post))
      end

      it "adopts all items" do
        item = create(:item, standup: standup_with_one_click_post)
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        expect(standup_with_one_click_post.posts.last.items).to eq [item]
      end

      it "sends the email" do
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        expect(ActionMailer::Base.deliveries).to_not be_empty
        expect(ActionMailer::Base.deliveries.last.to).to eq [standup_with_one_click_post.to_address]
      end

      it "archives the post" do
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        expect(standup_with_one_click_post.posts.last).to be_archived
      end

      it "sets a flash notifying that the email was sent and the post was archived" do
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        expect(flash[:notice]).to eq("Successfully sent Standup email!")
      end

      it_behaves_like "an action occurring within the standup's timezone" do
        after { post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id }
      end

      context "when sending email fails" do
        before do
          allow(PostMailer).to receive(:send_to_all).and_raise("SOME ARBITRARY ERROR")
          post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
        end

        it "displays an error message that the email could not be sent" do
          expect(flash[:error]).to eq("Failed to send email. Please try again.")
        end

        it "raises an error and does not archive the post if sending email fails" do
          expect(standup_with_one_click_post.posts.last).to_not be_archived
        end

        it "redirects to the post" do
          post :create, post: {title: "Standup 12/12/12"}, standup_id: standup_with_one_click_post.id
          expect(response).to redirect_to(edit_post_path(standup_with_one_click_post.posts.last))
        end
      end
    end

    context "standup does NOT have one click posting enabled" do
      it "creates a post" do
        expect do
          post :create, post: {title: "Standup 12/12/12"}, standup_id: standup.id
        end.to change { Post.count }.by(1)
      end

      it "redirects to the post" do
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup.id
        expect(response).to redirect_to(edit_post_path(standup.posts.last))
      end

      it "adopts all items" do
        item = create(:item, standup: standup)
        post :create, post: {title: "Standup 12/12/12"}, standup_id: standup.id
        expect(assigns[:post].items).to eq [item]
      end

      it_behaves_like "an action occurring within the standup's timezone" do
        after { post :create, post: {title: "Standup 12/12/12"}, standup_id: standup.id }
      end
    end
  end

  describe "#edit" do
    let(:post) { create(:post) }

    it "shows the post for editing" do
      get :edit, id: post.id
      expect(assigns[:post]).to eq post
      expect(response).to be_ok
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :edit, id: post.id, standup_id: 1 }
    end
  end

  describe "#show" do
    let(:post) { create(:post) }

    it "shows the post" do
      get :show, id: post.id
      expect(assigns[:post]).to eq post
      expect(response).to be_ok
      expect(response.body).to include(post.title)
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :show, id: post.id, standup_id: 1 }
    end
  end

  describe "#update" do
    let(:post) { create(:post) }

    it "updates the post" do
      put :update, id: post.id, post: {title: "New Title", from: "Matthew & Matthew"}
      expect(post.reload.title).to eq "New Title"
      expect(post.from).to eq "Matthew & Matthew"
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { put :update, id: post.id, post: {title: "New Title", from: "Matthew & Matthew"}, standup_id: 1 }
    end
  end

  describe "#index" do
    let(:standup) { create(:standup) }

    it "renders an index of posts" do
      post = create(:post, standup: standup)
      get :index, standup_id: standup.id
      expect(assigns[:posts]).to eq [post]
    end

    it "does not include archived" do
      unarchived_post = create(:post, standup: standup)
      create(:post, archived: true, standup: standup)
      get :index, standup_id: standup.id
      expect(assigns[:posts]).to eq [unarchived_post]
    end

    it "does not include posts associated with other standups" do
      standup_post = create(:post, standup: standup)
      create(:post, standup: create(:standup))
      get :index, standup_id: standup.id
      expect(assigns[:posts]).to eq [standup_post]
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :index, standup_id: standup.id }
    end
  end

  describe "#archived" do
    let(:standup) { create(:standup) }

    it "lists the archived posts" do
      create(:post, standup: standup)
      archived_post = create(:post, archived: true, standup: standup)

      get :archived, standup_id: standup.id

      expect(assigns[:posts]).to match [archived_post]
      expect(response).to render_template('archived')
      expect(response.body).to include(archived_post.title)
    end

    it "lists the archived posts associated with the standup" do
      standup_post = create(:post, standup: standup, archived: true)
      other_post = create(:post, standup: create(:standup), archived: true)

      get :archived, standup_id: standup.id

      expect(assigns[:posts]).to match [standup_post]
      expect(response.body).to include(standup_post.title)
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { get :archived, standup_id: standup.id }
    end
  end

  describe "#send_email" do
    it "sends the email" do
      post = create(:post, items: [create(:item)])
      put :send_email, id: post.id
      expect(response).to redirect_to(edit_post_path(post))
      expect(ActionMailer::Base.deliveries.last.to).to eq [post.standup.to_address]
    end

    it "does not allow resending" do
      post = create(:post, sent_at: Time.now)
      put :send_email, id: post.id
      expect(response).to redirect_to(edit_post_path(post))
      expect(flash[:error]).to eq "The post has already been emailed"
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      let(:post) { create(:post, sent_at: Time.now) }
      after { put :send_email, id: post.id, standup_id: 1 }
    end
  end

  describe "#post_to_blog" do
    before do
      @fakeWordpress = double("wordpress service", :"minimally_configured?" => true)
      allow(Rails.application.config).to receive(:blogging_service) { @fakeWordpress }

      @item = create(:item, public: true)
      @post = create(:post, items: [@item])
    end

    it "sets the post data on the blog post object" do
      allow(@fakeWordpress).to receive(:send!)
      blog_post = OpenStruct.new
      expect(BlogPost).to receive(:new).and_return(blog_post)

      put :post_to_blog, id: @post.id

      expect(blog_post.title).to eq @post.title
      expect(blog_post.body).to be
    end

    it "posts to wordpress" do
      expect(@fakeWordpress).to receive(:send!)

      put :post_to_blog, id: @post.id

      expect(response).to redirect_to(edit_post_path(@post))
    end

    it "marks it as posted" do
      allow(@fakeWordpress).to receive(:send!)

      put :post_to_blog, id: @post.id

      expect(@post.reload.blogged_at).to be
    end

    it "records the published post id" do
      allow(@fakeWordpress).to receive(:send!).and_return("1234")

      put :post_to_blog, id: @post.id

      expect(@post.reload.blog_post_id).to eq "1234"
    end

    it "doesn't post to wordpress multiple times" do
      @post.blogged_at = Time.now
      @post.save!

      put :post_to_blog, id: @post.id

      expect(response).to redirect_to(edit_post_path(@post))
      expect(flash[:error]).to eq "The post has already been blogged"
    end

    context 'unsuccessful post' do

      before do
        expect(@fakeWordpress).to receive(:send!).and_raise(XMLRPC::FaultException.new(123, "Wrong size. Was 180, should be 131"))
        put :post_to_blog, id: @post.id
      end

      it "catches XMLRPC::FaultException and displays error message" do
        expect(flash[:error]).to eq "While posting to the blog, the service reported the following error: 'Wrong size. Was 180, should be 131', please repost."
        expect(response).to redirect_to(edit_post_path(@post))
      end

      it "it doesn't set blogged_at for an unsuccessful post" do
        expect(@post.blogged_at).to be_nil
      end
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { put :post_to_blog, id: @post.id, standup_id: 1 }
    end
  end

  describe "#archive" do
    let(:post) { create(:post) }

    it "archives the post" do
      put :archive, id: post.id
      expect(post.reload).to be_archived
      expect(response).to redirect_to post.standup
    end

    it "redirects back to index with a flash if it fails" do
      put :archive, id: 1234
      expect(response).to be_not_found
    end

    it_behaves_like "an action occurring within the standup's timezone" do
      after { put :archive, id: post.id, standup_id: 6 }
    end
  end
end
