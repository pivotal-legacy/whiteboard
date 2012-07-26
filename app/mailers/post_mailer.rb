class PostMailer < ActionMailer::Base
  def send_to_all(post, addresses)
    @post = post
    mail  :to => Array(addresses),
          :subject => post.title_for_email,
          :from => "#{post.from} <noreply@pivotallabs.com>"
  end
end
