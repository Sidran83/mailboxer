class RepliesMailbox < ApplicationMailbox
  MATCHER = /reply-(.+)@reply.example.com/i

  # before_processing :ensure_user

  def process
    return if user.nil?

    discussion.comments.create(
      user: user,
      body: mail.decoded
    )
  end

  def user
    @user = User.find_by(email: mail.from)
  end

  def discussion
    @discussion = Discussion.find(discussion_id)
  end

  def discussion_id
    recipient = mail.recipients.find { |r| MATCHER.match?(r) }
    recipient[MATCHER, 1]
  end

  private

  def ensure_user
    bounce_with UserMailer.missing(inbound_email) if user.nil?
  end
end
