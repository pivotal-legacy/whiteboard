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
      end.to change { Post.count }.by(1)
      response.should be_redirect
    end

    it "adopts all items" do
      item = create(:help, standup: standup)
      post :create, post: { title: "Standup 12/12/12"}, standup_id: standup.id
      assigns[:post].items.should == [ item ]
    end
  end

  describe "#edit" do
    let(:post) { create(:post) }

    it "shows the post for editing" do
      get :edit, id: post.id
      assigns[:post].should == post
      response.should be_ok
    end

    it 'should not box the page contents' do
      controller.should_not_receive(:boxed)
      get :edit, id: post.id
    end
  end

  describe "#show" do
    let(:post) { create(:post) }

    it "shows the post" do
      get :show, id: post.id
      assigns[:post].should == post
      response.should be_ok
      response.body.should include(post.title)
    end

    it 'should not box the page contents' do
      controller.should_not_receive(:boxed)
      get :show, id: post.id
    end
  end

  describe "#update" do
    let(:post) { create(:post) }

    it "updates the post" do
      put :update, id: post.id, post: { title: "New Title", from: "Matthew & Matthew" }
      post.reload.title.should == "New Title"
      post.from.should == "Matthew & Matthew"
    end

    it 'should not box the page contents' do
      controller.should_not_receive(:boxed)
      put :update, id: post.id, post: { title: "New Title", from: "Matthew & Matthew" }
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
    before do
      @fakeWordpress = double("wordpress service", :"minimally_configured?" => true)
      Rails.application.config.stub(:blogging_service) { @fakeWordpress }

      @item = create(:item, public: true)
      @post = create(:post, items: [@item])
    end

    it "sets the post data on the blog post object" do
      @fakeWordpress.stub(:send!)
      blog_post = OpenStruct.new
      BlogPost.should_receive(:new).and_return(blog_post)

      put :post_to_blog, id: @post.id

      blog_post.title.should == @post.title
      blog_post.body.should be
    end

    it "posts to wordpress" do
      @fakeWordpress.should_receive(:send!)

      put :post_to_blog, id: @post.id

      response.should redirect_to(edit_post_path(@post))
    end

    it "marks it as posted" do
      @fakeWordpress.stub(:send!)

      put :post_to_blog, id: @post.id

      @post.reload.blogged_at.should be
    end

    it "records the published post id" do
      @fakeWordpress.stub(:send!).and_return("1234")

      put :post_to_blog, id: @post.id

      @post.reload.blog_post_id.should eq "1234"
    end

    it "doesn't post to wordpress multiple times" do
      @post.blogged_at = Time.now
      @post.save!

      put :post_to_blog, id: @post.id

      response.should redirect_to(edit_post_path(@post))
      flash[:error].should == "The post has already been blogged"
    end

    context 'unsuccessful post' do

      before do
        @fakeWordpress.should_receive(:send!).and_raise(XMLRPC::FaultException.new(123, "Wrong size. Was 180, should be 131"))
        put :post_to_blog, id: @post.id
      end

      it "catches XMLRPC::FaultException and displays error message" do
        flash[:error].should == "While posting to the blog, the service reported the following error: 'Wrong size. Was 180, should be 131', please repost."
        response.should redirect_to(edit_post_path(@post))
      end

      it "it doesn't set blogged_at for an unsuccessful post" do
        expect(@post.blogged_at).to be_nil
      end
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
