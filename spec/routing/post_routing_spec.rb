require 'rails_helper'

describe PostsController do
  it "routes send_email" do
    expect(put("posts/1/send_email")).to route_to("posts#send_email", id: '1')
  end

  it "routes to post_to_blog" do
    expect(put("posts/1/post_to_blog")).to route_to("posts#post_to_blog", id: '1')
  end

  it "routes to archive" do
    expect(put("posts/1/archive")).to route_to("posts#archive", id: "1")
  end

  it "routes to archived" do
    expect(get('standups/2/posts/archived')).to route_to("posts#archived", standup_id: '2')
  end
end
