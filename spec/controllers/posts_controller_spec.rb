require 'spec_helper'

describe PostsController do
  let(:standup) { create(:standup) }
  before do
    request.session[:logged_in] = true
  end

  describe "#create" do
    it "creates a post" do
      expect do
        post :create, post: { title: "Standup 12/12/12"}, standup_id: standup.id
      end.should change { Post.count }.by(1)
      response.should be_redirect
    end

    it "adopts all items" do
      item = create(:item)
      post :create, post: { title: "Standup 12/12/12"}, standup_id: standup.id
      assigns[:post].items.should == [ item ]
    end
  end

  describe "#edit" do
    it "shows the post for editing" do
      post = create(:post)
      get :edit, id: post.id
      assigns[:post].should == post
      response.should be_ok
    end
  end

  describe "#show" do
    it "shows the post" do
      post = create(:post)
      get :show, id: post.id
      assigns[:post].should == post
      response.should be_ok
      response.body.should include(post.title)
    end
  end

  describe "#update" do
    it "updates the post" do
      post = create(:post)
      put :update, id: post.id, post: { title: "New Title", from: "Matthew & Matthew" }
      post.reload.title.should == "New Title"
      post.from.should == "Matthew & Matthew"
    end
  end

  describe "#index" do
    let(:standup) { create(:standup) }

    it "renders an index of posts" do
      post = create(:post, standup: standup)
      get :index, standup_id: standup.id
      assigns[:posts].should == [ post ]
    end

    it "does not include archived" do
      unarchived_post = create(:post, standup: standup)
      create(:post, archived: true, standup: standup)
      get :index, standup_id: standup.id
      assigns[:posts].should == [ unarchived_post ]
    end

    it "does not include posts associated with other standups" do
      standup_post = create(:post, standup: standup)
      create(:post, standup: create(:standup))
      get :index, standup_id: standup.id
      assigns[:posts].should == [ standup_post ]
    end
  end

  describe "#archived" do
    let(:standup) { create(:standup) }

    it "lists the archived posts" do
      create(:post, standup: standup)
      archived_post = create(:post, archived: true, standup: standup)

      get :archived, standup_id: standup.id

      assigns[:posts].should =~ [ archived_post  ]
      response.should render_template('archived')
      response.body.should include(archived_post.title)
    end

    it "lists the archived posts associated with the standup" do
      standup_post = create(:post, standup: standup, archived: true)
      other_post = create(:post, standup: create(:standup), archived: true)

      get :archived, standup_id: standup.id

      assigns[:posts].should =~ [ standup_post  ]
      response.body.should include(standup_post.title)
    end
  end

  describe "#send" do
    it "sends the email" do
      post = create(:post, items: [ create(:item) ] )
      put :send_email, id: post.id
      response.should redirect_to(edit_post_path(post))
      ActionMailer::Base.deliveries.last.to.should == [post.standup.to_address]
    end

    it "does not allow resending" do
      post = create(:post, sent_at: Time.now )
      put :send_email, id: post.id
      response.should redirect_to(edit_post_path(post))
      flash[:error].should == "The post has already been emailed"
    end
  end

  describe "#post_to_blog" do
    class FakeWordpress
      attr_reader :post_opts
      def post(opts)
        @post_opts = opts
      end
    end

    before do
      @fakeWordpress = FakeWordpress.new
      WordpressService.stub(:new) { @fakeWordpress }
      ENV['WORDPRESS_USER'], ENV['WORDPRESS_PASSWORD'], ENV['WORDPRESS_BLOG'] = "foo", "bar", "baz"

      @item = create(:item, public: true)
      @post = create(:post, items: [@item])
    end

    it "posts to wordpress" do
      put :post_to_blog, id: @post.id
      @fakeWordpress.post_opts[:title].should == @post.title
      @fakeWordpress.post_opts[:body].should include(@item.title)

      response.should redirect_to(edit_post_path(@post))
    end

    it "marks it as posted" do
      put :post_to_blog, id: @post.id
      @post.reload.blogged_at.should be
    end

    it "doesn't post to wordpress multiple times" do
      @post.blogged_at = Time.now
      @post.save!

      put :post_to_blog, id: @post.id

      response.should redirect_to(edit_post_path(@post))
      flash[:error].should == "The post has already been blogged"
    end
  end

  describe "#archive" do
    let(:post) { create(:post) }

    it "archives the post" do
      put :archive, id: post.id
      post.reload.should be_archived
      response.should redirect_to post.standup
    end

    it "redirects back to index with a flash if it fails" do
      put :archive, id: 1234
      response.should be_not_found
    end
  end
end
