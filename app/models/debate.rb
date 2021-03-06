require 'numeric'
class Debate < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  apply_simple_captcha
  TITLE_LENGTH = Debate.columns.find { |c| c.name == 'title' }.limit

  acts_as_votable
  acts_as_commentable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :flags, :as => :flaggable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  scope :sorted_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
  scope :with_ignored_flag, -> { where("ignored_flag_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged, -> { where("flags_count > 0") }
  scope :for_render, -> { includes(:tags) }
  scope :sort_by_total_votes, -> { reorder(cached_votes_total: :desc) }
  scope :sort_by_likes , -> { reorder(cached_votes_up: :desc) }
  scope :sort_by_created_at, -> { reorder(created_at: :desc) }
      

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  def self.search(params)
    if params[:tag]
      tagged_with(params[:tag])
    else
      all
    end
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def editable?
    total_votes == 0
  end

  def editable_by?(user)
    editable? && author == user
  end

  def description
    super.try :html_safe
  end

  def tag_list_with_limit(limit = nil)
    tags.most_used(limit).pluck :name
  end

  def tags_count_out_of_limit(limit = nil)
    return 0 unless limit

    count = tags.count - limit
    count < 0 ? 0 : count
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    update(ignored_flag_at: Time.now)
  end

  protected

  def sanitize_description
    self.description = WYSIWYGSanitizer.new.sanitize(description)
  end

  def sanitize_tag_list
    self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
  end

end
